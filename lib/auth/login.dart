import 'package:expenses_tracker/auth/signup.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreen();
}

class _LoginScreen extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Center(
        child: SizedBox(
          width: 300,
          child: Column(
            spacing: 30,
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: "enter an email",
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
              ),
              TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Password",
                  labelText: "Password",
                ),
              ),
              ElevatedButton(onPressed: () {}, child: Text("Login")),
              Row(
                spacing: 40,
                children: [
                  Text("Don't have an account"),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => SignupScreen()),
                      );
                    },
                    child: Text("Signup"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
