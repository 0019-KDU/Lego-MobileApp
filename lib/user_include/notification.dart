import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;

  static Future<String> getDeviceToken() async {
    // Request user permission for push notifications
    await _firebaseMessaging.requestPermission();

    // Get the device token
    final deviceToken = await _firebaseMessaging.getToken();
    print(deviceToken);
    return deviceToken ?? "";
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
