import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;

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
    // Listen for when the user clicks on a notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage remoteMessage) {
      final title = remoteMessage.notification?.title ?? "";
      final description = remoteMessage.notification?.body ?? "";

      // Handle the notification, e.g., show an alert dialog
      // You can customize this part as needed
    });
  }
}
