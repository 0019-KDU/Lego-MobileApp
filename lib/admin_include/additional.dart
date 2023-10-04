import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminSeatResponseScreen extends StatefulWidget {
  const AdminSeatResponseScreen(List<int> list, {Key? key}) : super(key: key);

  @override
  State<AdminSeatResponseScreen> createState() => _AdminSeatResponseScreen();
}

class _AdminSeatResponseScreen extends State<AdminSeatResponseScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.indigo,
                      ),
                    ),
                  ), // Add other widgets or buttons here if needed
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('seat_requests').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final requests = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: requests.length,
                    itemBuilder: (context, index) {
                      final request =
                          requests[index].data() as Map<String, dynamic>;
                      final requestId = snapshot.data!.docs[index].id;

                      // Check if user data is available
                      final userId = request['userId'] as String?;
                      final username = userId != null
                          ? 'Username: ${request['username']}'
                          : 'Username: User not found';

                      return Card(
                        margin: const EdgeInsets.all(8),
                        elevation: 3,
                        child: ListTile(
                          title: Text(
                              'Requested Seats: ${request['requestedSeats']}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Purpose: ${request['purpose']}'),
                              Text(username),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  // Approve the request (update Firestore)
                                  _updateRequestStatus(requestId, 'approved');
                                  _showFeedback('Request approved');
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green),
                                child: const Text('Approve'),
                              ),
                              const SizedBox(
                                width: 3,
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  // Reject the request (update Firestore)
                                  _updateRequestStatus(requestId, 'rejected');
                                  _showFeedback('Request rejected');
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red),
                                child: const Text('Reject'),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateRequestStatus(String requestId, String status) async {
    await _firestore.collection('seat_requests').doc(requestId).update({
      'status': status,
    });
  }

  void _showFeedback(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
