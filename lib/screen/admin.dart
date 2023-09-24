import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:lego/admin_include/additional.dart';
import 'package:lego/admin_include/daily_attendance.dart';
import 'package:lego/admin_include/location_page.dart';
import 'package:lego/admin_include/payment.dart';
import 'package:lego/admin_include/sendnotificationscreen.dart';
import 'package:lego/admin_include/user_count.dart';
import 'package:lego/authentication/login.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({Key? key}) : super(key: key);

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late BuildContext _context; // Store the context

  int _currentIndex = 0; // Index for the bottom navigation bar

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _context = context; // Store the context in didChangeDependencies
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            onPressed: () {
              _signOutAndNavigateToLogin(); // Use the stored context here
            },
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      drawer: Drawer(
        child: StreamBuilder<DocumentSnapshot>(
          stream: _firestore
              .collection("users")
              .doc(_auth.currentUser?.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Text('No data available');
            }

            final userData = snapshot.data!.data() as Map<String, dynamic>;
            final email = userData['email'] as String;
            final username = userData['username'] as String;

            return Column(
              children: [
                UserAccountsDrawerHeader(
                  accountName: Text(username),
                  accountEmail: Text(email),
                  currentAccountPicture: const CircleAvatar(
                    child: Icon(Icons.person),
                  ),
                ),
                // Add other drawer items below as needed
                ListTile(
                  leading: const Icon(Icons.verified_user_rounded),
                  title: const Text('Users'),
                  onTap: () {
                    // Handle drawer item tap
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const UserCount(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.request_quote_sharp),
                  title: const Text('Requested'),
                  onTap: () {
                    // Handle drawer item tap
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const AdminSeatResponseScreen(),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
      body: _buildBody(), // Add a method to build the body content
      bottomNavigationBar: Container(
        color: Colors.black,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
          child: GNav(
            backgroundColor: Colors.black,
            color: Colors.white,
            activeColor: Colors.white,
            tabBackgroundColor: const Color(0xFF424242),
            gap: 8,
            onTabChange: (index) {
              _onTabTapped(index); // Handle tab change
            },
            padding: const EdgeInsets.all(15),
            tabs: const [
              GButton(icon: Icons.home, text: "Home"),
              GButton(icon: Icons.list_alt, text: "Daily Attendance"),
              GButton(icon: Icons.location_history_sharp, text: "Location"),
              GButton(icon: Icons.message_sharp, text: "Send message")
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        // Home Page
        return const PaymentDetails();
      case 1:
        // Daily Attendance Page
        return const DailyAttendancePage();
      case 2:
        // Location Page
        return const RuntimeLocationDriver();
      // case 3:
      //   // Send Message Page
      //   return const SendNotificationPage();
      default:
        return const SendNotificationPage();
    }
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _signOutAndNavigateToLogin() async {
    try {
      await _auth.signOut();
      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
        _context, // Use the stored context here
        MaterialPageRoute(
          builder: (context) => const LoginPage(),
        ),
      );
    } catch (e) {
      print('An error occurred while signing out: $e');
    }
  }
}
