import 'package:expenses_tracker/sqlite.dart';
import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override
  State<SignupScreen> createState() => _SignupScreen();
}

class _SignupScreen extends State<SignupScreen> {
  final dbQueries = Sqlite();
  String _lastMessage = '';
  @override
  void initState() {
    dbQueries.firebaseInit();
    super.initState();
  }

  _SignupScreen() {
    dbQueries.messageStreamController.listen((message) {
      if (message.notification != null) {
        _lastMessage =
            'Received message'
            '\nTitle: ${message.notification?.title}'
            '\nBody ${message.notification?.body}';
        '\nData ${message.data}';
      } else {
        _lastMessage = 'Received message ${message.data}';
      }
    });
  }
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

  Future<void> handleSignup() async {
    // var user = User(
    //   email: emailController.text.trim(),
    //   name: nameController.text.trim(),
    //   password: passwordController.text.trim(),
    // );

    // await dbQueries.insert(user);
    // debugPrint("User added: ${user.toString()}");

    // List<User> users = await dbQueries.listUsers();
    // debugPrint("All Users: $users");

    // await dbQueries.signup(emailController.text, passwordController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Signup")),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(10),
          width: 300,
          child: Column(
            spacing: 30,
            children: [
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
              Text(_lastMessage),
              ElevatedButton(
                onPressed: () {
                  handleSignup();
                },
                child: Text("Signup"),
              ),
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
