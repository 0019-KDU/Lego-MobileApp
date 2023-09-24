import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserCount extends StatelessWidget {
  const UserCount({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User List'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("users").snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          final users = snapshot.data?.docs ?? [];

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final userData = users[index].data() as Map<String, dynamic>;
              final username = userData['username'] ?? '';
              final email = userData['email'] ?? '';
              final type = userData['rool'] ?? '';

              return ListTile(
                title: Text('Username: $username'),
                subtitle: Text('Email: $email'),
                trailing: Text('$type'),
              );
            },
          );
        },
      ),
    );
  }
}
