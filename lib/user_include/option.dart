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

  @override
  Widget build(BuildContext context) {
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
                final user = _auth.currentUser;

                if (user == null) {
                  // User is not authenticated
                  return;
                }

                final lastRequest = await getLastRequest(user.uid);

                if (lastRequest == null ||
                    canMakeNewRequest(
                      lastRequest['timestamp'],
                    )) {
                  await submitRequest(user.uid, requestedSeats, purpose);

                  // Clear the input fields
                  setState(() {
                    requestedSeats = 1;
                    purpose = '';
                  });
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
                final user = _auth.currentUser;

                if (user == null) {
                  // User is not authenticated
                  return;
                }

                await deleteRequest(user.uid);
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
    final userRequests = await _firestore
        .collection('seat_requests')
        .where('userId', isEqualTo: userId)
        .get();

    for (final request in userRequests.docs) {
      await request.reference.delete();
    }
  }
}
