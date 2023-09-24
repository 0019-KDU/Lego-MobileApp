import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:lego/authentication/login.dart';
import 'package:lego/user_include/notification.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  NotificationService.configureNotificationHandling();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.blue[900],
      ),
      home: LoginPage(),
    );
  }
}
