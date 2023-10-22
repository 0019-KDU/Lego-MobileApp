import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lego/user_include/attendance_history.dart';

class ComeGoing extends StatefulWidget {
  const ComeGoing({super.key});

  @override
  State<ComeGoing> createState() => _ComeGoingState();
}

class _ComeGoingState extends State<ComeGoing> {
  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _storeSelectedValue() async {
    try {
      if (tripType == null) {
        _showDialog(
            "Warning", "Please select a trip type (Going or Coming) first.");
        return;
      }

      if (_fromkey.currentState!.validate()) {
        final currentUser = FirebaseAuth.instance.currentUser;

        if (currentUser != null) {
          final selectedValuesCollection = FirebaseFirestore.instance
              .collection(
                  tripType == 'Going' ? "going_values" : "coming_values");

          final existingValueDoc = await selectedValuesCollection
              .where("userId", isEqualTo: currentUser.uid)
              .get();

          if (existsSelected == null) {
            _showDialog("Error", "Please select a value from the dropdown.");
            return;
          }

          if (existingValueDoc.docs.isNotEmpty) {
            _showDialog("Warning", "You have already added a value.");
            return;
          }

          // User hasn't saved a value, proceed to save
          await selectedValuesCollection.add({
            "userId": currentUser.uid,
            "selectedValue": existsSelected,
            "timestamp": FieldValue.serverTimestamp(),
          });

          _showDialog("Success", "Value successfully saved.");
        }
      }
    } catch (e) {
      print("Error in _storeSelectedValue: $e");
      _showDialog("Error", "An error occurred while processing your request.");
    }
  }

  Future<void> _editSelectedValue() async {
    try {
      if (tripType == null) {
        _showDialog(
            "Warning", "Please select a trip type (Going or Coming) first.");
        return;
      }

      String? selectedValue = existsSelected ??
          _existPoints
              .first; // Initialize with the current value or the first item

      selectedValue = await showDialog<String>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Edit Value"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButton<String>(
                  value: selectedValue,
                  items: _existPoints.map((value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    selectedValue = newValue;
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(null); // Cancel the dialog
                },
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context)
                      .pop(selectedValue); // Save the selected value
                },
                child: const Text("Save"),
              ),
            ],
          );
        },
      );

      if (selectedValue != null && selectedValue != existsSelected) {
        final currentUser = FirebaseAuth.instance.currentUser;

        if (currentUser != null) {
          final selectedValuesCollection = FirebaseFirestore.instance
              .collection(
                  tripType == 'Going' ? "going_values" : "coming_values");

          final existingValueDoc = await selectedValuesCollection
              .where("userId", isEqualTo: currentUser.uid)
              .get();

          if (existingValueDoc.docs.isNotEmpty) {
            final docId = existingValueDoc.docs.first.id;
            await selectedValuesCollection.doc(docId).update({
              "selectedValue": selectedValue,
              "timestamp": FieldValue.serverTimestamp(),
            });

            setState(() {
              existsSelected = selectedValue;
            });

            _showDialog("Success", "Value successfully edited.");
          }
        }
      }
    } catch (e) {
      print("Error in _editSelectedValue: $e");
      _showDialog("Error", "An error occurred while processing your request.");
    }
  }

  String? tripType;
  late GlobalKey<FormState> _fromkey;
  String? existsSelected;
  String? message = "";
  final List<String> _existPoints = <String>[
    'Kaduwela',
    'Kothalawala',
    'Athurugiriya',
    'Kottawa',
    'Kahathuduwa',
    'Gelanigama',
    'Dodangoda',
    'Welipanna',
    'Kurundugaha',
    'Baddegama',
    'Pinnaduwa',
    'Imaduwa',
    'Kokmaduwa',
    'Godagama',
    'Palatuwa',
    'Kapuduwa',
    'Aparekka',
    'beliatta',
    'bedigama',
    'kasagala',
    'Angunukolapelessa',
    'Barawakumbuka',
    'Sooriyawewa',
  ];

  //bool isDropdownVisible = false;
  bool isDropdownVisible = false;

  void toggleDropdown() {
    setState(() {
      isDropdownVisible = !isDropdownVisible;
    });
  }

  @override
  void initState() {
    super.initState();
    _fromkey = GlobalKey<FormState>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
      ),
      body: Form(
        key: _fromkey,
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(10),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [],
              ),
            ),
            Container(
              margin: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio(
                        value: 'Going',
                        groupValue: tripType,
                        onChanged: (value) {
                          setState(() {
                            tripType = value;
                          });
                        },
                      ),
                      const Text(
                        'S-H',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Radio(
                        value: 'Coming',
                        groupValue: tripType,
                        onChanged: (value) {
                          setState(() {
                            tripType = value;
                          });
                        },
                      ),
                      const Text('H-S',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isDropdownVisible = !isDropdownVisible;
                          });
                        },
                        child: Icon(
                          isDropdownVisible
                              ? Icons.arrow_drop_up
                              : Icons.arrow_drop_down,
                          size: 30,
                          color: Colors.black,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            isDropdownVisible = !isDropdownVisible;
                          });
                        },
                        child: Text(
                          existsSelected ?? "Choose your Exit",
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade400,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32.0),
                          ),
                          minimumSize: const Size(90, 45),
                        ),
                        onPressed: _storeSelectedValue,
                        child: const Text("Go"),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32.0),
                          ),
                          minimumSize: const Size(90, 45),
                        ),
                        onPressed: _editSelectedValue,
                        child: const Text("Edit"),
                      ),
                    ],
                  ),
                  if (isDropdownVisible)
                    SizedBox(
                      height: 150,
                      child: ListView.builder(
                        itemCount: _existPoints.length,
                        itemBuilder: (context, index) {
                          final value = _existPoints[index];
                          return ListTile(
                            title: Text(value),
                            onTap: () {
                              setState(() {
                                existsSelected = value;
                                isDropdownVisible = false;
                              });
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.all(30),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade400,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32.0),
                  ),
                  minimumSize: const Size(90, 45),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AttendanceHistoryScreen(),
                    ),
                  );
                },
                child: const Text("History"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
