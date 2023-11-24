import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EditInformation extends StatefulWidget {
  const EditInformation({Key? key}) : super(key: key);

  @override
  State<EditInformation> createState() => _EditInformationState();
}

class _EditInformationState extends State<EditInformation> {
  TextEditingController _firstEditingController = TextEditingController();
  TextEditingController _secondEditingController = TextEditingController();
  String? previousFirstPrice;
  String? previousSecondPrice;

  // Function to handle the submission to the database for the first text box
  void submitFirstToDatabase(String firstPrice) {
    // Access Firestore instance
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Update the price in the "cost" document in the "permant" collection
    firestore.collection('permant').doc('cost').update({
      'price': firstPrice,
      'timestamp': FieldValue.serverTimestamp(),
    }).then((value) {
      // Success
      showSuccessDialog();
      // Set the previously submitted first price
      setState(() {
        previousFirstPrice = firstPrice;
      });
    }).catchError((error) {
      // Handle errors
      showErrorDialog(error.toString());
    });
  }

  // Function to handle the submission to the database for the second text box
  void submitSecondToDatabase(String secondPrice) {
    // Access Firestore instance
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Update the price in the "cost" document in the "non_permant" collection
    firestore.collection('non_permant').doc('cost').update({
      'price': secondPrice,
      'timestamp': FieldValue.serverTimestamp(),
    }).then((value) {
      // Success
      showSuccessDialog();
      // Set the previously submitted second price
      setState(() {
        previousSecondPrice = secondPrice;
      });
    }).catchError((error) {
      // Handle errors
      showErrorDialog(error.toString());
    });
  }

  // Function to show a success dialog
  void showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text('Prices submitted successfully.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Function to show an error dialog
  void showErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content:
              Text('Error submitting prices to the database: $errorMessage'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    // Fetch the previously submitted prices when the page is initialized
    fetchPreviousPrices();
  }

  // Function to fetch the previously submitted prices
  void fetchPreviousPrices() {
    // Access Firestore instance
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Fetch the "cost" document in the "permant" collection
    firestore
        .collection('permant')
        .doc('cost')
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        setState(() {
          // Set the previously submitted first price
          previousFirstPrice = documentSnapshot['price'];
        });
      }
    }).catchError((error) {
      print('Error fetching previous first price: $error');
    });

    // Fetch the "cost" document in the "non_permant" collection
    firestore
        .collection('non_permant')
        .doc('cost')
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        setState(() {
          // Set the previously submitted second price
          previousSecondPrice = documentSnapshot['price'];
        });
      }
    }).catchError((error) {
      print('Error fetching previous second price: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // WillPopScope to handle back button press
      onWillPop: () async {
        // Clear the previously submitted prices when navigating back
        setState(() {
          previousFirstPrice = null;
          previousSecondPrice = null;
        });
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Edit Information'),
        ),
        body: Container(
          color: Colors.white,
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue),
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                ),
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Center(
                      child: Text(
                        'Price of Permanent Member ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24, // Increased font size
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: TextField(
                        controller: _firstEditingController,
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                        ],
                        decoration: InputDecoration(
                          labelText: 'Enter new price here',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          // Call the submit function for the first button when pressed
                          submitFirstToDatabase(_firstEditingController.text);
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.blue,
                          onPrimary: Colors.white,
                          padding: EdgeInsets.all(16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: Text(
                          'Submit ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18, // Increased font size
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 70),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.green),
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                ),
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Center(
                      child: Text(
                        'Price of Non-Permanent Member ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24, // Increased font size
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Center(
                      child: TextField(
                        controller: _secondEditingController,
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                        ],
                        decoration: InputDecoration(
                          labelText: 'Enter new price here',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          // Call the submit function for the second button when pressed
                          submitSecondToDatabase(_secondEditingController.text);
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.green,
                          onPrimary: Colors.white,
                          padding: EdgeInsets.all(16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: Text(
                          'Submit ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18, // Increased font size
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 50),
              Center(
                child: previousFirstPrice != null
                    ? Text(
                        'Price of Permanent Member: Rs.$previousFirstPrice',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 19, // Increased font size
                          color: const Color.fromARGB(255, 0, 0, 0),
                        ),
                      )
                    : Container(),
              ),
              SizedBox(height: 10),
              Center(
                child: previousSecondPrice != null
                    ? Text(
                        'Price of Non-permanent Member: Rs.$previousSecondPrice',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 19, // Increased font size
                          color: const Color.fromARGB(255, 0, 0, 0),
                        ),
                      )
                    : Container(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Dispose the controllers when the widget is disposed
    _firstEditingController.dispose();
    _secondEditingController.dispose();
    super.dispose();
  }
}

void main() {
  runApp(MaterialApp(
    home: EditInformation(),
  ));
}
