import 'package:expenses_tracker/api/firebase_api.dart';
import 'package:expenses_tracker/auth/login.dart';
import 'package:expenses_tracker/auth/signup.dart';
import 'package:expenses_tracker/firebase_options.dart';
import 'package:expenses_tracker/pages/onboarding/first_screen.dart';
import 'package:expenses_tracker/providers/wallet_provider.dart';
import 'package:expenses_tracker/screens/settings_screen.dart';
import 'package:expenses_tracker/styles/app_colors.dart';
import 'package:expenses_tracker/tabs/add_expense.dart';
import 'package:expenses_tracker/screens/analytics_screen.dart';
import 'package:expenses_tracker/tabs/home.dart';
import 'package:expenses_tracker/tabs/second_screen.dart';
import 'package:expenses_tracker/tabs/wallet.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'services/firebase_service.dart';


final navigatorKey = GlobalKey<NavigatorState>();

Future<Map<String, dynamic>> initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Awesome Notifications
  await AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelKey: 'transactions',
        channelName: 'Transaction Notifications',
        channelDescription: 'Notifications for transaction updates',
        defaultColor: const Color(0xFF2C1F63),
        ledColor: Colors.white,
        importance: NotificationImportance.High,
        channelShowBadge: true,
        enableVibration: true,
        enableLights: true,
      ),
    ],
  );

  // Request permission to show notifications
  await AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
    if (!isAllowed) {
      AwesomeNotifications().requestPermissionToSendNotifications();
    }
  });
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseService().initialize();

  // Initialize shared preferences
  final prefs = await SharedPreferences.getInstance();
  final hasSeenOnBoarding = prefs.getBool("hasSeenOnBoarding") ?? false;
  final isLoggedIn = prefs.getBool("isLoggedIn") ?? false;
  final userEmail = prefs.getString("userEmail") ?? "";

  return {
    'hasSeenOnBoarding': hasSeenOnBoarding,
    'isLoggedIn': isLoggedIn,
    'userEmail': userEmail,
  };
}

void main() async {
  debugPrint('Initializing app...');
  final appState = await initializeApp();
  debugPrint('App initialized with state: $appState');
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) {
          debugPrint('Creating CounterProvider...');
          return CounterProvider();
        }),
        ChangeNotifierProvider(create: (context) {
          debugPrint('Creating WalletProvider...');
          final provider = WalletProvider();
          debugPrint('WalletProvider created');
          return provider;
        }),
        Provider(create: (context) {
          debugPrint('Creating SecondScreen...');
          return SecondScreen();
        }),
      ],
      child: MyApp(appState: appState),
    ),
  );
}

class MyApp extends StatelessWidget {
  final Map<String, dynamic> appState;
  const MyApp({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    debugPrint('Building MyApp...');
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
      title: 'Expenses Tracker',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      routes: {SignupScreen.route: (context) => const SignupScreen()},
      theme: appTheme,
      home: Builder(
        builder: (context) {
          debugPrint('Building home widget...');
          final walletProvider = context.watch<WalletProvider>();
          debugPrint('WalletProvider state: ${walletProvider.transactions.length} transactions');
          
          if (!appState['hasSeenOnBoarding']) {
            debugPrint('Showing onboarding screen...');
            return const FirstScreen();
          } else if (!appState['isLoggedIn']) {
            debugPrint('Showing login screen...');
            return const LoginScreen();
          } else {
            debugPrint('Showing main app screen...');
            return const MyHomePage();
          }
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
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
  final List<Map<String, dynamic>> screens = [
    {'screen': HomeScreen(), 'title': 'Dashboard'},
    {'screen': AnalyticsScreen(), 'title': 'Analytics'},
    {'screen': WalletScreen(), 'title': 'Wallet'},
    {'screen': SettingsScreen(), 'title': 'Settings'},
  ];

  void _showAddTransaction() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => AddExpense()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: Colors.grey.shade50,
      body: screens[currIndex]['screen'] as Widget, // The currently selected screen
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFFB800), // FAB background color
        onPressed: _showAddTransaction,
        child: const Icon(Icons.add, size: 32, color: Colors.black),
        elevation: 8.0, // FAB shadow
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked, // Docks FAB in the center of BottomNavigationBar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currIndex, // Highlights the current tab
        onTap: (index) {
          setState(() {
            currIndex = index; // Updates the selected tab index
          });
        },
        backgroundColor: Colors.white, // Background color of the navigation bar
        selectedItemColor: const Color(0xFF2C1F63), // Color of the selected item's icon and text
        unselectedItemColor: Colors.grey.shade600, // Color of unselected items' icons and text
        type: BottomNavigationBarType.fixed, // Ensures items are evenly spaced and labels are always visible
        showUnselectedLabels: true, // Makes sure labels for unselected items are visible
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet), // Changed to a more common wallet icon
            label: 'Wallet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline), // Changed to a common settings/profile icon
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}