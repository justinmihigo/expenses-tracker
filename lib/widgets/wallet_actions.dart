import 'package:flutter/material.dart';
import '../screens/savings_screen.dart';
import '../screens/history_screen.dart';
import '../models/transaction.dart';
import '../widgets/transaction_form.dart';

class WalletActions extends StatelessWidget {
  final Function(TransactionData) onTransactionAdded;
  final List<TransactionData> transactions;
  final List<TransactionData> upcomingBills;

  const WalletActions({
    required this.onTransactionAdded,
    required this.transactions,
    required this.upcomingBills,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        WalletActionButton(
          icon: Icons.add,
          label: "Add Transaction",
          onPressed: () => _showAddTransactionDialog(context),
        ),
        WalletActionButton(
          icon: Icons.savings,
          label: "Savings",
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SavingsScreen(),
              ),
            );
          },
        ),
        WalletActionButton(
          icon: Icons.history,
          label: "History",
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HistoryScreen(
                  transactions: transactions,
                  upcomingBills: upcomingBills,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  void _showAddTransactionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return TransactionForm(
          onSave: onTransactionAdded,
          onClose: () => Navigator.of(context).pop(),
        );
      },
    );
  }
}

class WalletActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const WalletActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Icon(icon, color: Theme.of(context).colorScheme.onSecondary),
          ),
          const SizedBox(height: 5),
          Text(label, style: TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}