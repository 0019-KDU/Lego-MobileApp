import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PaymentDetails extends StatefulWidget {
  const PaymentDetails(List<int> list, {super.key});

  @override
  State<PaymentDetails> createState() => _PaymentDetailsState();
}

class _PaymentDetailsState extends State<PaymentDetails> {
  void _approvePayment(String userName) {
    // Implement logic to approve payment here
    // You can update the 'status' field in Firestore
    // and perform any additional actions if needed
    FirebaseFirestore.instance
        .collection('payments')
        .where('userName', isEqualTo: userName)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        doc.reference.update({'status': 'approved'});
      });
    });

    // Notify the user that their payment has been approved
  }

  void _rejectPayment(String userName) {
    // Implement logic to reject payment here
    // You can update the 'status' field in Firestore
    // and perform any additional actions if needed
    FirebaseFirestore.instance
        .collection('payments')
        .where('userName', isEqualTo: userName)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        doc.reference.update({'status': 'rejected'});
      });
    });

    // Notify the user that their payment has been rejected
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Screen'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('payments').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          List<DocumentSnapshot> payments = snapshot.data!.docs;

          return ListView.builder(
            itemCount: payments.length,
            itemBuilder: (BuildContext context, int index) {
              Map<String, dynamic> data =
                  payments[index].data() as Map<String, dynamic>;

              return Card(
                margin: EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(
                    'User: ${data['userName']}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Status: ${data['status']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.check, color: Colors.green),
                        onPressed: () => _approvePayment(data['userName']),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.red),
                        onPressed: () => _rejectPayment(data['userName']),
                      ),
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
