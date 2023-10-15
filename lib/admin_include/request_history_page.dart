import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lego/classes/historicalrequest.dart';

class RequestHistoryScreen extends StatelessWidget {
  const RequestHistoryScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request History'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('request_history')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final requests = snapshot.data!.docs;

          if (requests.isEmpty) {
            return const Center(
              child: Text('No request history available.'),
            );
          }

          // Convert Firestore documents to HistoricalRequest objects
          final historicalRequests = requests.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return HistoricalRequest(
              requestedSeats: data['requestedSeats'] ?? 0,
              purpose: data['purpose'] ?? '',
              status: data['status'] ?? '',
              timestamp: data['timestamp'] ?? Timestamp.now(),
            );
          }).toList();

          // Filter historical requests for "approved" or "rejected" status
          final filteredRequests = historicalRequests
              .where((request) =>
                  request.status == 'approved' || request.status == 'rejected')
              .toList();

          if (filteredRequests.isEmpty) {
            return const Center(
              child: Text('No approved or rejected requests found.'),
            );
          }

          return ListView.builder(
            itemCount: filteredRequests.length,
            itemBuilder: (context, index) {
              final request = filteredRequests[index];
              return Card(
                margin: const EdgeInsets.all(8),
                elevation: 3,
                child: ListTile(
                  title: Text('Requested Seats: ${request.requestedSeats}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Purpose: ${request.purpose}'),
                      Text('Status: ${request.status}'),
                      Text('Timestamp: ${request.timestamp.toDate()}'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
