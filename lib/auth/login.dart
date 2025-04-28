import 'package:expenses_tracker/api/firebase_api.dart';
import 'package:expenses_tracker/auth/signup.dart';
import 'package:expenses_tracker/main.dart';
import 'package:expenses_tracker/styles/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return LoginScreenState();
  }
}

class LoginScreenState extends StatefulWidget {
  const LoginScreenState({super.key});
  @override
  State<LoginScreenState> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreenState> {
  bool response = false;
  final firebaseApi = FirebaseApi();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  Future<bool?> handleSignin() async {
    final login = await firebaseApi.login(
      emailController.text.trim(),
      passwordController.text.trim(),
    );
    debugPrint(emailController.text.trim());
    debugPrint(passwordController.text.trim());

    if (login) {
      setState(() {
        response = login;
      });
    }
    return response;
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
          child: SizedBox(
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
                    "Login into your account",
                    style: TextStyle(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
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
                  obscureText: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Password",
                    labelText: "Password",
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await handleSignin();
                    debugPrint(response.toString());
                    if (response) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => MyHomePage(title: 'Home'),
                        ),
                      );
                    }
                  },
                  child: Text(
                    "Login",
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
                Text(
                  "or Sign in with",
                  style: TextStyle(color: AppColors.secondary),
                ),
                InkWell(
                  onTap: () async {
                    final response = await firebaseApi.loginWithGoogle();
                    if (response!) {
                      Fluttertoast.showToast(msg: "Login successful");
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => MyHomePage(title: "Home"),
                        ),
                      );
                    } else {
                      Fluttertoast.showToast(msg: "Failed to login");
                    }
                  },
                  child: Image.asset(
                    "assets/logos/google-logo.png",
                    width: 50,
                    height: 50,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 40),
                  child: Row(
                    spacing: 10,
                    children: [
                      Text(
                        "Don't have an account",
                        style: TextStyle(color: AppColors.secondary),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => SignupScreen(),
                            ),
                          );
                        },
                        child: Text(
                          "Signup",
                          style: TextStyle(
                            color: AppColors.accent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
