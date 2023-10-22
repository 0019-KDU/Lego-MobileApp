import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PaymentItem {
  final String username;
  final DateTime paymentDate;
  final String photoUrl;
  final String userRole;
  final String documentId; // Add documentId to PaymentItem

  PaymentItem(this.username, this.paymentDate, this.photoUrl, this.userRole,
      this.documentId);
}

class AdminPayments extends StatefulWidget {
  const AdminPayments(List<int> list, {Key? key}) : super(key: key);

  @override
  State<AdminPayments> createState() => _AdminPaymentsState();
}

class _AdminPaymentsState extends State<AdminPayments> {
  List<PaymentItem> paymentItems = [];
  @override
  void dispose() {
    // Cancel any ongoing tasks (e.g., timers)
    // Dispose of any resources that may still be active
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Admin Payments'),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: fetchPayments(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No payment data available.'),
            );
          } else {
            paymentItems = snapshot.data!.docs.map((payment) {
              String photoUrl = payment['photoUrl'];
              DateTime paymentDate =
                  (payment['paymentDate'] as Timestamp).toDate();
              String userRole = payment['userRole'];
              String documentId = payment.id; // Get the document ID
              return PaymentItem(payment['username'], paymentDate, photoUrl,
                  userRole, documentId);
            }).toList();

            return ListView.builder(
              itemCount: paymentItems.length,
              itemBuilder: (context, index) {
                var payment = paymentItems[index];

                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text('Username: ${payment.username} paid'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            'Payment Date: ${DateFormat('yyyy/MM/dd').format(payment.paymentDate)}'),
                        Text('User Role: ${payment.userRole}'),
                      ],
                    ),
                    leading: GestureDetector(
                      onTap: () {
                        _showImageDialog(context, payment.photoUrl);
                      },
                      child: Image.network(
                        payment.photoUrl,
                        width: 80,
                        height: 80,
                      ),
                    ),
                    trailing: ElevatedButton(
                      onPressed: () {
                        handleConfirmation(payment);
                      },
                      child: const Text('Confirm'),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  Future<QuerySnapshot> fetchPayments() async {
    return FirebaseFirestore.instance.collection('payments').get();
  }

  void handleConfirmation(PaymentItem payment) {
    String confirmationMessage;
    Map<String, dynamic> updateData = {};

    if (payment.userRole == "Permanent") {
      final currentMonth = DateFormat('MMMM').format(DateTime.now());
      confirmationMessage = 'Payment confirmed for $currentMonth';
      updateData['confirmMonth'] = currentMonth;
    } else {
      confirmationMessage = 'Payment confirmed';
      updateData['confirmDate'] = Timestamp.now();
    }

    FirebaseFirestore.instance
        .collection('payments')
        .doc(payment.documentId)
        .update({
      'confirmed': true,
      ...updateData,
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation Successful'),
          content: Text(confirmationMessage),
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

  void _showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: SizedBox(
            width: 200,
            height: 200,
            child: Image.network(imageUrl),
          ),
        );
      },
    );
  }
}
