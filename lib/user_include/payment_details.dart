import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MainCard extends StatefulWidget {
  const MainCard({super.key});

  @override
  State<MainCard> createState() => _MainCardState();
}

class _MainCardState extends State<MainCard> {
  String? userName;
  double? cost;
  String? costMessage;
  String? userRole;

  @override
  void initState() {
    super.initState();
    fetchUserName();
    fetchUserData();
  }

  Future<void> fetchUserName() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUser.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          userName = userDoc.get("username");
        });
      }
    }
  }

  Future<void> fetchUserData() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUser.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          userName = userDoc.get("username");
          userRole = userDoc.get("rool");
        });

        // Fetch the cost based on the user's role
        final costCollection = userRole == "Permanent"
            ? FirebaseFirestore.instance.collection("permant")
            : FirebaseFirestore.instance.collection("non_permant");

        final costDoc = await costCollection.doc("cost").get();
        if (costDoc.exists) {
          setState(() {
            cost = costDoc.get("price")?.toDouble();

            // Set the display message based on the user's role
            costMessage = userRole == "permanent"
                ? 'Your Monthly Payment Due is:'
                : 'You must pay per ride:';
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Display the user's name
            Text(
              'Hello, ${userName ?? 'User'}', // Use 'User' as a default if userName is null
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            // Display the cost to the user
            Text(
              cost != null
                  ? '$costMessage \$${cost?.toStringAsFixed(2)}'
                  : 'Cost: Loading...',
              style: const TextStyle(
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
