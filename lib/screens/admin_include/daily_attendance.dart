import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class DailyAttendance extends StatefulWidget {
  const DailyAttendance(List<int> list, {Key? key}) : super(key: key);

  @override
  State<DailyAttendance> createState() => _DailyAttendanceState();
}

class _DailyAttendanceState extends State<DailyAttendance> {
  Map<String, int> goingDestinationCounts = {};
  Map<String, int> comingDestinationCounts = {};
  int approvedCount = 0; // Added variable to count approved requests

  @override
  void initState() {
    super.initState();
    _calculateDestinationCounts();
  }

  @override
  void dispose() {
    // Cancel ongoing operations here
    super.dispose();
  }

  Future<void> _clearAndSaveData() async {
    if (goingDestinationCounts.isEmpty && comingDestinationCounts.isEmpty) {
      // No data available to clear
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
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
      'date': formattedDate, // Save date first
      'goingDestinationCounts': goingDestinationCounts,
      'comingDestinationCounts': comingDestinationCounts,
      'approvedCount': approvedCount,
    };

    try {
      // Generate a unique document ID for each save operation
      final newDocRef = attendanceHistoryCollection.doc();
      await newDocRef.set(dataToSave);

      // Clear the local state
      setState(() {
        goingDestinationCounts.clear();
        comingDestinationCounts.clear();
        approvedCount = 0;
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Data has been cleared and saved to attendance history."),
      ));
    } catch (e) {
      // Handle any errors that occur during saving
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error saving data: $e"),
      ));
    }
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

      final goingDocs = goingQuerySnapshot.docs;
      final comingDocs = comingQuerySnapshot.docs;

      goingDestinationCounts = _countDestinations(goingDocs);
      comingDestinationCounts = _countDestinations(comingDocs);

      // Calculate and add total counts for going and coming
      final int totalGoingCount =
          goingDestinationCounts.values.fold(0, (a, b) => a + b);
      final int totalComingCount =
          comingDestinationCounts.values.fold(0, (a, b) => a + b);
      goingDestinationCounts['Total'] = totalGoingCount;
      comingDestinationCounts['Total'] = totalComingCount;

      // Calculate and set the approved count
      approvedCount = await calculateApprovedCountForCurrentWeek();

      setState(() {}); // Trigger a rebuild to display the counts
    } catch (error) {
      // Handle any errors that occur during Firestore operations
      print("Error in _calculateDestinationCounts: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text("An error occurred while calculating destination counts."),
        ),
      );
    }
  }

  Future<int> calculateApprovedCountForCurrentWeek() async {
    final DateTime now = DateTime.now();
    final DateTime startOfWeek = now.subtract(Duration(days: now.weekday));
    final DateTime endOfWeek = startOfWeek.add(const Duration(days: 6));

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
        iconTheme: const IconThemeData(
          color: Colors.white, // Change the color of the leading icon
        ),
        title: const Text(
          'Destination Counts',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          ElevatedButton(
            onPressed: _clearAndSaveData,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red, // Set the background color to red
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                    10.0), // Set the border radius for a box shape
              ),
              padding: const EdgeInsets.all(
                  10.0), // Increase the padding to increase the button size
            ),
            child: const Icon(Icons.delete,
                color: Colors.white), // You can add an icon
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildDestinationCountSection(
              "Going Destination Counts (Current Day):",
              goingDestinationCounts,
            ),
            const SizedBox(height: 20),
            _buildDestinationCountSection(
              "Coming Destination Counts (Current Day):",
              comingDestinationCounts,
            ),
            const SizedBox(height: 20),
            _buildTotalCountSection(),
          ],
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Add your logic for the "Report Day" button here
                    // generatePDFForCurrentDayValues();
                    generatePDFForCurrentDayValues();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Customize button color
                  ),
                  child: const Text("Report Day",
                      style: TextStyle(color: Colors.white)),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Add your logic for the "Report History" button here
                    generatePDFForHistory();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // Customize button color
                  ),
                  child: const Text("Report History",
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ],
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

  Future<void> generatePDFForCurrentDayValues() async {
    final pdfDocument = PdfDocument();
    var status = await Permission.storage.request();

    final page = pdfDocument.pages.add();
    final graphics = page.graphics;

    // Add content to the PDF page
    graphics.drawString(
        'Report for Current Day', PdfStandardFont(PdfFontFamily.helvetica, 24),
        bounds: const Rect.fromLTWH(50, 50, 500, 30));

    // Add content for "Going" destination counts
    var goingDestinationCountsString =
        'Going Destination Counts (Current Day):\n';
    goingDestinationCounts.forEach((destination, count) {
      goingDestinationCountsString += '$destination: $count\n';
    });
    graphics.drawString(goingDestinationCountsString,
        PdfStandardFont(PdfFontFamily.helvetica, 12),
        bounds: const Rect.fromLTWH(50, 100, 500, 100));

    // Add content for "Coming" destination counts
    var comingDestinationCountsString =
        'Coming Destination Counts (Current Day):\n';
    comingDestinationCounts.forEach((destination, count) {
      comingDestinationCountsString += '$destination: $count\n';
    });
    graphics.drawString(comingDestinationCountsString,
        PdfStandardFont(PdfFontFamily.helvetica, 12),
        bounds: const Rect.fromLTWH(50, 250, 500, 100));

    // Add content for other values (you can customize this part)
    var otherValuesString = 'Other Values:\n';
    otherValuesString += 'Approved Seat Request: $approvedCount\n';

    graphics.drawString(
        otherValuesString, PdfStandardFont(PdfFontFamily.helvetica, 12),
        bounds: const Rect.fromLTWH(50, 400, 500, 100));

    try {
      if (status.isGranted) {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/report.pdf');
        final pdfBytes = pdfDocument.save();
        await file.writeAsBytes(await pdfBytes);

        // Share the PDF using the 'share_plus' package
        Share.shareFiles([file.path]);
      } else {
        // Handle permission denied or restricted by the user
      }
    } catch (e) {
      // Handle any exceptions that may occur while saving the file
      print("Error: $e");
    }

    pdfDocument.dispose();
  }

  Future<void> generatePDFForHistory() async {
    final pdfDocument = PdfDocument();
    var status = await Permission.storage.request();

    try {
      if (status.isGranted) {
        final attendanceHistoryCollection =
            FirebaseFirestore.instance.collection("attendance_history");
        final querySnapshot = await attendanceHistoryCollection.get();

        for (final doc in querySnapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          print('Document ID: ${doc.id}');

          var page = pdfDocument.pages.add();
          var graphics = page.graphics;

          final formattedDate = data['date'] as String;
          final goingDestinationCounts =
              Map<String, int>.from(data['goingDestinationCounts']);
          final comingDestinationCounts =
              Map<String, int>.from(data['comingDestinationCounts']);
          final approvedCount = data['approvedCount'] as int;

          // Add content to the PDF page
          graphics.drawString(
            'Report for $formattedDate',
            PdfStandardFont(PdfFontFamily.helvetica, 24),
            bounds: const Rect.fromLTWH(50, 50, 500, 30),
          );

          // Add content for "Going" destination counts
          var goingDestinationCountsString =
              'Going Destination Counts (Current Day):\n';
          goingDestinationCounts.forEach((destination, count) {
            goingDestinationCountsString += '$destination: $count\n';
          });
          graphics.drawString(
            goingDestinationCountsString,
            PdfStandardFont(PdfFontFamily.helvetica, 12),
            bounds: const Rect.fromLTWH(50, 100, 500, 100),
          );

          // Add content for "Coming" destination counts
          var comingDestinationCountsString =
              'Coming Destination Counts (Current Day):\n';
          comingDestinationCounts.forEach((destination, count) {
            comingDestinationCountsString += '$destination: $count\n';
          });
          graphics.drawString(
            comingDestinationCountsString,
            PdfStandardFont(PdfFontFamily.helvetica, 12),
            bounds: const Rect.fromLTWH(50, 250, 500, 100),
          );

          // Add content for other values
          var otherValuesString = 'Other Values:\n';
          if (approvedCount != null) {
            otherValuesString += 'Approved Seat Request: $approvedCount\n';
          }

          graphics.drawString(
            otherValuesString,
            PdfStandardFont(PdfFontFamily.helvetica, 12),
            bounds: const Rect.fromLTWH(50, 400, 500, 100),
          );

          // Add a page break between reports
          if (doc != querySnapshot.docs.last) {
            page = pdfDocument.pages.add();
            graphics = page.graphics;
          }
        }

        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/history_report.pdf');
        final pdfBytes = pdfDocument.save();
        await file.writeAsBytes(await pdfBytes);

        // Share the PDF using the 'share_plus' package
        Share.shareFiles([file.path]);
      } else {
        // Handle permission denied or restricted by the user
      }
    } catch (e) {
      // Handle any exceptions that may occur while generating or sharing the PDF
      print("Error: $e");
    }

    pdfDocument.dispose();
  }
}
