import 'package:flutter/material.dart';

class WalletTransactionItem extends StatelessWidget {
  final String title;
  final String date;
  final String amount;
  final bool isCredit;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const WalletTransactionItem({
    required this.title,
    required this.date,
    required this.amount,
    required this.isCredit,
    this.onEdit,
    this.onDelete,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: CircleAvatar(
                backgroundColor: isCredit ? Colors.green.shade100 : Colors.red.shade100,
                child: Icon(
                  isCredit ? Icons.arrow_upward : Icons.arrow_downward,
                  color: isCredit ? Colors.green : Colors.red,
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.w600)),
                  Text(date, style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            Text(
              amount,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isCredit ? Colors.green : Colors.red,
              ),
            ),
            if (onEdit != null)
              IconButton(
                icon: Icon(Icons.edit, size: 20, color: Colors.grey.shade600),
                onPressed: onEdit,
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
              ),
            if (onDelete != null)
              IconButton(
                icon: Icon(Icons.delete, size: 20, color: Colors.blue.shade600),
                onPressed: onDelete,
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.only(left: 8.0, right: 12.0),
              ),
          ],
        ),
      ),
    );
  }
}