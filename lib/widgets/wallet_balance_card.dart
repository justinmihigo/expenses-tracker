import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/wallet_provider.dart';

class WalletBalanceCard extends StatelessWidget {
  final String Function(double) formatAmount;

  const WalletBalanceCard({
    required this.formatAmount,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<WalletProvider>(
      builder: (context, provider, _) {
        final balance = provider.totalBalance;
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              children: [
                const Text(
                  "Total Balance",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text(
                  "Rwf ${formatAmount(balance)}",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: balance >= 0 ? const Color.fromARGB(255, 10, 17, 90) : Colors.red,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}