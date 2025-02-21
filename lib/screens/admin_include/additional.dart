import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lego/screens/admin_include/request_history_page.dart';

class AdminSeatResponseScreen extends StatefulWidget {
  const AdminSeatResponseScreen(List<int> list, {super.key});

  @override
  State<AdminSeatResponseScreen> createState() =>
      _AdminSeatResponseScreenState();
}

class _AdminSeatResponseScreenState extends State<AdminSeatResponseScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> requestsData = [];
  Map<String, bool> approvalStatus = {};
  List<Map<String, dynamic>> pendingRequests =
      []; // Local list for pending requests
  int totalSeats = 55; // Total number of seats available
  int approvedCount = 0;
  Map<String, int> goingDestinationCounts = {};
  Map<String, int> comingDestinationCounts = {};
  int totalGocount = 0;
  int totalComecount = 0;

  @override
  void initState() {
    super.initState();
    fetchData();
    _calculateDestinationCounts();
  }

  Future<void> fetchData() async {
    try {
      final snapshot = await _firestore.collection('seat_requests').get();
      final requestsData = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Store the document ID for reference
        return data;
      }).toList();

      // Filter pending requests
      pendingRequests = requestsData
          .where((request) =>
              (request['status'] == 'pending' || request['status'] == null))
          .toList();
    } catch (e) {
      print('Error fetching data: $e');
    }
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

  Future<void> _calculateDestinationCounts() async {
    final currentTime = DateTime.now();
    final startOfWeek =
        currentTime.subtract(Duration(days: currentTime.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    final goingValuesCollection =
        FirebaseFirestore.instance.collection("going_values");
    final comingValuesCollection =
        FirebaseFirestore.instance.collection("coming_values");

    final goingQuerySnapshot = await goingValuesCollection
        .where("timestamp",
            isGreaterThanOrEqualTo: startOfWeek, isLessThanOrEqualTo: endOfWeek)
        .get();
    final comingQuerySnapshot = await comingValuesCollection
        .where("timestamp",
            isGreaterThanOrEqualTo: startOfWeek, isLessThanOrEqualTo: endOfWeek)
        .get();

    final List<DocumentSnapshot> goingDocs = goingQuerySnapshot.docs;
    final List<DocumentSnapshot> comingDocs = comingQuerySnapshot.docs;

    goingDestinationCounts = _countDestinations(goingDocs);
    comingDestinationCounts = _countDestinations(comingDocs);

    // Calculate and add total counts
    int totalGoingCount =
        goingDestinationCounts.values.fold(0, (a, b) => a + b);
    final int totalComingCount =
        comingDestinationCounts.values.fold(0, (a, b) => a + b);
    goingDestinationCounts['Total'] = totalGoingCount;
    comingDestinationCounts['Total'] = totalComingCount;

    // Calculate and set the approved count
    approvedCount = await _calculateApprovedCount();

    setState(() {});

    totalComecount =
        comingDestinationCounts['Total'] ?? 0; // Trigger a rebuild to
    totalGocount = goingDestinationCounts['Total'] ?? 0; // Trigger a rebuild to
    print(totalGocount);
  }

  Future<int> _calculateApprovedCount() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('seat_requests')
        .where("status", isEqualTo: "approved")
        .get();

    int totalApprovedSeats = 0;

    for (final doc in snapshot.docs) {
      final status = doc.get("status") as String?;
      final requestedSeats = doc.get("requestedSeats") as int?;

      if (status == "approved" && requestedSeats != null) {
        totalApprovedSeats += requestedSeats;
      }
    }

    return totalApprovedSeats;
  }

  Map<String, int> _countDestinations(List<DocumentSnapshot> docs) {
    final Map<String, int> destinationCounts = {};

    for (final doc in docs) {
      final selectedValue = doc.get("selectedValue") as String?;
      if (selectedValue != null) {
        destinationCounts[selectedValue] =
            (destinationCounts[selectedValue] ?? 0) + 1;
      }
    }

    return destinationCounts;
  }

  @override
  Widget build(BuildContext context) {
    int remainingSeats =
        totalSeats - (approvedCount + totalGocount + totalComecount);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(
          color: Colors.white, // Change the color of the leading icon
        ),
        title: const Text(
          'Admin Seat Response',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Remaining Seats for the Week:",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Total Seats: $totalSeats",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Approved Seats: $approvedCount",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Remaining Seats: $remainingSeats", // Display remaining seats here
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),

          // Display destination counts (Coming and Going)

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('seat_requests').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final querySnapshots =
                    snapshot.data as QuerySnapshot<Map<String, dynamic>>;
                final requests = querySnapshots.docs;
                print('Fetched data count: ${requests.length}');

                for (var doc in requests) {
                  final data = doc.data();
                  print('Document ID: ${doc.id}, Data: $data');
                }

                // Filter requests based on status (e.g., only show requests with status 'pending' or empty)
                final filteredRequests = requests
                    .where((queryDocumentSnapshot) =>
                        (queryDocumentSnapshot.data())['status'] == 'Pending' ||
                        (queryDocumentSnapshot.data())['status'] == null)
                    .toList();

                return ListView.builder(
                  itemCount: filteredRequests.length,
                  itemBuilder: (context, index) {
                    final request = filteredRequests[index].data();
                    final requestId = filteredRequests[index].id;
                    final userId = request['userId'] as String?;

                    // Print the status to check its value
                    print('Request Status: ${request['status']}');

                    String username =
                        'Username: User not found'; // Default value

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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to the RequestHistoryScreen when the button is pressed
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const RequestHistoryScreen(),
            ),
          );
        },
        child: const Icon(
            Icons.history), // You can use a different icon or text here
      ),
    );
  }

  Future<void> _updateRequestStatus(String requestId, String status) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      // Handle the case where the user is not authenticated.
      return;
    }

    // Get the original request data
    final originalRequestSnapshot =
        await _firestore.collection('seat_requests').doc(requestId).get();

    if (originalRequestSnapshot.exists) {
      final originalRequestData =
          originalRequestSnapshot.data() as Map<String, dynamic>;

      // Get the user ID from the original request data
      final userId = originalRequestData['userId'];

      // Update the status of the current request
      await _firestore.collection('seat_requests').doc(requestId).update({
        'status': status,
      });

      // Remove the request from the pendingRequests list
      pendingRequests.removeWhere((request) => request['id'] == requestId);

      // Create a historical record in the request_history collection
      await _firestore.collection('request_history').add({
        'requestId': requestId,
        'status': status,
        'timestamp': FieldValue.serverTimestamp(),
        'requestedSeats': originalRequestData['requestedSeats'] ?? 0,
        'purpose': originalRequestData['purpose'] ?? '',
        'userID': userId, // Include the user ID
      });

      // Refresh the UI to remove the request from the list
      setState(() {});
    }
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
