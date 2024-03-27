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
  void initState() {
    super.initState();
    fetchPayments().then((payments) {
      setState(() {
        paymentItems = payments;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(
          color: Colors.white, // Change the color of the leading icon
        ),
        title:
            const Text('Admin Payments', style: TextStyle(color: Colors.white)),
      ),
      body: paymentItems.isEmpty
          ? const Center(child: Text('No payment data available.'))
          : ListView.builder(
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
                          'Payment Date: ${DateFormat('yyyy/MM/dd').format(payment.paymentDate)}',
                        ),
                        Text('User Role: ${payment.userRole}'),
                      ],
                    ),
                    leading: GestureDetector(
                      onTap: () {
                        if (payment.photoUrl != 'assets/default.jpg') {
                          _showImageDialog(context, payment.photoUrl);
                        } else {
                          // Handle the case where the image is the default asset (optional)
                        }
                      },
                      child: payment.photoUrl != 'assets/default.jpg'
                          ? Image.network(
                              payment.photoUrl,
                              width: 80,
                              height: 80,
                            )
                          : Image.asset(
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
            ),
    );
  }

  Future<List<PaymentItem>> fetchPayments() async {
    var querySnapshot =
        await FirebaseFirestore.instance.collection('payments').get();

    return querySnapshot.docs.map((payment) {
      String? photoUrl = payment['photoUrl'] as String?;
      DateTime paymentDate = (payment['paymentDate'] as Timestamp).toDate();
      String userRole = payment['userRole'];
      String documentId = payment.id;

      String defaultPhotoUrl = 'assets/default.jpg';

      return PaymentItem(
        payment['username'],
        paymentDate,
        photoUrl ?? defaultPhotoUrl,
        userRole,
        documentId,
      );
    }).toList();
  }

  void handleConfirmation(PaymentItem payment) async {
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

    await FirebaseFirestore.instance
        .collection('payments')
        .doc(payment.documentId)
        .update({
      'confirmed': true,
      ...updateData,
    });

    setState(() {
      paymentItems.remove(payment);
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
