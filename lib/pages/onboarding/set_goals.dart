import 'package:expenses_tracker/pages/onboarding/goal_tracking.dart';
import 'package:flutter/material.dart';

class SpendingLimitScreen extends StatefulWidget {
  const SpendingLimitScreen({super.key});

  @override
  State<SpendingLimitScreen> createState() => _SpendingLimitScreenState();
}

class _SpendingLimitScreenState extends State<SpendingLimitScreen> {
  final TextEditingController _limitController = TextEditingController();
  double _spendingLimit = 0.0;
  double _currentSpending = 0.0;

  void _saveLimit() {
    if (_limitController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Please enter a spending limit")));
      return;
    }

    setState(() {
      _spendingLimit = double.tryParse(_limitController.text) ?? 0.0;
      _currentSpending = 0.0; // Reset spending when a new limit is set
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Spending limit set to \$$_spendingLimit")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back button and title
            Padding(
              padding: const EdgeInsets.only(top: 48.0, left: 16.0, right: 16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.of(context).pop();
                      _currentSpending;
                    },
                  ),
                  const Text(
                    "Set Spending Limit",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 20,
                children: [
                  Text("What's your Income:", style: TextStyle(fontSize: 16)),
                  TextField(
                    controller: _limitController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "e.g., 500",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  // Input for spending limit
                  Text(
                    "Enter your spending limit:",
                    style: TextStyle(fontSize: 16),
                  ),
                  TextField(
                    controller: _limitController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "e.g., 500",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Save Button
                  Center(
                    child: ElevatedButton(
                      onPressed: _saveLimit,

                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      ),
                      child: Text("Set Limit"),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => GoalTracking()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      ),
                      child: Text("Check your goals"),
                    ),
                  ),

                  // Progress Bar
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
