import 'package:carousel_slider/carousel_slider.dart';
import 'package:expenses_tracker/auth/login.dart';
import 'package:expenses_tracker/styles/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirstScreen extends StatelessWidget {
  const FirstScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const FirstScreenState();
  }
}

class FirstScreenState extends StatefulWidget {
  const FirstScreenState({super.key});
  @override
  State<StatefulWidget> createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreenState> {
  final List<Map<String, String>> screenContents = [
    {"text": "Your trusted financial partner", "image": "assets/1.jpg"},
    {"text": "Plan Smart, Spend Wisely", "image": "assets/2.jpg"},
    {"text": "Take Control of Your Money!", "image": "assets/3.jpg"},
  ];
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: Container(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            decoration: BoxDecoration(color: Colors.blueAccent),
            child: Stack(
              children: [
                CarouselSlider(
                  items:
                      screenContents.map((content) {
                        return Builder(
                          builder: (context) {
                            return Stack(
                              children: [
                                Container(
                                  width: constraints.maxWidth,
                                  height: constraints.maxHeight,
                                  child: Image.asset(
                                    "${content["image"]}",
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Align(
                                  child: Container(
                                    width: constraints.maxWidth * 0.8,
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(20),
                                      ),
                                      color: Colors.white,
                                    ),
                                    child: Text(
                                      "${content["text"]}",

                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontFamily: "poppins",
                                        backgroundColor: Colors.white,

                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      }).toList(),
                  options: CarouselOptions(
                    height: constraints.maxHeight,
                    initialPage: 0,
                    enableInfiniteScroll: true,
                    reverse: false,
                    autoPlay: true,
                    viewportFraction: 1,
                    autoPlayInterval: Duration(seconds: 4),
                    animateToClosest: true,
                    autoPlayAnimationDuration: Duration(milliseconds: 500),
                    autoPlayCurve: Curves.fastOutSlowIn,
                    enlargeCenterPage: false,
                    enlargeFactor: 1,
                    scrollDirection: Axis.horizontal,
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: ElevatedButton(
                      style: ButtonStyle(
                        padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                          EdgeInsets.all(20),
                        ),
                        backgroundColor: WidgetStateProperty.all<Color>(
                          AppColors.secondary,
                        ),
                        fixedSize: WidgetStateProperty.all<Size>(
                          Size.fromWidth(constraints.maxWidth * 0.8),
                        ),
                      ),
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool("hasSeenOnBoarding", true);
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => LoginScreen(),
                          ),
                        );
                      },
                      child: Text(
                        "Get started",
                        style: TextStyle(
                          fontFamily: "Poppins",
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Column(
            //   children: [
            //     Column(children: [Text("Have your money checked")]),

            //   ],
            // ),
          ),
        );
      },
    );
  }
}
