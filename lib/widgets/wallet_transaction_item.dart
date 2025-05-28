import 'package:flutter/material.dart';
import '../models/transaction.dart';

class WalletTransactionItem extends StatelessWidget {
  final String title;
  final String date;
  final String amount;
  final bool isCredit;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final TransactionCategory? category;

  const WalletTransactionItem({
    required this.title,
    required this.date,
    required this.amount,
    required this.isCredit,
    this.onEdit,
    this.onDelete,
    this.category,
    super.key,
  });

  IconData _getCategoryIcon() {
    if (isCredit) {
      switch (category) {
        case TransactionCategory.salary:
          return Icons.work;
        case TransactionCategory.investment:
          return Icons.trending_up;
        case TransactionCategory.business:
          return Icons.business;
        case TransactionCategory.otherIncome:
          return Icons.attach_money;
        default:
          return Icons.arrow_upward;
      }
    }
    
    switch (category) {
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
      default:
        return Icons.arrow_downward;
    }
  }

  Color _getCategoryColor() {
    if (isCredit) {
      switch (category) {
        case TransactionCategory.salary:
          return Colors.green;
        case TransactionCategory.investment:
          return Colors.teal;
        case TransactionCategory.business:
          return Colors.blue;
        case TransactionCategory.otherIncome:
          return Colors.lightGreen;
        default:
          return Colors.green;
      }
    }
    
    switch (category) {
      case TransactionCategory.food:
        return Colors.orange;
      case TransactionCategory.transportation:
        return Colors.blue;
      case TransactionCategory.housing:
        return Colors.purple;
      case TransactionCategory.utilities:
        return Colors.amber;
      case TransactionCategory.entertainment:
        return Colors.pink;
      case TransactionCategory.healthcare:
        return Colors.red;
      case TransactionCategory.education:
        return Colors.indigo;
      case TransactionCategory.shopping:
        return Colors.deepPurple;
      case TransactionCategory.travel:
        return Colors.cyan;
      default:
        return Colors.grey;
    }
  }

  String _getCategoryName() {
    if (category == null) return '';
    final name = category.toString().split('.').last;
    return name[0].toUpperCase() + name.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor();
    final categoryIcon = _getCategoryIcon();
    final categoryName = _getCategoryName();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: CircleAvatar(
                backgroundColor: categoryColor.withOpacity(0.1),
                child: Icon(
                  categoryIcon,
                  color: categoryColor,
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        date,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                      if (categoryName.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: categoryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            categoryName,
                            style: TextStyle(
                              fontSize: 12,
                              color: categoryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  amount,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isCredit ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
            if (onEdit != null || onDelete != null)
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: Colors.grey.shade600),
                itemBuilder: (context) => [
                  if (onEdit != null)
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                  if (onDelete != null)
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                ],
                onSelected: (value) {
                  if (value == 'edit' && onEdit != null) {
                    onEdit!();
                  } else if (value == 'delete' && onDelete != null) {
                    onDelete!();
                  }
                },
              ),
          ],
        ),
      ),
    );
  }
}