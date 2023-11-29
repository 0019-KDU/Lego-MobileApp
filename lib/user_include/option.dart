import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lego/components/nm_box.dart';

class SeatRequestScreen extends StatefulWidget {
  const SeatRequestScreen({Key? key}) : super(key: key);

  @override
  State<SeatRequestScreen> createState() => _SeatRequestScreenState();
}

class _SeatRequestScreenState extends State<SeatRequestScreen> {
  int requestedSeats = 1;
  String purpose = '';
  String bannerMessage = '';

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _purposeController =
      TextEditingController(); // Step 1
  int requestedseats = 0;

  @override
  void initState() {
    super.initState();
    getBannerMessage().then((message) {
      setState(() {
        bannerMessage = message ??
            ''; // Set the banner message or an empty string if it's not available.
      });
    });
  }

  Future<int> getSeatPrice(int requestedSeats) async {
    try {
      final priceDoc =
          await _firestore.collection('non_permant').doc('cost').get();

      if (priceDoc.exists) {
        final price = (priceDoc.data()?['price'] as num).toInt();
        print('Retrieved price: $price');
        return price * requestedSeats;
      } else {
        print('Price document does not exist.');
      }
    } catch (e) {
      print('Error fetching seat price: $e');
    }

    return 0; // Default price if not found, as an integer
  }

  Future<String?> getBannerMessage() async {
    try {
      final bannerQuery = await _firestore.collection('banner_messages').get();

      if (bannerQuery.docs.isNotEmpty) {
        final bannerDoc = bannerQuery.docs.first;
        return bannerDoc.data()['message'] as String?;
      }
    } catch (e) {
      print('Error fetching banner message: $e');
    }

    return null;
  }

