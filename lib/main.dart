import 'package:expenses_tracker/auth/login.dart';
import 'package:expenses_tracker/firebase_options.dart';
import 'package:expenses_tracker/sqlite.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expenses_tracker/tabs/add_expense.dart';
import 'package:expenses_tracker/tabs/analytics.dart';
import 'package:expenses_tracker/tabs/home.dart';
import 'package:expenses_tracker/tabs/profile.dart';
import 'package:expenses_tracker/tabs/second_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expenses_tracker/tabs/wallet.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CounterProvider()),
        Provider(create: (context) => SecondScreen()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Home'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    Sqlite().firebaseInit();
    super.initState();
  }

  int currIndex = 0;
  List<Widget> screens = [
    HomePage(),
    AnalyticsScreen(),
    LoginScreen(),
    WalletScreen(), // Wallet screen added
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 3, color: Colors.blue),
          borderRadius: BorderRadius.circular(100),
        ),
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => AddExpense()));
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            currIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: "Analytics"),
          BottomNavigationBarItem(icon: Icon(Icons.wallet), label: "Wallet"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
        ],
      ),
      body: screens[currIndex],
    );
  }
}
