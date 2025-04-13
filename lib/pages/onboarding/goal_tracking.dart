import 'package:flutter/material.dart';

class GoalTracking extends StatefulWidget {
  const GoalTracking({super.key});
  @override
  State<GoalTracking> createState() => _GoalTrackingState();
}

class _GoalTrackingState extends State<GoalTracking> {
  double _spendingLimit = 0.0;
  double _currentSpending = 0.0;
  void _updateSpending(double amount) {
    setState(() {
      _currentSpending += amount;
    });

    if (_currentSpending > _spendingLimit) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Warning: You have exceeded your spending limit!"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext build) {
    double progress =
        _spendingLimit == 0 ? 0 : (_currentSpending / _spendingLimit);
    return Scaffold(
      appBar: AppBar(title: Text("Goal Tracking")),
      body: Center(
        child: Column(
          children: [
            Text("Spending Progress", style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            CircularProgressIndicator(
              value:
                  progress > 1
                      ? 1
                      : progress, // Ensure it doesn't go beyond 100%
              strokeWidth: 8,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                _currentSpending > _spendingLimit ? Colors.red : Colors.green,
              ),
            ),
            const SizedBox(height: 20),

            // Display Spending Details
            Text(
              "Limit: \$$_spendingLimit",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              "Spent: \$$_currentSpending",
              style: TextStyle(fontSize: 16, color: Colors.blue),
            ),
            const SizedBox(height: 20),

            // Button to Simulate Adding an Expense
            Center(
              child: ElevatedButton(
                onPressed: () {
                  _updateSpending(50); // Simulating an expense of $50
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  backgroundColor: Colors.orange,
                ),
                child: Text("Add \$50 Expense"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
