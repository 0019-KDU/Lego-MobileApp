import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:lego/admin_include/users_attendance_history.dart';

class DailyAttendancePage extends StatefulWidget {
  const DailyAttendancePage({super.key});

  @override
  State<DailyAttendancePage> createState() => _DailyAttendancePageState();
}

class _DailyAttendancePageState extends State<DailyAttendancePage> {
  Future<Map<String, Map<String, int>>> fetchAndCountExistsByWeek() async {
    CollectionReference selectedValueCollection =
        FirebaseFirestore.instance.collection('selected_values');

    QuerySnapshot querySnapshot = await selectedValueCollection.get();

    Map<String, Map<String, int>> existsCountMapByWeek = {};

    for (var doc in querySnapshot.docs) {
      String? existsValue = doc['selectedValue'];
      Timestamp? timestamp = doc['timestamp']; // Use Timestamp type

      if (existsValue != null && timestamp != null) {
        // Convert Timestamp to DateTime
        DateTime dateTime = timestamp.toDate();

        // Calculate the week starting from Monday
        DateTime startOfWeek =
            dateTime.subtract(Duration(days: dateTime.weekday - 1));
        DateTime endOfWeek = startOfWeek.add(Duration(days: 6));

        String week = '${formatDate(startOfWeek, [
              yyyy,
              '-',
              mm,
              ' ',
              dd
            ])} - ${formatDate(endOfWeek, [yyyy, '-', mm, ' ', dd])}';

        if (!existsCountMapByWeek.containsKey(week)) {
          existsCountMapByWeek[week] = {};
        }

        existsCountMapByWeek[week]?[existsValue] =
            (existsCountMapByWeek[week]?[existsValue] ?? 0) + 1;
      }
    }

    return existsCountMapByWeek;
  }

  Map<String, Map<String, int>> getCurrentWeekData(
      Map<String, Map<String, int>> data) {
    // Get the current week's data
    DateTime now = DateTime.now();
    DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    DateTime endOfWeek = startOfWeek.add(Duration(days: 6));

    String currentWeek = '${formatDate(startOfWeek, [
          yyyy,
          '-',
          mm,
          ' ',
          dd
        ])} - ${formatDate(endOfWeek, [yyyy, '-', mm, ' ', dd])}';

    return {currentWeek: data[currentWeek] ?? {}};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: fetchAndCountExistsByWeek(),
        builder:
            (context, AsyncSnapshot<Map<String, Map<String, int>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            Map<String, Map<String, int>> existsCountMapByWeek = snapshot.data!;

            // Filter data for the current week
            Map<String, Map<String, int>> currentWeekData =
                getCurrentWeekData(existsCountMapByWeek);

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: currentWeekData.length,
                    itemBuilder: (context, index) {
                      String week = currentWeekData.keys.elementAt(index);
                      Map<String, int> existsCountMap = currentWeekData[week]!;

                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
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
                                String existsValue =
                                    existsCountMap.keys.elementAt(index);
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
                ),
                ElevatedButton(
                  onPressed: () async {
                    // Fetch the previous week's data
                    Map<String, Map<String, int>> previousWeekData =
                        await fetchAndCountExistsByPreviousWeek();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PreviousWeekAttendancePage(
                          previousWeekData: previousWeekData,
                        ),
                      ),
                    );
                  },
                  child: const Text('View Previous Week Attendance'),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Future<Map<String, Map<String, int>>>
      fetchAndCountExistsByPreviousWeek() async {
    CollectionReference selectedValueCollection =
        FirebaseFirestore.instance.collection('selected_values');

    QuerySnapshot querySnapshot = await selectedValueCollection.get();

    Map<String, Map<String, int>> existsCountMapByWeek = {};

    for (var doc in querySnapshot.docs) {
      String? existsValue = doc['selectedValue'];
      Timestamp? timestamp = doc['timestamp']; // Use Timestamp type

      if (existsValue != null && timestamp != null) {
        // Convert Timestamp to DateTime
        DateTime dateTime = timestamp.toDate();

        // Calculate the week starting from Monday
        DateTime startOfWeek =
            dateTime.subtract(Duration(days: dateTime.weekday - 1));
        DateTime endOfWeek = startOfWeek.add(Duration(days: 6));

        // Check if the week is in the previous week
        DateTime now = DateTime.now();
        DateTime startOfCurrentWeek =
            now.subtract(Duration(days: now.weekday - 1));

        if (startOfWeek.isBefore(startOfCurrentWeek)) {
          String week = '${formatDate(startOfWeek, [
                yyyy,
                '-',
                mm,
                ' ',
                dd
              ])} - ${formatDate(endOfWeek, [yyyy, '-', mm, ' ', dd])}';

          if (!existsCountMapByWeek.containsKey(week)) {
            existsCountMapByWeek[week] = {};
          }

          existsCountMapByWeek[week]?[existsValue] =
              (existsCountMapByWeek[week]?[existsValue] ?? 0) + 1;
        }
      }
    }

    return existsCountMapByWeek;
  }
}
