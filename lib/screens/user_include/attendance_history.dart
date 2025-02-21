import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  State<AttendanceHistoryScreen> createState() =>
      _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Attendance History"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("going_values")
            .where("userId", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .orderBy("timestamp", descending: true)
            .snapshots(),
        builder: (context, goingSnapshot) {
          if (goingSnapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (goingSnapshot.hasError) {
            return Text('Error: ${goingSnapshot.error}');
          } else {
            final List<QueryDocumentSnapshot> goingData =
                goingSnapshot.data!.docs;
            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("coming_values")
                  .where(
                    "userId",
                    isEqualTo: FirebaseAuth.instance.currentUser!.uid,
                  )
                  .orderBy("timestamp", descending: true)
                  .snapshots(),
              builder: (context, comingSnapshot) {
                if (comingSnapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (comingSnapshot.hasError) {
                  return Text('Error: ${comingSnapshot.error}');
                } else {
                  final List<QueryDocumentSnapshot> comingData =
                      comingSnapshot.data!.docs;

                  // Combine both going and coming attendance data
                  final List<QueryDocumentSnapshot> combinedData = [
                    ...goingData,
                    ...comingData
                  ];
                  combinedData.sort((a, b) {
                    final aTimestamp = (a['timestamp'] as Timestamp?)?.toDate();
                    final bTimestamp = (b['timestamp'] as Timestamp?)?.toDate();
                    return bTimestamp?.compareTo(aTimestamp ?? DateTime(0)) ??
                        0;
                  });

                  return ListView.builder(
                    itemCount: combinedData.length,
                    itemBuilder: (context, index) {
                      final document = combinedData[index];

                      final selectedValue =
                          document['selectedValue'] as String?;
                      final timestamp = document['timestamp'] as Timestamp?;

                      if (selectedValue == null || timestamp == null) {
                        return const ListTile(
                          title: Text('Data not available'),
                          subtitle: Text('Date: Unknown'),
                        );
                      }

                      final isGoingCollection =
                          document.reference.parent.id == 'going_values';

                      IconData icon;
                      Color iconColor;
                      String title;

                      if (isGoingCollection) {
                        icon = Icons.arrow_forward;
                        iconColor = Colors.green;
                        title = 'Going - $selectedValue';
                      } else {
                        icon = Icons.arrow_back;
                        iconColor = Colors.blue;
                        title = 'Coming - $selectedValue';
                      }

                      final date = timestamp.toDate();
                      final formattedDate =
                          DateFormat('yyyy-MM-dd HH:mm').format(date);

                      return ListTile(
                        title: Text(title),
                        subtitle: Text('Date: $formattedDate'),
                        leading: Icon(
                          icon,
                          color: iconColor,
                        ),
                      );
                    },
                  );
                }
              },
            );
          }
        },
      ),
    );
  }
}
