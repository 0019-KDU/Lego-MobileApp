import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SendNotificationPage extends StatefulWidget {
  const SendNotificationPage({super.key});

  @override
  _SendNotificationPageState createState() => _SendNotificationPageState();
}

class _SendNotificationPageState extends State<SendNotificationPage> {
  final controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.disabled)
    ..loadRequest(Uri.parse('https://0019-kdu.github.io/Notification/'));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WebViewWidget(
        controller: controller, // Assign the WebViewController
      ),
    );
  }
}
