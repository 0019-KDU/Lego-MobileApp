import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminSeatResponseScreen extends StatefulWidget {
  const AdminSeatResponseScreen(List<int> list, {super.key});

  @override
  State<AdminSeatResponseScreen> createState() => _AdminSeatResponseScreen();
}

class _AdminSeatResponseScreen extends State<AdminSeatResponseScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Interface'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('seat_requests').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const CircularProgressIndicator(); // Loading indicator
          }

          final requests = snapshot.data!.docs;

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index].data() as Map<String, dynamic>;
              final requestId = snapshot.data!.docs[index].id;

              // Display the request data and approve/reject buttons
              return ListTile(
                title: Text('Requested Seats: ${request['requestedSeats']}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Purpose: ${request['purpose']}'),
                    FutureBuilder<DocumentSnapshot>(
                      future: _firestore
                          .collection('users')
                          .doc(request['userId'])
                          .get(),
                      builder: (context, userSnapshot) {
                        if (userSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        }
                        if (!userSnapshot.hasData ||
                            !userSnapshot.data!.exists) {
                          return Text(
                              'Username: User not found'); // Handle user not found
                        }
                        final userData =
                            userSnapshot.data!.data() as Map<String, dynamic>;
                        final username = userData['username'];
                        return Text('Username: $username');
                      },
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // Approve the request (update Firestore)
                        _updateRequestStatus(requestId, 'approved');
                      },
                      child: const Text('Approve'),
                    ),
                    const SizedBox(
                      width: 3,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Reject the request (update Firestore)
                        _updateRequestStatus(requestId, 'rejected');
                      },
                      child: const Text('Reject'),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _updateRequestStatus(String requestId, String status) async {
    await _firestore.collection('seat_requests').doc(requestId).update({
      'status': status,
    });
  }
}
