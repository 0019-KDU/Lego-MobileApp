import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lego/admin_include/additional.dart';
import 'package:lego/admin_include/daily_attendance.dart';
import 'package:lego/admin_include/editinformation.dart';
import 'package:lego/admin_include/payment.dart';
import 'package:lego/admin_include/sendnotificationscreen.dart';
import 'package:lego/admin_include/travel_page.dart';
import 'package:lego/admin_include/user_count.dart';
import 'package:lego/authentication/auth_helper.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  var height, width;

  List imgSrc = [
    "assets/att.png",
    "assets/notebook.gif",
    "assets/bubble-chat.gif",
    "assets/notifications.gif",
    "assets/payment-app.gif",
    "assets/user.gif",
  ];

  List titles = [
    "ATTENDANCE",
    "LOCATION",
    "REQUEST",
    "NOTIFICATION",
    "USER PAYMENTT",
    "USERS"
  ];

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            color: Colors.black,
            width: width,
            child: Column(
              children: [
                Container(
                  decoration: const BoxDecoration(),
                  height: height * 0.25,
                  width: width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.only(top: 35, left: 30, right: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () {
                                AuthHelper.instance.logout(context);
                              },
                              child: const Icon(
                                Icons.logout_rounded,
                                color: Colors.white,
                                size: 35,
                              ),
                            ),
                            Container(
                              height: 50,
                              width: 50,
                              decoration: const BoxDecoration(
                                  image: DecorationImage(
                                image: AssetImage('assets/Lego.png'),
                              )),
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 20,
                          left: 30,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Dashboard",
                                        style: TextStyle(
                                            fontSize: 35,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: 1),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        DateFormat('MMMM d, y')
                                            .format(DateTime.now()),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.white54,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    // Navigate to the edit page
                                    // Add your navigation logic here
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const EditInformation(),
                                      ),
                                    );
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SingleChildScrollView(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(50),
                        topRight: Radius.circular(50),
                      ),
                    ),
                    //height: height * 0.75,
                    width: width,
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio:
                                  1.1, // Adjust the aspect ratio to control the box size
                              mainAxisSpacing: 50,
                              crossAxisSpacing: 20),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: imgSrc.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            switch (index) {
                              case 0:
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ComeGoing([index]),
                                  ),
                                );
                                break;
                              case 1:
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TravelForm([index]),
                                  ),
                                );
                                break;
                              case 2:
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        AdminSeatResponseScreen([index]),
                                  ),
                                );
                              case 3:
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        SenNotification([index]),
                                  ),
                                );
                                break;
                              case 4:
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        AdminPayments([index]),
                                  ),
                                );
                              case 5:
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => UserCount([index]),
                                  ),
                                );
                                break;
                              default:
                                break;
                            }
                          },
                          child: Container(
                            margin: const EdgeInsets.all(20),
                            padding: const EdgeInsets.symmetric(
                              vertical: 20, // Increase the vertical padding
                              horizontal: 30, // Increase the horizontal padding
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20.0),
                              color: Colors.white,
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  spreadRadius: 1,
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Image.asset(
                                  imgSrc[index],
                                  width: 100,
                                ),
                                Text(
                                  titles[index],
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
