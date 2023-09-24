import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lego/user_include/paymenthistory.dart';

class UserMainPage extends StatefulWidget {
  const UserMainPage({super.key});

  @override
  State<UserMainPage> createState() => _UserMainPageState();
}

class _UserMainPageState extends State<UserMainPage> {
  String? userName; // Variable to store the user's name

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _storeSelectedValue() async {
    if (_fromkey.currentState!.validate()) {
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        final selectedValuesCollection =
            FirebaseFirestore.instance.collection("selected_values");

        final existingValueDoc = await selectedValuesCollection
            .where("userId", isEqualTo: currentUser.uid)
            .get();

        if (existsSelected == null) {
          _showDialog("Error", "Please select a value from the dropdown.");
          return;
        }

        if (existingValueDoc.docs.isNotEmpty) {
          // User has already saved a value, check time difference
          final lastTimestamp =
              existingValueDoc.docs.first.get("timestamp") as Timestamp;
          final currentTime = Timestamp.now();

          // Calculate the difference in seconds
          final timeDifference = currentTime.seconds - lastTimestamp.seconds;
          const requiredTimeDifference = 1 * 24 * 60 * 60; // 1 days in seconds

          if (timeDifference < requiredTimeDifference) {
            _showDialog(
                "Waraning", "You can add a new value after a few days.");
            return;
          }
        }

        // User hasn't saved a value or enough time has passed, proceed to save
        await selectedValuesCollection.add({
          "userId": currentUser.uid,
          "selectedValue": existsSelected,
          "timestamp": FieldValue.serverTimestamp(),
        });

        _showDialog("Success", "Value successfully saved.");
      }
    }
  }

  //todo:Edit Function
  Future<void> _editSelectedValue() async {
    try {
      String? selectedValue = existsSelected ??
          _existPoints
              .first; // Initialize with the current value or the first item

      selectedValue = await showDialog<String>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Edit Value"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButton<String>(
                  value: selectedValue,
                  items: _existPoints.map((value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    selectedValue = newValue;
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(null); // Cancel the dialog
                },
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context)
                      .pop(selectedValue); // Save the selected value
                },
                child: const Text("Save"),
              ),
            ],
          );
        },
      );

      if (selectedValue != null && selectedValue != existsSelected) {
        final currentUser = FirebaseAuth.instance.currentUser;

        if (currentUser != null) {
          final selectedValuesCollection =
              FirebaseFirestore.instance.collection("selected_values");

          final existingValueDoc = await selectedValuesCollection
              .where("userId", isEqualTo: currentUser.uid)
              .get();

          if (existingValueDoc.docs.isNotEmpty) {
            final docId = existingValueDoc.docs.first.id;
            await selectedValuesCollection.doc(docId).update({
              "selectedValue": selectedValue,
              "timestamp": FieldValue.serverTimestamp(),
            });

            setState(() {
              existsSelected = selectedValue;
            });

            _showDialog("Success", "Value successfully edited.");
          }
        }
      }
    } catch (e) {
      print("Error in _editSelectedValue: $e");
      _showDialog("Error", "An error occurred while processing your request.");
    }
  }

  DateTime selectedDate = DateTime.now();
  String? imageUrl;

  Future<void> _uploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);
      final Reference storageRef =
          FirebaseStorage.instance.ref().child('your_image_path');
      await storageRef.putFile(imageFile);
      imageUrl = await storageRef.getDownloadURL();
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _storeDetails() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      final detailsCollection =
          FirebaseFirestore.instance.collection("details");

      if (imageUrl == null) {
        _showDialog("Error", "Please upload an image.");
        return;
      }

      if (selectedDate == null) {
        _showDialog("Error", "Please select a date.");
        return;
      }

      await detailsCollection.add({
        "userId": currentUser.uid,
        "pay": "pending", // Set the initial status as pending
        "timestamp": FieldValue.serverTimestamp(),
        "image_url": imageUrl,
        "selected_date": selectedDate.toUtc(),
      });

      _showDialog("Success", "Payment details submitted for admin approval.");
    }
  }

  void _navigateToPayHistory(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const PayHistoryPage(), // Navigate to PayHistoryPage
      ),
    );
  }

  late GlobalKey<FormState> _fromkey;
  String? existsSelected;
  String? message = "";
  final List<String> _existPoints = <String>[
    'Kaduwela',
    'Kothalawala',
    'Athurugiriya',
    'Kottawa',
    'Kahathuduwa',
    'Gelanigama',
    'Dodangoda',
    'Welipanna',
    'Kurundugaha',
    'Baddegama',
    'Pinnaduwa',
    'Imaduwa',
    'Kokmaduwa',
    'Godagama',
    'Palatuwa',
    'Kapuduwa',
    'Aparekka',
    'beliatta',
    'bedigama',
    'kasagala',
    'Angunukolapelessa',
    'Barawakumbuka',
    'Sooriyawewa',
  ];

  //bool isDropdownVisible = false;
  bool isDropdownVisible = false;

  void toggleDropdown() {
    setState(() {
      isDropdownVisible = !isDropdownVisible;
    });
  }

  @override
  void initState() {
    super.initState();
    _fromkey = GlobalKey<FormState>();
    fetchUserName();
  }

  Future<void> fetchUserName() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection("users") // Replace with the actual collection name
          .doc(currentUser.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          userName = userDoc.get(
              "username"); // Assuming the username field exists in Firestore
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _fromkey,
        child: ListView(
          children: [
            if (userName != null)
              Container(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Text(
                      'Welcome,',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                        fontFamily:
                            'YourCustomFont', // Replace with your custom font
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      userName!,
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontFamily:
                            'YourCustomFont', // Replace with your custom font
                      ),
                    ),
                  ],
                ),
              ),
            Container(
              width: 550,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
                borderRadius: BorderRadius.circular(16),
              ),
              margin: const EdgeInsets.all(30),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isDropdownVisible = !isDropdownVisible;
                          });
                        },
                        child: Icon(
                          isDropdownVisible
                              ? Icons.arrow_drop_up
                              : Icons.arrow_drop_down,
                          size: 30,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            isDropdownVisible = !isDropdownVisible;
                          });
                        },
                        child: Container(
                          alignment: Alignment.center,
                          child: Text(
                            existsSelected ?? "Choose your Exist",
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.green.shade400,
                          shadowColor: Colors.greenAccent,
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32.0),
                          ),
                          minimumSize: const Size(90, 45),
                        ),
                        onPressed: _storeSelectedValue,
                        child: const Text("Going"),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.blue,
                          shadowColor: Colors.greenAccent,
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32.0),
                          ),
                          minimumSize: const Size(90, 45),
                        ),
                        onPressed: _editSelectedValue,
                        child: const Text("Edit"),
                      ),
                    ],
                  ),
                  if (isDropdownVisible)
                    SizedBox(
                      height: 150,
                      child: ListView.builder(
                        itemCount: _existPoints.length,
                        itemBuilder: (context, index) {
                          final value = _existPoints[index];
                          return ListTile(
                            title: Text(value),
                            onTap: () {
                              setState(() {
                                existsSelected = value;
                                isDropdownVisible = false;
                              });
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                alignment: Alignment.center,
                child: Text(
                  existsSelected != null
                      ? 'You selected location: $existsSelected'
                      : 'You have not selected a location yet',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey,
                ),
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey.shade300,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: _uploadImage,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: imageUrl != null
                          ? Image.network(imageUrl!, fit: BoxFit.cover)
                          : const Center(
                              child: Icon(Icons.add_photo_alternate),
                            ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey,
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 10,
                          child: Text(
                            selectedDate != null
                                ? "Selected Date: ${selectedDate!.toLocal().toString().split(' ')[0]}"
                                : "Select Date",
                            style: TextStyle(
                              fontSize: 18,
                              color: selectedDate != null
                                  ? Colors.black
                                  : Colors.grey,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: IconButton(
                            icon: const Icon(Icons.calendar_today),
                            tooltip: 'Tap to open date picker',
                            onPressed: () {
                              _selectDate(context);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        onPressed: _storeDetails,
                        child: const Text("Payed"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _navigateToPayHistory(
                              context); // Navigate to Pay History page
                        },
                        child: const Text("Payment History"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
