import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PayHistoryPage extends StatelessWidget {
  const PayHistoryPage({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pay History"),
      ),
      body: const PayHistoryList(),
    );
  }
}

class PayHistoryList extends StatelessWidget {
  const PayHistoryList({Key? key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Center(child: Text("Please log in to view pay history."));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('details')
          .where('userId', isEqualTo: currentUser.uid)
          .where('pay', isEqualTo: 'approved')
          .orderBy('selected_date', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;

        if (docs.isEmpty) {
          return const Center(child: Text("No payments found."));
        }

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final paymentData = docs[index].data() as Map<String, dynamic>;
            final paymentDate = paymentData['selected_date'] != null
                ? (paymentData['selected_date'] as Timestamp).toDate()
                : DateTime.now();

            final formattedDate = DateFormat('MMM d, y').format(paymentDate);

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 3,
                child: ListTile(
                  title: Text(
                    "Payment Date: $formattedDate",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Row(
                    children: [
                      Text(
                        "Status: Payed",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(
                        Icons.check_circle,
                        color: Colors.green,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
