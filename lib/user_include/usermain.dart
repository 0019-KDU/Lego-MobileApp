import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lego/components/drawer.dart';
import 'package:lego/user_include/exit_comeing.dart';
import 'package:lego/user_include/location.dart';
import 'package:lego/user_include/option.dart';
import 'package:lego/user_include/payment_details.dart';

class UserMainPage extends StatefulWidget {
  const UserMainPage({
    Key? key,
  }) : super(key: key);

  @override
  State<UserMainPage> createState() => _UserMainPageState();
}

class _UserMainPageState extends State<UserMainPage>
    with TickerProviderStateMixin {
  String? userName;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    fetchUserName();

    // Initialize the animation controller and animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animation = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(0, 10),
    ).animate(_controller);

    // Start the animation
    _controller.repeat(reverse: true);
  }

  Future<void> fetchUserName() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUser.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          userName = userDoc.get("username");
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.indigo.shade50,
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.only(top: 18, left: 24, right: 24),
          child: Column(
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      _scaffoldKey.currentState!.openEndDrawer();
                    },
                    child: const Icon(
                      Icons.bar_chart_rounded,
                      color: Colors.indigo,
                      size: 28,
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Flexible(
                    child: Text(
                      'HI $userName ',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.indigo,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 32,
              ),
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    const SizedBox(
                      height: 32,
                    ),
                    Center(
                      child: AnimatedBuilder(
                        animation: _animation, // Use the animation
                        builder: (context, child) {
                          return Transform.translate(
                            offset:
                                _animation.value, // Apply the animation value
                            child: Image.asset(
                              'assets/banner.png',
                              scale: 1.2,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    const Center(
                      child: Text(
                        "Lego",
                        style: TextStyle(
                            fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(
                      height: 48,
                    ),
                    const Text(
                      "SERVICE",
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: _cardMenu(
                            title: "JOURNEY",
                            icon: 'assets/go.png',
                            onTap: () {
                              // Handle the JOURNEY card onTap action
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const ComeGoing()),
                              );
                            },
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: _cardMenu(
                            title: "LOCATION",
                            icon: 'assets/map.png',
                            onTap: () {
                              // Handle the LOCATION card onTap action
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const Location()),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: _cardMenu(
                            title: "REQUEST",
                            icon: 'assets/mobile.png',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const SeatRequestScreen()),
                              );
                            },
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: _cardMenu(
                            title: "PAYMENT DETAILS",
                            icon: 'assets/cashless-payment.png',
                            onTap: () {
                              // Handle the PAYMENT DETAILS card onTap action
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const MainCard()),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      endDrawer: const MyDrawer(),
    );
  }

  Widget _cardMenu({
    required String title,
    required String icon,
    VoidCallback? onTap,
    Color color = Colors.white,
    Color fontColor = Colors.grey,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 190,
        padding: const EdgeInsets.symmetric(
          vertical: 30,
        ),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            Image.asset(icon),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold, color: fontColor),
            )
          ],
        ),
      ),
    );
  }
}
