import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:lego/main.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;

  // Define a callback function for handling new notifications
  static void Function()? onNewNotificationReceived = () {};

  // todo: get device token for identifying the device
  static Future<String?> getDeviceToken() async {
    try {
      // Request user permission for push notifications
      await _firebaseMessaging.requestPermission();

      // Get the device token
      final deviceToken = await _firebaseMessaging.getToken();
      print('Device token: $deviceToken');

      if (deviceToken != null) {
        // Save the device token to Firestore with the document ID as the token
        final db = FirebaseFirestore.instance;
        final tokenCollection = db.collection('tokens');

        // Use set() to create or update the document with the token as the document ID
        await tokenCollection.doc(deviceToken).set({'token': deviceToken});
      }

      return deviceToken;
    } catch (e) {
      print('Error getting device token or saving to Firestore: $e');
      return null;
    }
  }

  static void configureNotificationHandling() {
    getDeviceToken();

    // Listen for incoming messages when the app is in the foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage remoteMessage) {
      final title = remoteMessage.notification?.title ?? "";
      final description = remoteMessage.notification?.body ?? "";

      // Handle the notification, e.g., show an alert dialog
      // You can customize this part as needed

      // Show an alert dialog using rflutter_alert
      Alert(
        context: navigatorKey.currentState!
            .context, // Replace YourAppNavigatorKey with your navigator key
        type: AlertType.info, // Customize the type of alert as needed
        title: title,
        desc: description,
        buttons: [
          DialogButton(
            onPressed: () {
              Navigator.pop(
                  navigatorKey.currentState!.context); // Close the alert dialog
              // Handle the action when the button is pressed
              // You can add code to navigate to the desired screen here
            },
            child: const Text(
              "View Details",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
        ],
      ).show();

      // Notify the UserMainPage widget of a new notification
      onNewNotificationReceived?.call();
    });

    // Listen for when the user clicks on a notification when the app is terminated
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage remoteMessage) {
      final title = remoteMessage.notification?.title ?? "";
      final description = remoteMessage.notification?.body ?? "";

      // Handle the notification, e.g., show an alert dialog
      // You can customize this part as needed

      // Show an alert dialog using rflutter_alert
      Alert(
        context: navigatorKey.currentState!
            .context, // Replace YourAppNavigatorKey with your navigator key
        type: AlertType.info, // Customize the type of alert as needed
        title: title,
        desc: description,
        buttons: [
          DialogButton(
            onPressed: () {
              Navigator.pop(
                  navigatorKey.currentState!.context); // Close the alert dialog
              // Handle the action when the button is pressed
              // You can add code to navigate to the desired screen here
            },
            child: const Text(
              "View Details",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
        ],
      ).show();

      // Notify the UserMainPage widget of a new notification
      onNewNotificationReceived?.call();
    });
  }
}
