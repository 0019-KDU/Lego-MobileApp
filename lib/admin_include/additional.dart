import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminSeatResponseScreen extends StatefulWidget {
  const AdminSeatResponseScreen(List<int> list, {Key? key}) : super(key: key);

  @override
  State<AdminSeatResponseScreen> createState() =>
      _AdminSeatResponseScreenState();
}

class _AdminSeatResponseScreenState extends State<AdminSeatResponseScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> requestsData = [];
  Map<String, bool> approvalStatus = {};

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final snapshot = await _firestore.collection('seat_requests').get();
    requestsData =
        snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

    // Initialize approvalStatus map for all valid requests
    approvalStatus = {
      for (var requestId in requestsData
          .where((request) => request['requestId'] != null)
          .map((request) => request['requestId'] as String))
        requestId: false
    };

    setState(() {});
  }

  Future<String?> fetchUsername(String? userId) async {
    if (userId == null) {
      return null;
    }

    final userSnapshot = await _firestore.collection('users').doc(userId).get();

    if (userSnapshot.exists) {
      return userSnapshot.data()?['username'];
    } else {
      return null; // User not found
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Seat Response'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('seat_requests').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final requests = snapshot.data!.docs;

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index].data() as Map<String, dynamic>;
              final requestId = requests[index].id;
              final userId = request['userId'] as String?;
              String username = 'Username: User not found'; // Default value

              return FutureBuilder<String?>(
                future: fetchUsername(userId),
                builder: (context, usernameSnapshot) {
                  if (usernameSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const CircularProgressIndicator(
                      strokeWidth: 1,
                    );
                  }

                  if (usernameSnapshot.hasError) {
                    // Handle the error case if needed
                    return Text('Error: ${usernameSnapshot.error}');
                  }

                  if (usernameSnapshot.data != null) {
                    username = 'Username: ${usernameSnapshot.data}';
                  }

                  return Card(
                    margin: const EdgeInsets.all(8),
                    elevation: 3,
                    child: ListTile(
                      title:
                          Text('Requested Seats: ${request['requestedSeats']}'),
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
                              _updateRequestStatus(requestId, 'approved');
                              _showFeedback('Request approved');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            child: const Text('Approve'),
                          ),
                          const SizedBox(
                            width: 3,
                          ),
                          ElevatedButton(
                            onPressed: () {
                              _updateRequestStatus(requestId, 'rejected');
                              _showFeedback('Request rejected');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: const Text('Reject'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
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

  void _showFeedback(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
