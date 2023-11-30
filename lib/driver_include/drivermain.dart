import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lego/authentication/auth_helper.dart';
import 'package:lego/driver_include/d_attendance.dart';
import 'package:lego/driver_include/location_service.dart';
import 'package:lego/screen/driver.dart';

class DriverMainPage extends StatefulWidget {
  const DriverMainPage({Key? key}) : super(key: key);

  @override
  State<DriverMainPage> createState() => _DriverMainPageState();
}

class _DriverMainPageState extends State<DriverMainPage>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    _initLocationService();
  }

  void _initLocationService() async {
    // Create an instance of LocationService and call shareLocation
    LocationService locationService = LocationService();
    await locationService.shareLocation();
  }

  @override
  Widget build(BuildContext context) {
    // Get the current date
    String currentDate = DateFormat.yMMMMd().format(DateTime.now());

    return Scaffold(
      backgroundColor: Colors.indigo.shade50,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        child: const Icon(
                          Icons.bar_chart_rounded,
                          color: Colors.indigo,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'HI Driver',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.indigo,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            currentDate,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Logout button
                  InkWell(
                    onTap: () {
                      // Implement the logic to handle the logout action
                      // For example, you can use AuthHelper to logout
                      AuthHelper.instance.logout(context);
                    },
                    child: const Icon(
                      Icons.logout_rounded,
                      color: Colors.indigo,
                      size: 28,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    const Center(
                      child: Text(
                        "Lego",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _cardMenu(
                            title: "LOCATION",
                            icon: 'assets/map.png',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const DriverPage(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _cardMenu(
                            title: "ATTENDANCE",
                            icon: 'assets/attend.png',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const d_attendance(),
                                ),
                              );
                            },
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
      ),
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
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: fontColor,
              ),
            )
          ],
        ),
      ),
    );
  }
}
