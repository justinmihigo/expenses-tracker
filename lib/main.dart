import 'package:expenses_tracker/api/firebase_api.dart';
import 'package:expenses_tracker/auth/signup.dart';
import 'package:expenses_tracker/firebase_options.dart';
import 'package:expenses_tracker/pages/onboarding/first_screen.dart';
import 'package:expenses_tracker/styles/app_colors.dart';
import 'package:expenses_tracker/tabs/add_expense.dart';
import 'package:expenses_tracker/tabs/analytics.dart';
import 'package:expenses_tracker/tabs/home.dart';
import 'package:expenses_tracker/tabs/profile.dart';
import 'package:expenses_tracker/tabs/second_screen.dart';
import 'package:expenses_tracker/tabs/wallet.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

final navigatorKey = GlobalKey<NavigatorState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseApi().firebaseInit();
  final prefs = await SharedPreferences.getInstance();

  final hasSeenOnBoarding = prefs.getBool("hasSeenOnBoarding") ?? false;
  debugPrint("onboarding $hasSeenOnBoarding");
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CounterProvider()),
        Provider(create: (context) => SecondScreen()),
      ],
      child: MyApp(hasSeenOnBoarding: hasSeenOnBoarding),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool hasSeenOnBoarding;
  const MyApp({super.key, required this.hasSeenOnBoarding});

  @override
  Widget build(BuildContext context) {
    final ThemeData appTheme = ThemeData(
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
            EdgeInsets.all(20),
          ),
          backgroundColor: WidgetStateProperty.all<Color>(AppColors.secondary),
          foregroundColor: WidgetStateProperty.all<Color>(AppColors.primary),
          fixedSize: WidgetStateProperty.all<Size>(
            Size.fromWidth(MediaQuery.of(context).size.width * 0.8),
          ),
        ),
      ),
      fontFamily: "Poppins", // This should apply to all text
      primaryColor: AppColors.secondary,
      colorScheme: ColorScheme.light(
        primary: AppColors.secondary,
        onPrimary: AppColors.secondary,
        secondary: AppColors.accent,
        onSecondary: AppColors.primary,
        error: AppColors.errorColor,
        onError: AppColors.primary,
        surface: AppColors.primary,
        onSurface: AppColors.secondary,
      ),
      textTheme: TextTheme(
        displayMedium: TextStyle(fontSize: 15, color: AppColors.secondary),
        titleSmall: TextStyle(
          fontSize: 12,
          color: AppColors.secondary,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: TextStyle(fontSize: 20, color: AppColors.secondary),
        bodyMedium: TextStyle(fontSize: 15, color: AppColors.secondary),
      ),
    );

    return MaterialApp(
      title: 'Expense tracker',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      routes: {SignupScreen.route: (context) => const SignupScreen()},
      theme: appTheme,
      home:
          // hasSeenOnBoarding
          //     ? const MyHomePage(title: 'Home')
          //     :
          const FirstScreen(),
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
    FirebaseApi().firebaseInit();
    super.initState();
  }

  int currIndex = 0;
  List<Widget> screens = [
    HomePage(),
    AnalyticsScreen(),
    WalletScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      //   title: Text(widget.title),
      // ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 3, color: Colors.blue),
          borderRadius: BorderRadius.circular(100),
        ),
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => AddExpense()));
        },
        child: Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            currIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: "Analytics",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.wallet), label: "Wallet"),

          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Settings",
          ),
        ],
      ),
      body: Container(child: screens[currIndex]),
    );
  }
}
