import 'package:expenses_tracker/api/firebase_api.dart';
import 'package:expenses_tracker/auth/signup.dart';
import 'package:expenses_tracker/firebase_options.dart';
import 'package:expenses_tracker/pages/onboarding/first_screen.dart';
import 'package:expenses_tracker/providers/wallet_provider.dart';
import 'package:expenses_tracker/screens/settings_screen.dart';
import 'package:expenses_tracker/styles/app_colors.dart';
import 'package:expenses_tracker/tabs/add_expense.dart';
import 'package:expenses_tracker/screens/analytics_screen.dart';
import 'package:expenses_tracker/tabs/home.dart';
import 'package:expenses_tracker/tabs/profile.dart';
import 'package:expenses_tracker/tabs/second_screen.dart';
import 'package:expenses_tracker/tabs/wallet.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/firebase_service.dart';

final navigatorKey = GlobalKey<NavigatorState>();

Future<bool> initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseService().initialize();

  // Initialize shared preferences
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool("hasSeenOnBoarding") ?? false;
}

void main() async {
  final hasSeenOnBoarding = await initializeApp();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CounterProvider()),
        ChangeNotifierProvider(create: (context) => WalletProvider()),
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
            const EdgeInsets.all(20),
          ),
          backgroundColor: WidgetStateProperty.all<Color>(AppColors.secondary),
          foregroundColor: WidgetStateProperty.all<Color>(AppColors.primary),
          fixedSize: WidgetStateProperty.all<Size>(
            Size.fromWidth(MediaQuery.of(context).size.width * 0.8),
          ),
        ),
      ),
      fontFamily: "Poppins",
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
      textTheme: const TextTheme(
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
      home: const FirstScreen(),
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
    HomeScreen(),
    AnalyticsScreen(),
    WalletScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      bottomNavigationBar: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: 80,
            margin: const EdgeInsets.only(top: 30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home, 'Home'),
                _buildNavItem(1, Icons.analytics, 'Analytics'),
                const SizedBox(width: 60),
                _buildNavItem(2, Icons.wallet, 'Wallet'),
                _buildNavItem(3, Icons.person, 'Profile'),
              ],
            ),
          ),
          Positioned(
            top: 0,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFFFB800),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.add,
                  size: 32,
                  color: Colors.black,
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => AddExpense()),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      body: Container(child: screens[currIndex]),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = currIndex == index;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => setState(() => currIndex = index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? const Color(0xFF2C1F63) : Colors.grey.shade400,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? const Color(0xFF2C1F63) : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
