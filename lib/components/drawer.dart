import 'package:flutter/material.dart';
import 'package:lego/authentication/auth_helper.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({
    super.key,
  });

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
            child: Stack(
              children: [
                Positioned(
                  bottom: 8.0,
                  left: 4.0,
                  child: Text(
                    "",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                )
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text("Home"),
            onTap: () {},
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
