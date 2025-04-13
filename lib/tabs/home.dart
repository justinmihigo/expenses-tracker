import "package:expenses_tracker/pages/notifications.dart";
import "package:flutter/material.dart";

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, BoxConstraints constraints) {
          return SizedBox(
            height: double.infinity,
            width: double.infinity,
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 60,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        clipBehavior: Clip.none,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(30),
                            bottomRight: Radius.circular(30),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Container(
                              height: 100,
                              margin: EdgeInsets.only(top: 40),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                spacing: 5,
                                children: [
                                  Text(
                                    "Good Morning",
                                    style: TextStyle(
                                      fontSize: 20,
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.onSecondary,
                                    ),
                                  ),
                                  Text(
                                    "Justin Mihigo",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.onSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              clipBehavior: Clip.none,
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color:
                                      Theme.of(context).colorScheme.onSecondary,
                                ),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                              ),
                              child: InkWell(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => Notifications(),
                                    ),
                                  );
                                },
                                child: Icon(
                                  Icons.notifications_rounded,
                                  color:
                                      Theme.of(context).colorScheme.onSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 150,
                        left: 50,
                        child: Center(
                          child: Container(
                            width: 300,
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.secondary,
                              borderRadius: BorderRadius.all(
                                Radius.circular(20),
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          spacing: 10,
                                          children: [
                                            Text(
                                              "Total balance",
                                              style: TextStyle(
                                                color:
                                                    Theme.of(
                                                      context,
                                                    ).colorScheme.onSecondary,
                                              ),
                                            ),
                                            Icon(
                                              Icons.arrow_upward,
                                              color:
                                                  Theme.of(
                                                    context,
                                                  ).colorScheme.onSecondary,
                                            ),
                                          ],
                                        ),
                                        Text(
                                          "\$28500",
                                          style: TextStyle(
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.onSecondary,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Icon(
                                      Icons.more_horiz_outlined,
                                      size: 30,
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.onSecondary,
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(5),
                                                ),
                                              ),
                                              child: Icon(
                                                Icons.arrow_downward_rounded,
                                                color:
                                                    Theme.of(
                                                      context,
                                                    ).colorScheme.onSecondary,
                                              ),
                                            ),
                                            Text(
                                              "Income",
                                              style: TextStyle(
                                                color:
                                                    Theme.of(
                                                      context,
                                                    ).colorScheme.onSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          "\$444000",
                                          style: TextStyle(
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.onSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(5),
                                                ),
                                              ),
                                              child: Icon(
                                                Icons.arrow_downward_rounded,
                                                color:
                                                    Theme.of(
                                                      context,
                                                    ).colorScheme.onSecondary,
                                              ),
                                            ),
                                            Text(
                                              "Income",
                                              style: TextStyle(
                                                color:
                                                    Theme.of(
                                                      context,
                                                    ).colorScheme.onSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          "\$444000",
                                          style: TextStyle(
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.onSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Positioned(
                      //   top: constraints.maxHeight * 0.5,
                      //   left: 50,
                      // child:
                    ],
                  ),
                  SizedBox(
                    width: 300,
                    height: 500,
                    child: ListView(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Transaction history"),
                            Text("View all"),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Image.asset(
                              "assets/mtnlogo.jpg",
                              width: 40,
                              height: 40,
                              scale: 0.2,
                            ),
                            Column(children: [Text("Paypal"), Text("Today")]),
                            Text(
                              "30493",
                              style: (TextStyle(
                                color: Colors.green,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              )),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Image.asset(
                              "assets/mtnlogo.jpg",
                              width: 40,
                              height: 40,
                              scale: 0.2,
                            ),
                            Column(children: [Text("Paypal"), Text("Today")]),
                            Text(
                              "30493",
                              style: (TextStyle(
                                color: Colors.green,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              )),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Image.asset(
                              "assets/mtnlogo.jpg",
                              width: 40,
                              height: 40,
                              scale: 0.2,
                            ),
                            Column(children: [Text("Paypal"), Text("Today")]),
                            Text(
                              "30493",
                              style: (TextStyle(
                                color: Colors.green,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              )),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Image.asset(
                              "assets/mtnlogo.jpg",
                              width: 40,
                              height: 40,
                              scale: 0.2,
                            ),
                            Column(children: [Text("Paypal"), Text("Today")]),
                            Text(
                              "30493",
                              style: (TextStyle(
                                color: Colors.green,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              )),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // ),
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
