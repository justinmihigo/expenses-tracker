import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/wallet_provider.dart';
import '../models/transaction.dart';
import '../styles/app_colors.dart';

class TransactionsList extends StatelessWidget {
  final Function(TransactionData)? onTransactionTap;
  final Function(int, TransactionData)? onEdit;
  final Function(int, TransactionData)? onDelete;
  final String Function(double)? formatAmount;

  const TransactionsList({
    super.key,
    this.onTransactionTap,
    this.onEdit,
    this.onDelete,
    this.formatAmount,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<WalletProvider>(
      builder: (context, provider, child) {
        final transactions = provider.transactions;
        
        if (transactions.isEmpty) {
          return Center(
            child: Text(
              'No transactions yet',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
          );
        }

        // Group transactions by date
        final groupedTransactions = <DateTime, List<TransactionData>>{};
        for (var transaction in transactions) {
          final date = transaction.parsedDate;
          final dateOnly = DateTime(date.year, date.month, date.day);
          groupedTransactions.putIfAbsent(dateOnly, () => []).add(transaction);
        }

        // Sort dates in descending order
        final sortedDates = groupedTransactions.keys.toList()
          ..sort((a, b) => b.compareTo(a));

        return ListView.builder(
          itemCount: sortedDates.length,
          itemBuilder: (context, index) {
            final date = sortedDates[index];
            final dateTransactions = groupedTransactions[date]!;
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Text(
                    _formatDate(date),
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                ...dateTransactions.map((transaction) => _buildTransactionItem(
                  context,
                  transaction,
                  dateTransactions.indexOf(transaction),
                )),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildTransactionItem(
    BuildContext context,
    TransactionData transaction,
    int index,
  ) {
    final amount = formatAmount?.call(transaction.amount) ?? 
      '\$${transaction.amount.toStringAsFixed(2)}';

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 4.0,
      ),
      child: ListTile(
        onTap: () => onTransactionTap?.call(transaction),
        leading: CircleAvatar(
          backgroundColor: transaction.isCredit ? AppColors.successColor : AppColors.errorColor,
          child: Icon(
            _getCategoryIcon(transaction.category),
            color: AppColors.primary,
          ),
        ),
        title: Text(
          transaction.title,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          transaction.category.toString().split('.').last,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${transaction.isCredit ? "+" : "-"}$amount',
              style: TextStyle(
                color: transaction.isCredit ? AppColors.successColor : AppColors.errorColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              _formatTime(transaction.parsedDate),
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (date == today) {
      return 'Today';
    } else if (date == yesterday) {
      return 'Yesterday';
    } else {
      return TransactionData.formatDateForDisplay(date);
    }
  }

  String _formatTime(DateTime date) {
    // Get the current time for the transaction
    final now = DateTime.now();
    final transactionTime = DateTime(
      date.year,
      date.month,
      date.day,
      now.hour,
      now.minute,
    );
    
    // Format as HH:mm
    return '${transactionTime.hour.toString().padLeft(2, '0')}:${transactionTime.minute.toString().padLeft(2, '0')}';
  }

  IconData _getCategoryIcon(TransactionCategory category) {
    switch (category) {
      case TransactionCategory.salary:
        return Icons.work;
      case TransactionCategory.investment:
        return Icons.trending_up;
      case TransactionCategory.business:
        return Icons.business;
      case TransactionCategory.otherIncome:
        return Icons.attach_money;
      case TransactionCategory.food:
        return Icons.restaurant;
      case TransactionCategory.transportation:
        return Icons.directions_car;
      case TransactionCategory.housing:
        return Icons.home;
      case TransactionCategory.utilities:
        return Icons.power;
      case TransactionCategory.entertainment:
        return Icons.movie;
      case TransactionCategory.healthcare:
        return Icons.medical_services;
      case TransactionCategory.education:
        return Icons.school;
      case TransactionCategory.shopping:
        return Icons.shopping_bag;
      case TransactionCategory.travel:
        return Icons.flight;
      case TransactionCategory.others:
        return Icons.category;
    }
  }
}