import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lego/components/app_styles.dart';

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
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.only(top: 18, left: 24, right: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.indigo,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildDestinationCountSection(
                "Going Destination Counts (Current Week):",
                goingDestinationCounts,
              ),
              const SizedBox(height: 20),
              _buildDestinationCountSection(
                "Coming Destination Counts (Current Week):",
                comingDestinationCounts,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDestinationCountSection(
    String title,
    Map<String, int> destinationCounts,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: ralewayStyle.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          itemCount: destinationCounts.length,
          itemBuilder: (context, index) {
            final entry = destinationCounts.entries.elementAt(index);
            return _buildDestinationCountCard(entry.key, entry.value);
          },
        ),
      ],
    );
  }

  Widget _buildDestinationCountCard(String destination, int count) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              destination,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Count: $count",
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
