import 'package:flutter/material.dart';
import 'package:lego/components/drawer.dart';
import 'package:lego/screen/profile.dart';
import 'package:lego/user_include/attendance_history.dart';
import 'package:lego/user_include/location.dart';
import 'package:lego/user_include/option.dart';
import 'package:lego/user_include/usermain.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  static const route = '/user-screen';

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  int index = 0;

  final screen = const [
    UserMainPage(),
    Location(),
    AttendanceHistory(),
    SeatRequestScreen(),
  ];

  void goToProfilePage() {
    Navigator.pop(context);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProfilePage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool showAppBar = index == 0;
    return Scaffold(
      appBar: showAppBar ? AppBar(backgroundColor: Colors.black) : null,
      drawer: Mydrawer(
        onProfileTap: goToProfilePage,
      ),
      body: screen[index],
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(indicatorColor: Colors.blue.shade100),
        child: NavigationBar(
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
          selectedIndex: index,
          onDestinationSelected: (index) => setState(() => this.index = index),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home), label: "Home"),
            NavigationDestination(
                icon: Icon(Icons.location_on), label: "Location"),
            NavigationDestination(
                icon: Icon(Icons.assignment_sharp), label: "Travel History"),
            NavigationDestination(
                icon: Icon(Icons.work), label: "Notification"),
          ],
        ),
      ),
    );
  }
}
