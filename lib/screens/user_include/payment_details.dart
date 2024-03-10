import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lego/screens/user_include/paymentHistory.dart';


class MainCard extends StatefulWidget {
  const MainCard({super.key});

  @override
  State<MainCard> createState() => _MainCardState();
}

class _MainCardState extends State<MainCard> {
  String? userName;
  double? price;
  String? costMessage;
  String? userRole;
  File? userImage; // Declare userImage as a class member variable
  double? cost;

  @override
  void initState() {
    super.initState();
    fetchUserName();
    fetchUserData();
    fetchRequestSeatCost();
  }

  Future<void> fetchUserName() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUser.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          userName = userDoc.get("username");
        });
      }
    }
  }

  Future<void> fetchUserData() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUser.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          userName = userDoc.get("username");
          userRole = userDoc.get("rool");
        });

        // Fetch the cost based on the user's role
        final costCollection = userRole == "Permanent"
            ? FirebaseFirestore.instance.collection("permant")
            : FirebaseFirestore.instance.collection("non_permant");

        final costDoc = await costCollection.doc("cost").get();
        if (costDoc.exists) {
          setState(() {
            price = costDoc.get("price")?.toDouble();

            // Set the display message based on the user's role
            costMessage = userRole == "Permanent"
                ? 'Your Monthly Payment Due is:'
                : 'You must pay per ride:';
          });
        }
      }
    }
  }

  Future<void> handlePayment() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUser.uid)
          .get();

      if (userDoc.exists) {
        final username = userDoc.get("username");
        final userRole = userDoc.get("rool");
        final currentDateTime = DateTime.now();
        final currentUserUID = currentUser.uid;

        // Upload the image to Firebase Storage
        final photoUrl = await uploadImageAndGetDownloadURL(userImage);

        // Save payment details to Firestore, including the download URL
        await FirebaseFirestore.instance.collection("payments").add({
          "username": username,
          "userRole": userRole,
          "paymentDate": currentDateTime,
          "photoUrl": photoUrl,
          "userUID": currentUserUID,
          "confirmed": false, // Add this line to set confirmed to false
        });

        // Show a dialog with the payment success message
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Payment Success'),
              content: const Text('Payment processed successfully'),
              actions: <Widget>[
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                    // Clear the uploaded photo
                    setState(() {
                      userImage = null;
                    });
                  },
                ),
              ],
            );
          },
        );
      }
    }
  }

  Future<void> fetchRequestSeatCost() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUser.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          userName = userDoc.get("username");
          userRole = userDoc.get("rool");
        });

        print("User Role: $userRole");

        if (userRole == "Permanent") {
          // Fetch the cost based on the user's role
          final costCollection =
              FirebaseFirestore.instance.collection("permant");

          final costDoc = await costCollection.doc("cost").get();
          if (costDoc.exists) {
            setState(() {
              cost = costDoc.get("price")?.toDouble();
              costMessage = 'Your Monthly Payment Due is:';
            });
          } else {
            print("Cost document does not exist for Permanent user");
          }

          // Fetch the number of approved seat requests for Permanent users
          final requestHistoryCollection =
              FirebaseFirestore.instance.collection("request_history");

          final approvedRequestsSnapshot = await requestHistoryCollection
              .where("userUID", isEqualTo: currentUser.uid)
              .where("status", isEqualTo: "approved")
              .get();

          final numberOfApprovedRequests = approvedRequestsSnapshot.size;

          print("Number of Approved Requests: $numberOfApprovedRequests");

          // Calculate the total cost based on the number of approved seat requests
          setState(() {
            cost = cost! * numberOfApprovedRequests;
          });
        } else {
          // Non-Permanent user
          // Fetch the cost based on the user's role
          final costCollection =
              FirebaseFirestore.instance.collection("non_permant");

          final costDoc = await costCollection.doc("cost").get();
          if (costDoc.exists) {
            setState(() {
              cost = costDoc.get("price")?.toDouble();
              costMessage = 'You must pay per ride:';
            });
          } else {
            print("Cost document does not exist for Non-Permanent user");
          }

          // Fetch the number of approved seat requests for Non-Permanent users
          final requestHistoryCollection =
              FirebaseFirestore.instance.collection("request_history");

          final approvedRequestsSnapshot = await requestHistoryCollection
              .where("userUID", isEqualTo: currentUser.uid)
              .where("status", isEqualTo: "approved")
              .get();

          final numberOfApprovedRequests = approvedRequestsSnapshot.size;

          print("Number of Approved Requests: $numberOfApprovedRequests");

          // Calculate the total cost based on the number of approved seat requests
          setState(() {
            cost = cost! * numberOfApprovedRequests;
          });
        }
      } else {
        print("User document does not exist");
      }
    }
  }

  Future<String?> uploadImageAndGetDownloadURL(File? image) async {
    if (image != null) {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final currentUserUID = currentUser.uid;
        final fileName =
            '$currentUserUID/${DateTime.now().toIso8601String()}.jpg';

        final storage = FirebaseStorage.instance;
        final storageRef = storage.ref().child('user_images/$fileName');

        await storageRef.putFile(image);

        // Retrieve and return the download URL
        return await storageRef.getDownloadURL();
      }
    }
    return null;
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        final currentUserUID = currentUser.uid;
        final fileName =
            '$currentUserUID/${DateTime.now().toIso8601String()}.jpg';

        final storage = FirebaseStorage.instance;
        final storageRef = storage.ref().child('user_images/$fileName');

        await storageRef.putFile(File(pickedFile.path));

        // Now, you've saved the image in Firebase Storage under the user's UID document.
        // You can also display the image using the fileName in the admin-side code.

        setState(() {
          userImage = File(pickedFile
              .path); // Set userImage for display in the user interface.
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Payment Details'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Hello, ${userName ?? 'User'}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors
                              .black, // You can change the color to your preference
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 10),
                          Text(
                            cost != null
                                ? '$costMessage \$${price?.toStringAsFixed(2)}'
                                : 'Cost: Loading...',
                            style: const TextStyle(
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 25),
                          Text(
                            'Request Seat Cost: ${cost?.toStringAsFixed(2) ?? 'Loading...'}',
                            style: const TextStyle(
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: 380,
                      height: 290,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 3,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: <Widget>[
                          GestureDetector(
                            onTap: _pickImage,
                            child: userImage != null
                                ? Image.file(
                                    userImage!,
                                    width: 100,
                                    height: 100,
                                  )
                                : Container(
                                    width: 150,
                                    height: 150,
                                    color: Colors.grey,
                                    child: const Center(
                                      child: Text(
                                        'Tap to Upload Image',
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: handlePayment,
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Text('Pay'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to the PaymentHistoryPage and pass the userRole
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PaymentHistoryPage(),
            ),
          );
        },
        backgroundColor: Colors.black,
        child: const Icon(Icons.history),
      ),
    );
  }
}
