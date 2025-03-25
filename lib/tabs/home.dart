import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";

void main() {
  runApp(HomePage());
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme.apply(
            displayColor: Colors.white,
            bodyColor: Colors.white,
          ),
        ),
        colorScheme: ColorScheme.dark(),
      ),
      home: Scaffold(
        body: LayoutBuilder(
          builder: (context, BoxConstraints constraints) {
            return SizedBox(
              height: double.infinity,
              width: double.infinity,
              child: Stack(
                children: [
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 8, 130, 104),
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
                                style: TextStyle(fontSize: 20),
                              ),
                              Text(
                                "Justin Mihigo",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            border: Border.all(width: 1),
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          child: Icon(Icons.notifications_rounded),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 150,
                    left: 40,
                    child: Container(
                      width: 300,
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 5, 79, 56),
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    spacing: 10,
                                    children: [
                                      Text("Total balance"),
                                      Icon(Icons.arrow_upward),
                                    ],
                                  ),
                                  Text(
                                    "\$28500",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Icon(Icons.more_horiz_outlined, size: 30),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                        ),
                                      ),
                                      Text("Income"),
                                    ],
                                  ),
                                  Text("\$444000"),
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
                                        ),
                                      ),
                                      Text("Income"),
                                    ],
                                  ),
                                  Text("\$444000"),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: constraints.maxHeight * 0.5,
                    left: 50,
                    child: SizedBox(
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
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
