import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lego/authentication/login.dart';
import 'package:lego/components/my_list_tile.dart';

class Mydrawer extends StatefulWidget {
  final void Function()? onProfileTap;

  const Mydrawer({super.key, required this.onProfileTap});

  @override
  State<Mydrawer> createState() => _MydrawerState();
}

class _MydrawerState extends State<Mydrawer> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.black,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          //header
          Column(
            children: [
              const DrawerHeader(
                child: Icon(
                  Icons.person,
                  color: Colors.red, // Change the color here
                  size: 100,
                ),
              ),
              //home list tile
              MyListTile(
                icon: Icons.home,
                text: "H O M E",
                onTap: () => Navigator.pop(context),
              ),
              MyListTile(
                icon: Icons.person,
                text: "P R O F I L E",
                onTap: widget.onProfileTap,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: MyListTile(
              icon: Icons.logout,
              text: "L O G O U T",
              onTap: _signOutAndNavigateToLogin,
            ),
          ),
        ],
      ),
    );
  }

  void _signOutAndNavigateToLogin() async {
    try {
      await _auth.signOut();
      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
        context, // Use the context from the build method
        MaterialPageRoute(
          builder: (context) => const LoginPage(),
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print('An error occurred while signing out: $e');
      }
    }
  }
}
