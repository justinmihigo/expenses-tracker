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
                    TransactionData.formatDateForDisplay(date),
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                ...dateTransactions.map((transaction) => Dismissible(
                  key: ValueKey<String>(transaction.id),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (direction) async {
                    return await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Delete Transaction'),
                          content: const Text('Are you sure you want to delete this transaction?'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text('Delete'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  onDismissed: (direction) {
                    if (onDelete != null) {
                      onDelete!(dateTransactions.indexOf(transaction), transaction);
                    }
                  },
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20.0),
                    color: AppColors.errorColor,
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                  child: _buildTransactionItem(
                    context,
                    transaction,
                    dateTransactions.indexOf(transaction),
                  ),
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

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
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