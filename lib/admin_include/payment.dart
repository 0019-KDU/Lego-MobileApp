import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PaymentDetails extends StatefulWidget {
  const PaymentDetails({Key? key}) : super(key: key);

  @override
  _PaymentDetailsState createState() => _PaymentDetailsState();
}

class _PaymentDetailsState extends State<PaymentDetails> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('details')
            .where('pay', isEqualTo: 'pending') // Filter by pending payments
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No pending payments found.'));
          }

          // Display the list of pending payments
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final document = snapshot.data!.docs[index];
              final data = document.data() as Map<String, dynamic>;
              final documentId = document.id;
              final userId = data['userId']; // Get the user's UID

              // Fetch user information based on the UID
              return FutureBuilder<DocumentSnapshot>(
                future: _firestore.collection('users').doc(userId).get(),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }

                  if (!userSnapshot.hasData) {
                    return Text('User not found');
                  }

                  final userData =
                      userSnapshot.data!.data() as Map<String, dynamic>;
                  final username = userData['username']; // Get the username

                  return Card(
                    elevation: 4,
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: ListTile(
                      title:
                          Text('Username: $username'), // Display the username
                      subtitle: Text('Selected Date: ${data['selected_date']}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.check),
                            color: Colors.green,
                            onPressed: () {
                              // Approve the payment
                              _approvePayment(documentId);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.close),
                            color: Colors.red,
                            onPressed: () {
                              // Reject the payment
                              _rejectPayment(documentId);
                            },
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

  Future<void> _approvePayment(String documentId) async {
    try {
      await _firestore.collection('details').doc(documentId).update({
        'pay': 'approved', // Update the payment status to 'approved'
      });
      // Provide feedback to the admin, e.g., show a snackbar.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment approved.'),
        ),
      );
    } catch (error) {
      print('Error approving payment: $error');
      // Handle the error, e.g., show an error message.
    }
  }

  Future<void> _rejectPayment(String documentId) async {
    try {
      await _firestore.collection('details').doc(documentId).update({
        'pay': 'rejected', // Update the payment status to 'rejected'
      });
      // Provide feedback to the admin, e.g., show a snackbar.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment rejected.'),
        ),
      );
    } catch (error) {
      print('Error rejecting payment: $error');
      // Handle the error, e.g., show an error message.
    }
  }
}