  bool showRequestDetails = true;
  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Seat Request"),
          backgroundColor: Colors.black,
        ),
        backgroundColor: mC,
        body: Container(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(
                height: 30,
              ),
              const Text(
                'How many additional seats do you need?',
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  IconButton(
                    icon: const Icon(
                      Icons.remove,
                      color: Colors.blue,
                    ),
                    onPressed: () {
                      setState(() {
                        if (requestedSeats > 1) {
                          requestedSeats--;
                        }
                      });
                    },
                  ),
                  Text(
                    requestedSeats.toString(),
                    style: const TextStyle(fontSize: 24),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.add,
                      color: Colors.blue,
                    ),
                    onPressed: () {
                      setState(() {
                        if (requestedSeats < 5) {
                          requestedSeats++;
                        }
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _purposeController,
                onChanged: (text) {
                  setState(() {
                    purpose = text;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Specify the purpose',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceEvenly, // Adjust as needed
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    onPressed: () async {
                      if (user == null) {
                        // User is not authenticated
                        return;
                      }

                      // Validate the purpose field
                      if (purpose.trim().isEmpty) {
                        // Show an error message if the purpose is empty
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Purpose cannot be empty.'),
                          ),
                        );
                        return; // Don't submit the request
                      }

                      final lastRequest = await getLastRequest(user.uid);

                      if (lastRequest == null ||
                          canMakeNewRequest(lastRequest['timestamp'])) {
                        final price = await getSeatPrice(
                            requestedSeats); // Get the seat price
                        await submitRequest(user.uid, requestedSeats, purpose);

                        // Clear the input fields
                        setState(() {
                          requestedSeats = 0;
                          purpose = '';
                          _purposeController.clear();
                        });

                        // Show a snackbar indicating the request is pending
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Request submitted and pending. Cost: \$$price'),
                          ),
                        );
                      } else {
                        // User cannot make a new request
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Request Limit Reached'),
                              content: const Text(
                                  'You cannot make a new request at this time.'),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text('OK'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 10.0,
                        horizontal: 20.0,
                      ),
                      child: Text('Submit Request'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    onPressed: () async {
                      // Get the user
                      final user = _auth.currentUser;

                      if (user == null) {
                        // User is not authenticated
                        return;
                      }

                      // Get the last request document ID
                      final lastRequestDocumentId =
                          await getLastRequestDocumentId(user.uid);

                      if (lastRequestDocumentId != null) {
                        // Get the last request using the document ID
                        final lastRequest = await FirebaseFirestore.instance
                            .collection('seat_requests')
                            .doc(lastRequestDocumentId)
                            .get();

                        if (lastRequest.exists) {
                          // Delete the request
                          await FirebaseFirestore.instance
                              .collection('seat_requests')
                              .doc(lastRequestDocumentId)
                              .delete();

                          // Save to RecycleHistory
                          await saveToRecycleHistory(
                            user.uid,
                            lastRequest['requestedSeats'] as int,
                            lastRequest['purpose'] as String,
                          );

                          // Show a snackbar indicating the request is deleted
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Request deleted and saved to RecycleHistory.'),
                            ),
                          );
                        } else {
                          // Document does not exist
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('No request found to delete.'),
                            ),
                          );
                        }
                      } else {
                        // No last request document ID found
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('No request found to delete.'),
                          ),
                        );
                      }
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 10.0,
                        horizontal: 20.0,
                      ),
                      child: Text('Delete Request'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              // Display user requests and admin responses
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('seat_requests')
                      .where('userId', isEqualTo: user?.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (!snapshot.hasData ||
                        snapshot.data!.docs.isEmpty) {
                      // Prevent vibration
                      HapticFeedback
                          .lightImpact(); // or HapticFeedback.heavyImpact();
                      return const Text('No seat requests found.');
                    } else {
                      final documents = snapshot.data!.docs;
                      // Set the requestedSeats variable based on the latest request
                      final lastRequest = documents.first;
                      requestedSeats = lastRequest['requestedSeats'] as int;
                      // Create a list of Future objects to fetch seat prices
                      final priceFutures = documents.map((document) {
                        final documentData =
                            document.data() as Map<String, dynamic>;
                        final requestedSeats =
                            documentData['requestedSeats'] as int;
                        return getSeatPrice(requestedSeats);
                      }).toList();

                      return ListView.builder(
                        itemCount: documents.length,
                        itemBuilder: (context, index) {
                          return FutureBuilder<int>(
                            future: priceFutures[index],
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                final documentData = documents[index].data()
                                    as Map<String, dynamic>;
                                final adminResponse =
                                    documentData['status'] ?? 'Pending';
                                final requestedSeats =
                                    documentData['requestedSeats'] as int;
                                final cost = snapshot.data
                                    .toString(); // This is the calculated cost

                                return InkWell(
                                  onTap: () {
                                    // Handle ListTile tap if needed
                                  },
                                  child: Container(
                                    height: 120, // Adjust the height as needed
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.grey),
                                    ),
                                    child: Stack(
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            if (showRequestDetails)
                                              Text(
                                                'Requested Seats: $requestedSeats',
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            if (showRequestDetails)
                                              Text(
                                                'Purpose: ${documentData['purpose']}',
                                                style: const TextStyle(
                                                    fontSize: 15),
                                              ),
                                            if (showRequestDetails)
                                              Text(
                                                'Admin Response: $adminResponse',
                                                style: const TextStyle(
                                                    fontSize: 15),
                                              ),
                                            if (showRequestDetails)
                                              Text(
                                                'Cost: \$$cost',
                                                style: const TextStyle(
                                                    fontSize: 15),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              } else {
                                return const CircularProgressIndicator(); // Show a loading indicator while calculating the price.
                              }
                            },
                          );
                        },
                      );
                    }
                  },
                ),
              ),

              if (bannerMessage.isNotEmpty)
                SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(
                              10.0), // Adjust the radius as needed
                        ),
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                bannerMessage,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.history_sharp,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String?> getLastRequestDocumentId(String userId) async {
    final userRequests = await _firestore
        .collection('seat_requests')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    if (userRequests.docs.isNotEmpty) {
      return userRequests.docs.first.id;
    } else {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getLastRequest(String userId) async {
    final userRequests = await _firestore
        .collection('seat_requests')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    if (userRequests.docs.isNotEmpty) {
      final lastRequest =
          userRequests.docs.first.data() as Map<String, dynamic>;
      print("Last request data: $lastRequest");
      return lastRequest;
    } else {
      print("No last request found");
    }

    return null;
  }

  bool canMakeNewRequest(Timestamp lastRequestTimestamp) {
    final today = Timestamp.now();
    final fiveDaysAgo = today.toDate().subtract(const Duration(days: 5));
    return lastRequestTimestamp.toDate().isBefore(fiveDaysAgo);
  }

  Future<void> submitRequest(
      String userId, int requestedSeats, String purpose) async {
    await _firestore.collection('seat_requests').add({
      'userId': userId,
      'requestedSeats': requestedSeats,
      'purpose': purpose,
      'timestamp': Timestamp.now(),
      'status': 'Pending', // Add a default status
    });
  }

  Future<void> saveToRecycleHistory(
      String? userId, int requestedSeats, String purpose) async {
    if (userId != null) {
      await _firestore.collection('RecycleHistory').add({
        'userId': userId,
        'requestedSeats': requestedSeats,
        'purpose': purpose,
        'timestamp': Timestamp.now(),
      });

      // Clear the purpose controller after saving to recycle history
      _purposeController.clear();
    }
  }
}
