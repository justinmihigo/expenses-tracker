import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expenses_tracker/auth/login.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isDarkMode = false;
  bool isNotificationsEnabled = true;
  String currency = 'Rwf';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? false;
      isNotificationsEnabled = prefs.getBool('isNotificationsEnabled') ?? true;
      currency = prefs.getString('currency') ?? 'Rwf';
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDarkMode);
    await prefs.setBool('isNotificationsEnabled', isNotificationsEnabled);
    await prefs.setString('currency', currency);
  }

    Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('userEmail');
    
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      await _logout();
      // Navigate to login screen or handle sign out
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error signing out')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: ListView(
        children: [
          const SizedBox(height: 16),
          // Back button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
               
                const Text(
                  'Settings',
                  style: TextStyle(
                    color: Color(0xFF2C1F63),
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Profile Section
          ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF2C1F63),
              child: const Icon(Icons.person, color: Colors.white),
            ),
            title: Text(
              FirebaseAuth.instance.currentUser?.displayName ?? 'User',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Text(
              FirebaseAuth.instance.currentUser?.email ?? '',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          // const Divider(),
          
          // // Appearance Section
          // const Padding(
          //   padding: EdgeInsets.all(16.0),
          //   child: Text(
          //     'Appearance',
          //     style: TextStyle(
          //       color: Color(0xFF2C1F63),
          //       fontWeight: FontWeight.bold,
          //       fontSize: 16,
          //     ),
          //   ),
          // ),
          // SwitchListTile(
          //   title: const Text('Dark Mode'),
          //   subtitle: const Text('Enable dark theme'),
          //   value: isDarkMode,
          //   onChanged: (value) {
          //     setState(() {
          //       isDarkMode = value;
          //       _saveSettings();
          //     });
          //   },
          //   activeColor: const Color(0xFF2C1F63),
          // ),
          // const Divider(),

          // Notifications Section
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Notifications',
              style: TextStyle(
                color: Color(0xFF2C1F63),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          SwitchListTile(
            title: const Text('Enable Notifications'),
            subtitle: const Text('Receive alerts for bills and updates'),
            value: isNotificationsEnabled,
            onChanged: (value) {
              setState(() {
                isNotificationsEnabled = value;
                _saveSettings();
              });
            },
            activeColor: const Color(0xFF2C1F63),
          ),
          const Divider(),

          // Currency Section
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Currency',
              style: TextStyle(
                color: Color(0xFF2C1F63),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          ListTile(
            title: const Text('Default Currency'),
            subtitle: Text(currency),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Select Currency'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        title: const Text('Rwf'),
                        onTap: () {
                          setState(() {
                            currency = 'Rwf';
                            _saveSettings();
                          });
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        title: const Text('USD'),
                        onTap: () {
                          setState(() {
                            currency = 'USD';
                            _saveSettings();
                          });
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        title: const Text('EUR'),
                        onTap: () {
                          setState(() {
                            currency = 'EUR';
                            _saveSettings();
                          });
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const Divider(),

          // Account Section
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Account',
              style: TextStyle(
                color: Color(0xFF2C1F63),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Sign Out',
              style: TextStyle(color: Colors.red),
            ),
            onTap: _signOut,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
} 