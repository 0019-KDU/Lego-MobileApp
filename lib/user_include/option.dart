import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SeatRequestScreen extends StatefulWidget {
  const SeatRequestScreen({Key? key}) : super(key: key);

  @override
  State<SeatRequestScreen> createState() => _SeatRequestScreenState();
}

class _SeatRequestScreenState extends State<SeatRequestScreen> {
  int requestedSeats = 1;
  String purpose = '';

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _purposeController =
      TextEditingController(); // Step 1

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Additional Seats'),
      ),
      body: Container(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
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
            const SizedBox(height: 20),
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

                final lastRequest = await getLastRequest(user.uid);

                if (lastRequest == null ||
                    canMakeNewRequest(lastRequest['timestamp'])) {
                  await submitRequest(user.uid, requestedSeats, purpose);

                  // Clear the input fields
                  setState(() {
                    requestedSeats = 1;
                    purpose = '';
                    _purposeController.clear();
                  });

                  // Show a snackbar indicating the request is pending
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Request submitted and pending.'),
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
                if (user == null) {
                  // User is not authenticated
                  return;
                }

                await deleteRequest(user.uid);

                // Show a snackbar indicating the request is deleted
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Request deleted.'),
                  ),
                );
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 20.0,
                ),
                child: Text('Delete Request'),
              ),
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
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // Show a loading indicator while data is loading
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    // Handle error
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    // Handle case when no data is available
                    return Text('No seat requests found.');
                  } else {
                    // Display user requests and admin responses
                    final documents = snapshot.data!.docs;
                    return ListView.builder(
                      itemCount: documents.length,
                      itemBuilder: (context, index) {
                        final documentData =
                            documents[index].data() as Map<String, dynamic>;
                        final adminResponse = documentData['status'] ??
                            'Pending'; // Default to 'Pending' if field doesn't exist
                        return ListTile(
                          title: Text(
                              'Requested Seats: ${documentData['requestedSeats']}'),
                          subtitle: Text('Purpose: ${documentData['purpose']}'),
                          trailing: Text('Admin Response: $adminResponse'),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<Map<String, dynamic>?> getLastRequest(String userId) async {
    final userRequests = await _firestore
        .collection('seat_requests')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    if (userRequests.docs.isNotEmpty) {
      return userRequests.docs.first.data() as Map<String, dynamic>;
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
    });
  }

  Future<void> deleteRequest(String userId) async {
    try {
      final userRequests = await _firestore
          .collection('seat_requests')
          .where('userId', isEqualTo: userId)
          .get();

      for (final request in userRequests.docs) {
        await request.reference.delete();
      }
    } catch (e) {
      print("Error deleting request: $e");
      // Handle the error here, e.g., display an error message to the user.
    }
  }
}
