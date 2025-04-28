import 'package:flutter/material.dart';
import '../models/transaction.dart';
import 'wallet_transaction_item.dart';

class TransactionsList extends StatelessWidget {
  final List<TransactionData> transactions;
  final Function(int index, TransactionData transaction) onEdit;
  final Function(int index, TransactionData transaction) onDelete;
  final String Function(double) formatAmount;

  const TransactionsList({
    required this.transactions,
    required this.onEdit,
    required this.onDelete,
    required this.formatAmount,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const Center(
        child: Text(
          "No transactions yet",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    final sortedTransactions = List<TransactionData>.from(transactions)
      ..sort((a, b) {
        DateTime dateA = _parseDate(a.date);
        DateTime dateB = _parseDate(b.date);
        return dateB.compareTo(dateA);
      });

    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: sortedTransactions.length,
      itemBuilder: (context, index) {
        final transaction = sortedTransactions[index];
        return WalletTransactionItem(
          title: transaction.title,
          date: transaction.date,
          amount: "${transaction.isCredit ? "+" : "-"}${formatAmount(transaction.amount)}",
          isCredit: transaction.isCredit,
          onEdit: () => onEdit(
            transactions.indexOf(transaction),
            transaction,
          ),
          onDelete: () => onDelete(
            transactions.indexOf(transaction),
            transaction,
          ),
        );
      },
    );
  }

  DateTime _parseDate(String dateStr) {
    if (dateStr == "Today") {
      return DateTime.now();
    } else if (dateStr == "Yesterday") {
      return DateTime.now().subtract(const Duration(days: 1));
    } else {
      final months = {
        'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6,
        'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12
      };
      
      final parts = dateStr.split(' ');
      final month = months[parts[0]] ?? 1;
      final day = int.parse(parts[1].replaceAll(',', ''));
      final year = int.parse(parts[2]);
      
      return DateTime(year, month, day);
    }
  }
}