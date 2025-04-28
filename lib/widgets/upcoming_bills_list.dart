import 'package:flutter/material.dart';
import '../models/transaction.dart';
import 'wallet_transaction_item.dart';

class UpcomingBillsList extends StatelessWidget {
  final List<TransactionData> upcomingBills;
  final Function(int index, TransactionData bill) onEdit;
  final Function(int index, TransactionData bill) onDelete;
  final String Function(double) formatAmount;

  const UpcomingBillsList({
    required this.upcomingBills,
    required this.onEdit,
    required this.onDelete,
    required this.formatAmount,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (upcomingBills.isEmpty) {
      return const Center(
        child: Text(
          "No upcoming bills",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    final sortedBills = List<TransactionData>.from(upcomingBills)
      ..sort((a, b) {
        if (a.scheduledDate == null || b.scheduledDate == null) return 0;
        return a.scheduledDate!.compareTo(b.scheduledDate!);
      });

    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: sortedBills.length,
      itemBuilder: (context, index) {
        final bill = sortedBills[index];
        return WalletTransactionItem(
          title: bill.title,
          date: bill.date,
          amount: "-${formatAmount(bill.amount)}",
          isCredit: false,
          onEdit: () => onEdit(
            upcomingBills.indexOf(bill),
            bill,
          ),
          onDelete: () => onDelete(
            upcomingBills.indexOf(bill),
            bill,
          ),
        );
      },
    );
  }
}