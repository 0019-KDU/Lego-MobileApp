import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SenNotification extends StatefulWidget {
  const SenNotification(List<int> list, {super.key});

  @override
  State<SenNotification> createState() => _SenNotificationState();
}

//initialization web view
final controller = WebViewController()
  ..setJavaScriptMode(JavaScriptMode.unrestricted)
  ..loadRequest(Uri.parse("https://0019-kdu.github.io/Notification/"));

class _SenNotificationState extends State<SenNotification> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Send Notification'),
        backgroundColor: Colors.blue,
        leading: IconButton(
            icon: Icon(Icons.arrow_back), // Add a back icon
            onPressed: () {
              Navigator.of(context)
                  .pop(); // If WebView can't go back, pop the route
            }),
      ),
      body: Container(
        margin: const EdgeInsets.only(top: 18, left: 24, right: 24),
        padding: const EdgeInsets.symmetric(vertical: 50),
        child: WebViewWidget(controller: controller),
      ),
    );
  }
}
