import 'package:expenses_tracker/pages/notifications.dart';
import 'package:expenses_tracker/pages/onboarding/goal_tracking.dart';
import 'package:expenses_tracker/pages/onboarding/set_goals.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Fixing spacing
          children: [
            Text(
              "Profile",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSecondary,
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => Notifications()),
                );
              },
              child: Icon(
                Icons.notifications,
                color: Theme.of(context).colorScheme.onSecondary,
              ),
            ),
          ],
        ),
        leading: InkWell(
          onTap: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (context) => Notifications()));
          },
          child: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.onSecondary,
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, BoxConstraints constraints) {
          return SingleChildScrollView(
            child: Column(
              children: [
                // Top Green Container
                Container(
                  width: double.infinity,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.elliptical(200, 50),
                      bottomRight: Radius.elliptical(200, 50),
                    ),
                  ),
                ),

                SizedBox(
                  height: 150, // Ensure enough space for Positioned Widget
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        top: -50,
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: Image.asset(
                                "assets/mtnlogo.jpg",
                                fit: BoxFit.cover,
                                width: 80,
                                height: 80,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text("Justin Mihigo"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Menu Items
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    children: [
                      _menuItem(Icons.person, "Account Info", () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GoalTracking(),
                          ),
                        );
                      }),
                      _menuItem(Icons.language, "Languages", () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GoalTracking(),
                          ),
                        );
                      }),
                      _menuItem(Icons.abc, "Goals", () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SpendingLimitScreen(),
                          ),
                        );
                      }),
                      _menuItem(Icons.security, "Security", () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GoalTracking(),
                          ),
                        );
                      }),
                      _menuItem(Icons.logout, "Logout", () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GoalTracking(),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _menuItem(IconData icon, String text, Function page) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Row(
        children: [
          Icon(icon, size: 24),
          const SizedBox(width: 20), // Fixing spacing
          InkWell(
            onTap: page as dynamic,
            child: Text(text, style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
