import 'package:flutter/material.dart';

class PreviousWeekAttendancePage extends StatelessWidget {
  final Map<String, Map<String, int>> previousWeekData;

  const PreviousWeekAttendancePage({super.key, required this.previousWeekData});

  @override
  Widget build(BuildContext context) {
    // Sort the keys (weeks) in descending order
    final sortedWeeks = previousWeekData.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Previous Week Attendance'),
      ),
      body: ListView.builder(
        itemCount: sortedWeeks.length,
        itemBuilder: (context, index) {
          String week = sortedWeeks[index];
          Map<String, int> existsCountMap = previousWeekData[week]!;

          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                ListTile(
                  title: Text(
                    'Week: $week',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: existsCountMap.length,
                  itemBuilder: (context, index) {
                    String existsValue = existsCountMap.keys.elementAt(index);
                    int count = existsCountMap[existsValue]!;

                    return ListTile(
                      title: Text(existsValue),
                      trailing: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Count: $count',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
