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
    if (_fromkey.currentState!.validate()) {
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        final selectedValuesCollection = FirebaseFirestore.instance
            .collection(tripType == 'Going' ? "going_values" : "coming_values");

        final existingValueDoc = await selectedValuesCollection
            .where("userId", isEqualTo: currentUser.uid)
            .get();

        if (existsSelected == null) {
          _showDialog("Error", "Please select a value from the dropdown.");
          return;
        }

        if (existingValueDoc.docs.isNotEmpty) {
          // User has already saved a value, check time difference
          final lastTimestamp =
              existingValueDoc.docs.first.get("timestamp") as Timestamp;
          final currentTime = Timestamp.now();

          // Calculate the difference in seconds
          final timeDifference = currentTime.seconds - lastTimestamp.seconds;
          const requiredTimeDifference = 1 * 24 * 60 * 60; // 1 days in seconds

          if (timeDifference < requiredTimeDifference) {
            _showDialog("Warning", "You can add a new value after a few days.");
            return;
          }
        }

        // User hasn't saved a value or enough time has passed, proceed to save
        await selectedValuesCollection.add({
          "userId": currentUser.uid,
          "selectedValue": existsSelected,
          "timestamp": FieldValue.serverTimestamp(),
        });

        _showDialog("Success", "Value successfully saved.");
      }
    }
  }

  Future<void> _editSelectedValue() async {
    try {
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
      body: Form(
        key: _fromkey,
        child: ListView(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 18, left: 24, right: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
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
            ),
            Container(
              width: 550,
              height: 350,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
                borderRadius: BorderRadius.circular(16),
              ),
              margin: const EdgeInsets.all(30),
              child: Column(
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Radio(
                      value: 'Going',
                      groupValue: tripType,
                      onChanged: (value) {
                        setState(() {
                          tripType = value;
                        });
                      },
                    ),
                    const Text('Going'),
                    Radio(
                      value: 'Coming',
                      groupValue: tripType,
                      onChanged: (value) {
                        setState(() {
                          tripType = value;
                        });
                      },
                    ),
                    const Text('Coming'),
                  ]),
                  const SizedBox(
                    height: 10,
                  ),
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
                      const SizedBox(
                        width: 8,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            isDropdownVisible = !isDropdownVisible;
                          });
                        },
                        child: Container(
                          alignment: Alignment.center,
                          child: Text(
                            existsSelected ?? "Choose your Exist",
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.green.shade400,
                          shadowColor: Colors.greenAccent,
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32.0),
                          ),
                          minimumSize: const Size(90, 45),
                        ),
                        onPressed: _storeSelectedValue,
                        child: const Text("Going"),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.blue,
                          shadowColor: Colors.greenAccent,
                          elevation: 3,
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
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.green.shade400,
                shadowColor: Colors.greenAccent,
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32.0),
                ),
                minimumSize: const Size(90, 45),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AttendanceHistoryScreen()),
                );
              },
              child: const Text("History"),
            ),
          ],
        ),
      ),
    );
  }
}
