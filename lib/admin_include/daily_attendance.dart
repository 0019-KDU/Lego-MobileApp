import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ComeGoing extends StatefulWidget {
  const ComeGoing(List<int> list, {Key? key}) : super(key: key);

  @override
  _ComeGoingState createState() => _ComeGoingState();
}

class _ComeGoingState extends State<ComeGoing> {
  Map<String, int> goingDestinationCounts = {};
  Map<String, int> comingDestinationCounts = {};

  @override
  void initState() {
    super.initState();
    _calculateDestinationCounts();
  }

  Future<void> _calculateDestinationCounts() async {
    final currentTime = DateTime.now();
    final startOfWeek =
        currentTime.subtract(Duration(days: currentTime.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    final goingValuesCollection =
        FirebaseFirestore.instance.collection("going_values");
    final comingValuesCollection =
        FirebaseFirestore.instance.collection("coming_values");

    final goingQuerySnapshot = await goingValuesCollection
        .where("timestamp",
            isGreaterThanOrEqualTo: startOfWeek, isLessThanOrEqualTo: endOfWeek)
        .get();
    final comingQuerySnapshot = await comingValuesCollection
        .where("timestamp",
            isGreaterThanOrEqualTo: startOfWeek, isLessThanOrEqualTo: endOfWeek)
        .get();

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

    setState(() {}); // Trigger a rebuild to display the counts
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
        title: const Text('Destination Counts'),
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
    final grandTotal = totalGoingCount + totalComingCount;

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
