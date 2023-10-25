import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class NotificationState extends StatefulWidget {
  const NotificationState({Key? key}) : super(key: key);

  @override
  _NotificationStateState createState() => _NotificationStateState();
}

class _NotificationStateState extends State<NotificationState> {
  @override
  void initState() {
    init();
    super.initState();
  }

  init() async {
    String deviceToken = await getDeviceToken();
    print("###### PRINT DEVICE TOKEN TO USE FOR PUSH NOTIFCIATION ######");
    print(deviceToken);
    print("############################################################");

    // listen for user to click on notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage remoteMessage) {
      String? title = remoteMessage.notification!.title;
      String? description = remoteMessage.notification!.body;

      //im gonna have an alertdialog when clicking from push notification
      Alert(
        context: context,
        type: AlertType.error,
        title: title, // title from push notification data
        desc: description, // description from push notifcation data
        buttons: [
          DialogButton(
            onPressed: () => Navigator.pop(context),
            width: 120,
            child: const Text(
              "COOL",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          )
        ],
      ).show();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height,
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                    child: Text(
                  "Firebase Messaging",
                  style: TextStyle(fontSize: 40),
                )),
                SizedBox(
                  height: 20,
                ),
                Center(
                    child: Text(
                  "How to integrate Firebase Messaging",
                  style: TextStyle(fontSize: 18),
                ))
              ],
            ),
          )
        ],
      ),
    ));
  }

  //get device token to use for push notification
  Future getDeviceToken() async {
    //request user permission for push notification
    FirebaseMessaging.instance.requestPermission();
    FirebaseMessaging _firebaseMessage = FirebaseMessaging.instance;
    String? deviceToken = await _firebaseMessage.getToken();
    return (deviceToken == null) ? "" : deviceToken;
  }
}
