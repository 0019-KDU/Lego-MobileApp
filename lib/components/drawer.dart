import 'package:flutter/material.dart';
import 'package:lego/authentication/auth_helper.dart';
import 'package:lego/dashbord/profile.dart';

class MyDrawer extends StatelessWidget {
  final OnUsernameChangedCallback onUsernameChanged;

  const MyDrawer({
    Key? key,
    required this.onUsernameChanged,
  }) : super(key: key);
// Function to handle the log out action

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.black,
              image: DecorationImage(
                image: AssetImage('assets/Lego.png'),
              ),
            ),
            child: null,
          ),
          ListTile(
            leading: const Icon(Icons.verified_user),
            title: const Text("User Profile"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ProfilePage(onUsernameChanged: onUsernameChanged),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline_rounded),
            title: const Text("About"),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.logout_rounded),
            title: const Text("Log Out"),
            onTap: () {
              AuthHelper.instance.logout(context);
            },
          )
        ],
      ),
    );
  }
}
