import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AttendanceHistory extends StatefulWidget {
  const AttendanceHistory({Key? key}) : super(key: key);

  @override
  State<AttendanceHistory> createState() => _AttendanceHistoryState();
}

class _AttendanceHistoryState extends State<AttendanceHistory> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Define variables for pagination
  int documentsPerPage = 10;
  DocumentSnapshot? lastVisibleDocument;
  List<DataRow> dataRows = [];

  Future<String?> getCurrentUserUid() async {
    User? user = _auth.currentUser;
    if (user != null) {
      return user.uid;
    }
    return null; // If the user is not logged in
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Attendance History',
          style: TextStyle(fontSize: 20.0), // Increase font size for title
        ),
      ),
      body: FutureBuilder<String?>(
        future: getCurrentUserUid(),
        builder: (context, uidSnapshot) {
          if (uidSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (uidSnapshot.hasError) {
            return Text(
              'Error: ${uidSnapshot.error}',
              style: const TextStyle(
                  fontSize: 16.0), // Increase font size for error text
            );
          }
          final currentUserUid = uidSnapshot.data;

          if (currentUserUid == null) {
            return const Center(
              child: Text(
                'User not logged in.',
                style:
                    TextStyle(fontSize: 16.0), // Increase font size for message
              ),
            );
          }

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("selected_values")
                .where("userId",
                    isEqualTo: currentUserUid) // Filter by userId (UID)
                .orderBy("timestamp", descending: true) // Sort by timestamp
                .limit(documentsPerPage) // Load the first batch of documents
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (snapshot.hasError) {
                return Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(
                      fontSize: 16.0), // Increase font size for error text
                );
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text(
                    'No attendance data available for the current user.',
                    style: TextStyle(
                        fontSize: 16.0), // Increase font size for message
                  ),
                );
              }

              // Extract "selectedValue" and "timestamp" from documents
              List<String> selectedValues = [];
              List<Timestamp> timestampList = [];

              if (snapshot.hasData && snapshot.data != null) {
                selectedValues = snapshot.data!.docs
                    .map((doc) => doc["selectedValue"].toString())
                    .toList();

                timestampList = snapshot.data!.docs
                    .map((doc) => doc["timestamp"] as Timestamp?)
                    .where((timestamp) =>
                        timestamp != null) // Filter out null timestamps
                    .map(
                        (timestamp) => timestamp!) // Unwrap non-null timestamps
                    .toList();
              }

              // Ensure that the lengths match (selectedValues and timestampList)
              assert(selectedValues.length == timestampList.length);

              // Create a list of DataRow widgets for the DataTable
              List<DataRow> dataRows =
                  selectedValues.asMap().entries.map((entry) {
                int index = entry.key;
                String selectedValue = entry.value;

                // Check if the index is valid for timestampList
                if (index >= 0 && index < timestampList.length) {
                  DateTime timestamp = timestampList[index].toDate();

                  // Format the timestamp as a human-readable string
                  String formattedTimestamp =
                      DateFormat('MMM d, yyyy HH:mm:ss').format(timestamp);

                  return DataRow(
                    cells: [
                      DataCell(
                        Text(
                          selectedValue,
                          style: const TextStyle(
                              fontSize:
                                  18.0), // Increase font size for selectedValue
                        ),
                      ),
                      DataCell(
                        Text(
                          formattedTimestamp,
                          style: const TextStyle(
                              fontSize:
                                  18.0), // Increase font size for timestamp
                        ),
                      ),
                    ],
                  );
                }

                return const DataRow(cells: []);
              }).toList();

              return Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(
                            label: Text(
                              'Selected Value',
                              style: TextStyle(
                                  fontSize:
                                      18.0), // Increase font size for DataColumn label
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Timestamp',
                              style: TextStyle(
                                  fontSize:
                                      18.0), // Increase font size for DataColumn label
                            ),
                          ),
                        ],
                        rows: dataRows,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Load the next page of data
                      loadMoreData(currentUserUid);
                    },
                    child: const Text("Load More"),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Future<void> loadMoreData(String? userId) async {
    final query = FirebaseFirestore.instance
        .collection("selected_values")
        .where("userId", isEqualTo: userId)
        .orderBy("timestamp", descending: true)
        .limit(documentsPerPage);

    if (lastVisibleDocument != null) {
      query.startAfterDocument(lastVisibleDocument!);
    }

    final newSnapshot = await query.get();

    // Update the last visible document for the next load
    if (newSnapshot.docs.isNotEmpty) {
      lastVisibleDocument = newSnapshot.docs.last;
    }

    // Add the new data to the existing list
    final newData = newSnapshot.docs.map((doc) {
      final selectedValue = doc["selectedValue"].toString();
      final timestamp = doc["timestamp"] as Timestamp?;

      // Check if the timestamp is not null before casting
      final formattedTimestamp = timestamp != null
          ? DateFormat('MMM d, yyyy HH:mm:ss').format(timestamp.toDate())
          : "N/A"; // Provide a default value or handle the null case

      return DataRow(
        cells: [
          DataCell(
            Text(
              selectedValue,
              style: const TextStyle(fontSize: 18.0),
            ),
          ),
          DataCell(
            Text(
              formattedTimestamp,
              style: const TextStyle(fontSize: 18.0),
            ),
          ),
        ],
      );
    }).toList();

    // Update the dataRows list with the new data
    dataRows.addAll(newData);

    // Trigger a rebuild of the widget
    setState(() {});
  }
}
