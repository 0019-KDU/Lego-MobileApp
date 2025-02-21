import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditInformation extends StatefulWidget {
  const EditInformation({super.key});

  @override
  State<EditInformation> createState() => _EditInformationState();
}

class _EditInformationState extends State<EditInformation> {
  final TextEditingController permanentCostController = TextEditingController();
  final TextEditingController nonPermanentCostController =
      TextEditingController();

  String? previousPermanentCost;
  String? previousNonPermanentCost;

  @override
  void initState() {
    super.initState();
    // Fetch and set the initial values from Firestore
    fetchInitialValues();
  }

  Future<void> fetchInitialValues() async {
    try {
      DocumentSnapshot permantSnapshot = await FirebaseFirestore.instance
          .collection('permant')
          .doc('cost')
          .get();
      DocumentSnapshot nonPermantSnapshot = await FirebaseFirestore.instance
          .collection('non_permant')
          .doc('cost')
          .get();

      setState(() {
        previousPermanentCost = permantSnapshot['price'].toString();
        previousNonPermanentCost = nonPermantSnapshot['price'].toString();
      });
    } catch (error) {
      print('Error fetching initial values: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Information'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Price of Permanent Member',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: permanentCostController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: 'Enter new price here'),
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      onPressed: () {
                        updateCost('permant', permanentCostController.text);
                      },
                      child: const Text('Save Changes'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  previousPermanentCost != null
                      ? Text(
                          'Current Price of Permanent Member: $previousPermanentCost',
                          style:
                              const TextStyle(fontSize: 16, color: Colors.blue),
                        )
                      : const SizedBox.shrink(),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Price of Non-Permanent Member',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: nonPermanentCostController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: 'Enter new price here'),
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      onPressed: () {
                        updateCost(
                            'non_permant', nonPermanentCostController.text);
                      },
                      child: const Text('Save Changes'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  previousNonPermanentCost != null
                      ? Text(
                          'Current Price of Non-Permanent Member: $previousNonPermanentCost',
                          style:
                              const TextStyle(fontSize: 16, color: Colors.blue),
                        )
                      : const SizedBox.shrink(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> updateCost(String collectionName, String cost) async {
    try {
      // Validate if the cost is a valid double
      if (double.tryParse(cost) == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text('Please enter a valid number for $collectionName cost.'),
        ));
        return;
      }

      // Get the current price before the update
      String? previousCost;
      if (collectionName == 'permant') {
        previousCost = previousPermanentCost;
      } else if (collectionName == 'non_permant') {
        previousCost = previousNonPermanentCost;
      }

      // Update the Firestore document
      await FirebaseFirestore.instance
          .collection(collectionName)
          .doc('cost')
          .update({
        'price': double.parse(cost),
      });

      // Update the state to show the updated values
      setState(() {
        if (collectionName == 'permant') {
          previousPermanentCost = cost;
        } else if (collectionName == 'non_permant') {
          previousNonPermanentCost = cost;
        }
      });

      // Show a success message or navigate back to the previous screen
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('New price updated successfully.'),
      ));
    } catch (error) {
      // Handle errors
      print('Error updating cost: $error');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Error updating cost. Please try again.'),
      ));
    }
  }

  @override
  void dispose() {
    // Dispose the controllers when the widget is disposed
    permanentCostController.dispose();
    nonPermanentCostController.dispose();
    super.dispose();
  }
}
