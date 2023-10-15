import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ComeGoing extends StatefulWidget {
  const ComeGoing(List<int> list, {Key? key}) : super(key: key);

  @override
  _ComeGoingState createState() => _ComeGoingState();
}

class _ComeGoingState extends State<ComeGoing> {
  Map<String, int> goingDestinationCounts = {};
  Map<String, int> comingDestinationCounts = {};
  int approvedCount = 0; // Added variable to count approved requests

  @override
  void initState() {
    super.initState();
    _calculateDestinationCounts();
  }

  Future<void> _clearAndSaveData() async {
    if (goingDestinationCounts.isEmpty && comingDestinationCounts.isEmpty) {
      // No data available to clear
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("No data to clear."),
      ));
      return;
    }

    // Clear the current data from the collections
    final goingValuesCollection =
        FirebaseFirestore.instance.collection("going_values");
    final comingValuesCollection =
        FirebaseFirestore.instance.collection("coming_values");
    final seatRequestsCollection =
        FirebaseFirestore.instance.collection("seat_requests");

    await _clearCollection(goingValuesCollection);
    await _clearCollection(comingValuesCollection);
    await _clearCollection(seatRequestsCollection);

    // Save the current data to a new document in the attendance history collection
    final attendanceHistoryCollection =
        FirebaseFirestore.instance.collection("attendance_history");
    final DateTime now = DateTime.now();
    final String formattedDate = DateFormat('yyyy-MM-dd').format(now);

    final Map<String, dynamic> dataToSave = {
      'goingDestinationCounts': goingDestinationCounts,
      'comingDestinationCounts': comingDestinationCounts,
      'approvedCount': approvedCount,
    };

    // Generate a unique document ID for each save operation
    final newDocRef = attendanceHistoryCollection.doc();
    await newDocRef.set(dataToSave);

    // Clear the local state
    setState(() {
      goingDestinationCounts.clear();
      comingDestinationCounts.clear();
      approvedCount = 0;
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Data has been cleared and saved to attendance history."),
    ));
  }

  Future<void> _clearCollection(CollectionReference collection) async {
    QuerySnapshot querySnapshot = await collection.get();
    for (QueryDocumentSnapshot doc in querySnapshot.docs) {
      await doc.reference.delete();
    }
  }

  Future<void> _calculateDestinationCounts() async {
    try {
      final currentTime = DateTime.now();
      final startOfDay =
          DateTime(currentTime.year, currentTime.month, currentTime.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final goingValuesCollection =
          FirebaseFirestore.instance.collection("going_values");
      final comingValuesCollection =
          FirebaseFirestore.instance.collection("coming_values");

      final goingQuerySnapshot = await goingValuesCollection
          .where("timestamp",
              isGreaterThanOrEqualTo: startOfDay, isLessThan: endOfDay)
          .get();
      final comingQuerySnapshot = await comingValuesCollection
          .where("timestamp",
              isGreaterThanOrEqualTo: startOfDay, isLessThan: endOfDay)
          .get();

      if (goingQuerySnapshot.docs.isNotEmpty &&
          comingQuerySnapshot.docs.isNotEmpty) {
        final List<DocumentSnapshot> goingDocs = goingQuerySnapshot.docs;
        final List<DocumentSnapshot> comingDocs = comingQuerySnapshot.docs;

        goingDestinationCounts = _countDestinations(goingDocs);
        comingDestinationCounts = _countDestinations(comingDocs);

        // Calculate and add total counts
        final int totalGoingCount =
            goingDestinationCounts.values.fold(0, (a, b) => a + b);
        final int totalComingCount =
            comingDestinationCounts.values.fold(0, (a, b) => a + b);
        goingDestinationCounts['Total'] = totalGoingCount;
        comingDestinationCounts['Total'] = totalComingCount;

        // Calculate and set the approved count
        approvedCount = await calculateApprovedCountForCurrentWeek();

        setState(() {}); // Trigger a rebuild to display the counts
      } else {
        // Handle the case where no data is found
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("No data found for the current day."),
        ));
      }
    } catch (error) {
      // Handle any errors that occur during Firestore operations
      print("Error in _calculateDestinationCounts: $error");
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content:
            Text("An error occurred while calculating destination counts."),
      ));
    }
  }

  Future<int> calculateApprovedCountForCurrentWeek() async {
    final DateTime now = DateTime.now();
    final DateTime startOfWeek = now.subtract(Duration(days: now.weekday));
    final DateTime endOfWeek = startOfWeek.add(Duration(days: 6));

    print("Start of the week: $startOfWeek");
    print("End of the week: $endOfWeek");

    final snapshot = await FirebaseFirestore.instance
        .collection('request_history')
        .where("status", isEqualTo: "approved")
        .where("timestamp", isGreaterThanOrEqualTo: startOfWeek)
        .where("timestamp", isLessThanOrEqualTo: endOfWeek)
        .get();

    int totalApprovedSeats = 0;

    for (final doc in snapshot.docs) {
      final status = doc.get("status") as String?;
      final requestedSeats = doc.get("requestedSeats") as int?;

      if (status == "approved" && requestedSeats != null) {
        totalApprovedSeats += requestedSeats;
      }
    }

    print("Total approved seats for the current week: $totalApprovedSeats");

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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Destination Counts'),
        actions: [
          IconButton(
            icon: Icon(Icons.clear),
            onPressed: _clearAndSaveData,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildDestinationCountSection(
              "Going Destination Counts (Current Week):",
              goingDestinationCounts,
            ),
            const SizedBox(height: 20),
            _buildDestinationCountSection(
              "Coming Destination Counts (Current Week):",
              comingDestinationCounts,
            ),
            const SizedBox(height: 20),
            _buildTotalCountSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildDestinationCountSection(
    String title,
    Map<String, int> destinationCounts,
  ) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Column(
              children: destinationCounts.entries.map((entry) {
                return _buildDestinationCountCard(entry.key, entry.value);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalCountSection() {
    final totalGoingCount = goingDestinationCounts['Total'] ?? 0;
    final totalComingCount = comingDestinationCounts['Total'] ?? 0;
    final grandTotal = totalGoingCount + totalComingCount + approvedCount;

    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Total Destination Counts:",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            _buildTotalCountCard("Going Total", totalGoingCount),
            _buildTotalCountCard("Coming Total", totalComingCount),
            _buildTotalCountCard(
                "Approved Seat Request", approvedCount), // Added approved count
            const Divider(),
            _buildTotalCountCard("Grand Total", grandTotal),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalCountCard(String title, int count) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      trailing: Text(
        "Count: $count",
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildDestinationCountCard(String destination, int count) {
    return ListTile(
      title: Text(
        destination,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      trailing: Text(
        "Count: $count",
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}
