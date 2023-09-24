import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lego/components/text_box.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    super.key,
  });

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final userCollection = FirebaseFirestore.instance.collection('users');

  Future<void> editField(String field) async {
    String? newValue = '';

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: Text(
          "Edit $field",
          style: const TextStyle(color: Colors.white),
        ),
        content: TextField(
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Enter new",
            hintStyle: TextStyle(color: Colors.grey),
          ),
          onChanged: (value) {
            newValue = value;
          },
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white),
            ),
          ),
          TextButton(
            onPressed: () async {
              // Update the field with the new value
              if (newValue!.trim().isNotEmpty) {
                await userCollection
                    .doc(currentUser.uid)
                    .update({field: newValue});
                Navigator.of(context).pop(); // Close the dialog
              } else {
                // Handle the case where newValue is empty or null
                print('Invalid input for newValue');
              }
            },
            child: const Text(
              'Save',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile Page"),
        backgroundColor: Colors.black87,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final userData = snapshot.data!.data() as Map<String, dynamic>;
            return ListView(
              children: [
                const SizedBox(
                  height: 25,
                ),
                const Icon(
                  Icons.person,
                  size: 100,
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  currentUser.email!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 25),
                  child: Text(
                    "My Details",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                MyTextBox(
                  text: userData['username'],
                  sectionName: 'Username',
                  onPressed: () => editField('username'), // Fix typo here
                ),
                MyTextBox(
                  text: userData['rool'],
                  sectionName: "Type",
                  onPressed: () {},
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}"),
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
