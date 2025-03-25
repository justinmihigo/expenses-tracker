import 'package:expenses_tracker/api/firebase_api.dart';
import 'package:expenses_tracker/api/sqlite.dart';
import 'package:expenses_tracker/auth/login.dart';
import 'package:expenses_tracker/main.dart';
import 'package:expenses_tracker/styles/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  static const route = "/signup";
  @override
  State<SignupScreen> createState() => _SignupScreen();
}

class _SignupScreen extends State<SignupScreen> {
  final dbQueries = Sqlite();
  final firebaseApi = FirebaseApi();
  bool response = false;
  // Fix: Initialize controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    // Fix: Dispose controllers to prevent memory leaks
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<bool?> handleSignup() async {
    var user = User(
      email: emailController.text.trim(),
      name: nameController.text.trim(),
      password: passwordController.text.trim(),
    );

    await dbQueries.insert(user);
    debugPrint("User added: ${user.toString()}");

    List<User> users = await dbQueries.listUsers();
    debugPrint("All Users: $users");
    final res = await firebaseApi.signup(
      emailController.text,
      passwordController.text,
    );

    setState(() {
      response = res;
      debugPrint('Response $response');
    });
    if (response) {
      return Fluttertoast.showToast(msg: "User created successfully");
    } else {
      return Fluttertoast.showToast(
        msg: "Failed to create user",
        backgroundColor: Colors.redAccent,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            padding: EdgeInsets.all(10),
            width: 300,
            child: Column(
              spacing: 30,

              children: [
                SizedBox(
                  width: 150,
                  height: 50,
                  child: ClipRRect(
                    child: Image.asset(
                      "assets/logos/trackit-black.png",
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "Create a new account",
                    style: TextStyle(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: "enter an your name",
                    labelText: "Full name",
                    border: OutlineInputBorder(),
                  ),
                ),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    hintText: "enter an email",
                    labelText: "Email",
                    border: OutlineInputBorder(),
                  ),
                ),
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Password",
                    labelText: "Password",
                  ),
                ),

                ElevatedButton(
                  onPressed: () {
                    handleSignup();
                    if (response) {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    }
                  },

                  child: Text(
                    "Signup",
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
                Text(
                  "or Sign up with",
                  style: TextStyle(color: AppColors.secondary),
                ),
                InkWell(
                  onTap: () async {
                    final response = await firebaseApi.loginWithGoogle();
                    if (response!) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => MyHomePage(title: "Home"),
                        ),
                      );
                    }
                  },
                  child: Image.asset(
                    "assets/logos/google-logo.png",
                    width: 50,
                    height: 50,
                  ),
                ),
                Row(
                  spacing: 10,
                  children: [
                    Text(
                      "Don't have an account?",
                      style: TextStyle(color: AppColors.secondary),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => LoginScreen(),
                          ),
                        );
                      },
                      child: Text(
                        "Login",
                        style: TextStyle(
                          color: AppColors.accent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
