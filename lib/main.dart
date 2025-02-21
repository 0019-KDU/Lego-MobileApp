import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:lego/authentication/login.dart';
import 'package:lego/driver_include/drivermain.dart';
import 'package:lego/dashbord/admin.dart';
import 'package:lego/screens/user_include/notification.dart';
import 'package:lego/screens/user_include/usermain.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    // Set authentication persistence to LOCAL

    NotificationService.configureNotificationHandling();

    // Check if the user has already logged in
    User? user = FirebaseAuth.instance.currentUser;

    runApp(MyApp(initialUser: user));
  } catch (e) {
    print("Firebase initialization error: $e");
  }
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  final User? initialUser;

  const MyApp({super.key, this.initialUser});

  @override
  Widget build(BuildContext context) {
    if (initialUser != null) {
      return MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: Colors.blue[900],
        ),
        home: determineHomePage(initialUser!),
      );
    } else {
      return MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: Colors.blue[900],
        ),
        home: const LoginPage(),
      );
    }
  }

  Widget determineHomePage(User user) {
    // Implement logic to determine the home page based on user role
    // For example:
    if (isAdmin(user)) {
      return const AdminPage();
    } else if (isDriver(user)) {
      return const DriverMainPage();
    } else {
      return const UserMainPage();
    }
  }

  bool isAdmin(User user) {
    // Implement logic to check if the user is an admin
    // You may need to query your Firestore database or use other mechanisms
    // to determine the user's role.

    // Example: Assuming 'users' is your Firestore collection for user documents
    // and 'uid' is the field representing the user's ID
    FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        return documentSnapshot.get('rool') == 'Admin';
      } else {
        return false; // User document does not exist
      }
    }).catchError((error) {
      print('Error checking admin role: $error');
      return false; // Error occurred while querying
    });

    return false; // Default value, should not be reached
  }

  bool isDriver(User user) {
    // Implement logic to check if the user is a driver
    // You may need to query your Firestore database or use other mechanisms
    // to determine the user's role.

    // Example: Assuming 'users' is your Firestore collection for user documents
    // and 'uid' is the field representing the user's ID
    FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        return documentSnapshot.get('rool') == 'Driver';
      } else {
        return false; // User document does not exist
      }
    }).catchError((error) {
      print('Error checking driver role: $error');
      return false; // Error occurred while querying
    });

    return false; // Default value, should not be reached
  }
}
