import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          spacing: 50,
          children: [Text("Profile"), Icon(Icons.notifications)],
        ),
        leading: Icon(Icons.arrow_back),
      ),
      body: LayoutBuilder(
        builder: (context, BoxConstraints constraints) {
          return Center(
            child: SizedBox(
              height: double.infinity,
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.elliptical(200, 50),
                        bottomRight: Radius.elliptical(200, 50),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 100,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          top: -50,
                          left: constraints.maxWidth * 0.4,
                          child: Column(
                            spacing: 10,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                // borderRadius: BorderRadius.all(Radius.circular(100)),
                                child: Image.asset(
                                  "assets/mtnlogo.jpg",
                                  fit: BoxFit.fitWidth,
                                  width: 80,
                                ),
                              ),
                              Text("Justin Mihigo"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: constraints.maxWidth * 0.8,
                    height: 300,
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Column(
                        spacing: 40,
                        children: [
                          Row(
                            spacing: 50,
                            children: [
                              Icon(Icons.person),
                              Text("Account Info"),
                            ],
                          ),

                          Row(
                            spacing: 50,
                            children: [Icon(Icons.language), Text("Languages")],
                          ),
                          Row(
                            spacing: 50,
                            children: [Icon(Icons.security), Text("Security")],
                          ),
                          Row(
                            spacing: 50,
                            children: [Icon(Icons.logout), Text("Logout")],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
