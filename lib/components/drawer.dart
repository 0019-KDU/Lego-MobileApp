import 'package:flutter/material.dart';
import 'package:lego/authentication/login.dart';
import 'package:lego/screen/profile.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({
    super.key,
  });

// Function to handle the log out action
  void logout(BuildContext context) async {
    // Implement your log out logic here, such as clearing user session.
    // For demonstration purposes, we'll use a Future.delayed to simulate the process.

    // Simulate a delay for clearing the session (replace this with your actual logic)
    await Future.delayed(const Duration(seconds: 1));

    // After clearing the session, navigate to the login screen.
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.indigo.shade50,
        child: ListView(
          children: [
            const DrawerHeader(
              child: Center(
                child: Text(
                  "L E G O",
                  style: TextStyle(fontSize: 32),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.verified_user_rounded),
              title: const Text(
                "User Profile",
                style: TextStyle(fontSize: 20),
              ),
              onTap: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => ProfilePage()));
              },
            ),
            const SizedBox(
              height: 70,
            ), // This adds spacing between the previous items and the ones at the bottom
            ListTile(
              leading: const Icon(Icons.logout_sharp),
              title: const Text(
                "L O G O U T",
                style: TextStyle(fontSize: 20),
              ),
              onTap: () {
                // Implement the settings logic here
                logout(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
