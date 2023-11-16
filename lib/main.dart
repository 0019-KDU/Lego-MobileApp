import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:lego/authentication/login.dart';
import 'package:lego/driver_include/drivermain.dart';
import 'package:lego/user_include/notification.dart';
import 'package:lego/user_include/usermain.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    // Set authentication persistence to LOCAL

    NotificationService.configureNotificationHandling();
    // Check if the user has already logged in
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    runApp(MyApp(isLoggedIn: isLoggedIn));
  } catch (e) {
    print("Firebase initialization error: $e");
  }
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({Key? key, required this.isLoggedIn}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.blue[900],
      ),
      home: isLoggedIn ? const UserMainPage() : const LoginPage(),
      // Add DriverMainPage as an option in your app's navigation
      routes: {
        '/driverMain': (context) => const DriverMainPage(),
      },
    );
  }
}
