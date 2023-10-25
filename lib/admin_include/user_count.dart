import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserCount extends StatelessWidget {
  const UserCount(List<int> list, {Key? key});

  Future<void> _deleteUser(BuildContext context, String userId) async {
    try {
      // Delete user from Firebase Authentication
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null && user.uid == userId) {
        await user.delete();
      }

      // Delete user document from Firestore
      await FirebaseFirestore.instance.collection("users").doc(userId).delete();
    } catch (e) {
      print("Error deleting user: $e");
      // Handle the error appropriately (e.g., show a snackbar or display an error message)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User List'),
        backgroundColor: Colors.black,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("users").snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final users = snapshot.data?.docs ?? [];

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final userData = users[index].data() as Map<String, dynamic>;
              final username = userData['username'] ?? '';
              final email = userData['email'] ?? '';
              final role = userData['role'] ?? ''; // Corrected 'rool' to 'role'
              print(role);
              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text(
                    'Username: $username',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Email: $email',
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Role: ${role ?? "No role available"}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      // Get the current user's ID
                      final userId = users[index].id;
                      await _deleteUser(context, userId);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
