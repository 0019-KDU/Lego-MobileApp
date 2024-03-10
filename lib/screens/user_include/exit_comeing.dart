import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:lego/screens/user_include/attendance_history.dart';

class ComeGoing extends StatefulWidget {
  const ComeGoing(List<int> list, {super.key});

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
      setState(() {
        if (tripType == 'Going') {
          selectedGoingValue = existsSelected;
        } else if (tripType == 'Coming') {
          selectedComingValue = existsSelected;
        }
      });
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
              if (tripType == 'Going') {
                selectedGoingValue = selectedValue;
              } else if (tripType == 'Coming') {
                selectedComingValue = selectedValue;
              }
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
    _fetchSelectedValues(); // Call a method to fetch and set selected values
  }

  String? selectedGoingValue; // Variable for "Suriyawawa To Home"
  String? selectedComingValue; // Variable for "Home To Suriyawawa"
  bool userHasSelected = false;
// Modify _buildSelectedValuesColumn to set userHasSelected flag
  Widget _buildSelectedValuesColumn(String goingValue, String comingValue) {
    return Column(
      children: [
        if (goingValue.isNotEmpty || comingValue.isNotEmpty)
          Column(
            children: [
              _buildSelectedValueText("Suriyawawa To Home", goingValue),
              _buildSelectedValueText("Home To Suriyawawa", comingValue),
            ],
          ),
        if (goingValue.isEmpty && comingValue.isEmpty)
          _buildNoDataFoundWidget(),
      ],
    );
  }

  Widget _buildErrorWidget(dynamic error) {
    return Center(
      child: Text('Error: $error'),
    );
  }

  Widget _buildSelectedValueText(String label, String value) {
    return Text(
      "$label: $value",
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildNoDataFoundWidget() {
    return const Center(
      child: Text('No data found for the current day.'),
    );
  }

  Future<void> _fetchSelectedValues() async {
    final values = await _getSelectedValuesForCurrentDay();
    if (values != null) {
      setState(() {
        selectedGoingValue = values['going'];
        selectedComingValue = values['coming'];
      });
    }
  }

  Future<Map<String, dynamic>?> _getSelectedValuesForCurrentDay() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        final goingCollection =
            FirebaseFirestore.instance.collection("going_values");
        final comingCollection =
            FirebaseFirestore.instance.collection("coming_values");

        DateTime currentDate = DateTime.now();
        Timestamp startOfDay = Timestamp.fromDate(
            DateTime(currentDate.year, currentDate.month, currentDate.day));

        print("startOfDay: $startOfDay");
        print("currentDate: $currentDate");

        final goingSnapshot = await goingCollection
            .where("userId", isEqualTo: currentUser.uid)
            .where("timestamp", isGreaterThanOrEqualTo: startOfDay)
            .where("timestamp",
                isLessThan: Timestamp.fromDate(
                    currentDate.add(const Duration(days: 1))))
            .get();

        final comingSnapshot = await comingCollection
            .where("userId", isEqualTo: currentUser.uid)
            .where("timestamp", isGreaterThanOrEqualTo: startOfDay)
            .where("timestamp",
                isLessThan: Timestamp.fromDate(
                    currentDate.add(const Duration(days: 1))))
            .get();

        if (goingSnapshot.docs.isNotEmpty || comingSnapshot.docs.isNotEmpty) {
          Map<String, dynamic> values = {};

          if (goingSnapshot.docs.isNotEmpty) {
            values['going'] = goingSnapshot.docs.first.data()['selectedValue'];
          }

          if (comingSnapshot.docs.isNotEmpty) {
            values['coming'] =
                comingSnapshot.docs.first.data()['selectedValue'];
          }

          print("Retrieved values: $values");
          return values;
        } else {
          print("No documents found for the current day.");
        }
      }
    } catch (e) {
      print("Error in _getSelectedValuesForCurrentDay: $e");
    }

    return null;
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
          'Jouerny',
          style: TextStyle(
            color: Colors.white, // Change the color of the title text
          ),
        ),
      ),
      body: Form(
        key: _fromkey,
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            Container(
              margin: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                    child: RadioListTile(
                      contentPadding: const EdgeInsets.all(5.0),
                      value: 'Going',
                      groupValue: tripType,
                      dense: true,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                      tileColor: Colors.black12,
                      title: const Text(
                        "Suriyawawa To Home",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          tripType = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 3,
                  ),
                  Expanded(
                    child: RadioListTile(
                      contentPadding: const EdgeInsets.all(5.0),
                      value: 'Coming',
                      groupValue: tripType,
                      dense: true,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                      tileColor: Colors.black12,
                      title: const Text(
                        "Home To Suriyawawa",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          tripType = value;
                        });
                      },
                    ),
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
                      SizedBox(
                        child: ElevatedButton(
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
                      ),
                      SizedBox(
                        child: ElevatedButton(
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
            const SizedBox(
              height: 60.0,
            ),
            Column(
              children: [
                // New widget to display selected values
                if (selectedGoingValue != null || selectedComingValue != null)
                  _buildSelectedValuesColumn(
                    selectedGoingValue ?? 'Not selected',
                    selectedComingValue ?? 'Not selected',
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
          ],
        ),
      ),
    );
  }
}
