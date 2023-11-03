import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PaymentHistoryPage extends StatefulWidget {
  const PaymentHistoryPage({Key? key}) : super(key: key);

  @override
  _PaymentHistoryPageState createState() => _PaymentHistoryPageState();
}

class _PaymentHistoryPageState extends State<PaymentHistoryPage> {
  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(currentUser.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>?;
          if (userData == null) {
            return const Center(child: Text("User data not found."));
          }

          final userRole = userData["rool"] as String;

          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.black,
              title: const Text('Payment History'),
            ),
            body: FutureBuilder<List<PaymentInfo>>(
              future: fetchPaymentHistory(currentUser.uid),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final paymentHistory = snapshot.data;

                return ListView.builder(
                  itemCount: paymentHistory!.length,
                  itemBuilder: (context, index) {
                    final paymentDate =
                        paymentHistory[index].paymentDate.toDate();
                    final formattedDate =
                        DateFormat('yyyy/MM/dd').format(paymentDate);

                    return ListTile(
                      title: _buildSubtitle(paymentHistory[index], userRole),
                      subtitle: Text('Payment Date: $formattedDate'),
                    );
                  },
                );
              },
            ),
          );
        },
      );
    } else {
      return const Center(child: Text("User not logged in."));
    }
  }

  Widget _buildSubtitle(PaymentInfo paymentInfo, String userRole) {
    if (userRole == "Permanent") {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Confirmed: ${paymentInfo.confirmed}'),
          Text('Confirm Month: ${paymentInfo.confirmMonth ?? "N/A"}'),
        ],
      );
    } else if (userRole == "Non-Permanent") {
      final confirmDate = paymentInfo.confirmDate;
      final confirmDateString = confirmDate != null
          ? DateFormat("MMMM d, y 'at' H:mm:ss a 'UTC'Z")
              .format(confirmDate.toDate())
          : "N/A";

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Confirm Date: $confirmDateString'),
          Text('Confirmed: ${paymentInfo.confirmed}'),
        ],
      );
    } else {
      return const SizedBox.shrink(); // Hide the widget for other user roles
    }
  }

  Future<List<PaymentInfo>> fetchPaymentHistory(String userUID) async {
    final paymentsCollection =
        FirebaseFirestore.instance.collection("payments");
    final querySnapshot =
        await paymentsCollection.where("userUID", isEqualTo: userUID).get();

    final payments = querySnapshot.docs.map((doc) {
      return PaymentInfo.fromMap(doc.data());
    }).toList();

    return payments;
  }
}

class PaymentInfo {
  final Timestamp paymentDate;
  final String? confirmMonth; // Make it nullable
  final Timestamp? confirmDate; // Make it nullable
  final bool confirmed;

  PaymentInfo(
      this.paymentDate, this.confirmMonth, this.confirmDate, this.confirmed);

  factory PaymentInfo.fromMap(Map<String, dynamic> map) {
    final Timestamp paymentDate = map["paymentDate"] as Timestamp;
    final String? confirmMonth = map["confirmMonth"] as String?;
    final Timestamp? confirmDate = map["confirmDate"] as Timestamp?;
    final bool confirmed = map["confirmed"] as bool;

    return PaymentInfo(paymentDate, confirmMonth, confirmDate, confirmed);
  }
}
