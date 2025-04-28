import 'package:flutter/material.dart';

class WalletBalanceCard extends StatelessWidget {
  final double balance;
  final String Function(double) formatAmount;

  const WalletBalanceCard({
    required this.balance,
    required this.formatAmount,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            Text(
              "Total Balance",
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              "Rwf ${formatAmount(balance)}",
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: balance >= 0 ? const Color.fromARGB(255, 10, 17, 90) : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}