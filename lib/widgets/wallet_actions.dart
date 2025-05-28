import 'package:expenses_tracker/tabs/add_expense.dart';
import 'package:flutter/material.dart';
import '../screens/savings_screen.dart';
import '../screens/history_screen.dart';
import '../models/transaction.dart';
import '../widgets/transaction_form.dart';
import 'package:provider/provider.dart';
import '../providers/wallet_provider.dart';
import '../styles/app_colors.dart';

class WalletActions extends StatelessWidget {
  const WalletActions({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WalletProvider>();
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        WalletActionButton(
          icon: Icons.add,
          label: "Add Transaction",
          onPressed: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const AddExpense()),
            );
            // Refresh data when returning from add expense screen
            if (context.mounted) {
              await provider.refreshData();
            }
          }
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
                  transactions: provider.transactions,
                  upcomingBills: provider.upcomingBills,
                ),
              ),
            );
          },
        ),
      ],
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
          Icon(
            icon,
            size: 32,
            color: AppColors.primary,
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}