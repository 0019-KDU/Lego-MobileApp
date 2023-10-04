import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ComeGoing extends StatefulWidget {
  const ComeGoing(List<int> list, {Key? key}) : super(key: key);

  @override
  State<ComeGoing> createState() => _ComeGoingState();
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
    final goingValuesCollection =
        FirebaseFirestore.instance.collection("going_values");
    final comingValuesCollection =
        FirebaseFirestore.instance.collection("coming_values");

    final goingQuerySnapshot = await goingValuesCollection.get();
    final comingQuerySnapshot = await comingValuesCollection.get();

    final List<DocumentSnapshot> goingDocs = goingQuerySnapshot.docs;
    final List<DocumentSnapshot> comingDocs = comingQuerySnapshot.docs;

    goingDestinationCounts = _countDestinations(goingDocs);
    comingDestinationCounts = _countDestinations(comingDocs);

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Going Destination Counts:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            for (var entry in goingDestinationCounts.entries)
              Text("${entry.key}: ${entry.value}"),
            const SizedBox(height: 20),
            const Text(
              "Coming Destination Counts:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            for (var entry in comingDestinationCounts.entries)
              Text("${entry.key}: ${entry.value}"),
          ],
        ),
      ),
    );
  }
}
