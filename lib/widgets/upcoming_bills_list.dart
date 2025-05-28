import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/wallet_provider.dart';
import '../models/transaction.dart';
import '../styles/app_colors.dart';

class UpcomingBillsList extends StatelessWidget {
  final Function(TransactionData)? onBillTap;
  final Function(int, TransactionData)? onEdit;
  final Function(int, TransactionData)? onDelete;
  final String Function(double)? formatAmount;

  const UpcomingBillsList({
    super.key,
    this.onBillTap,
    this.onEdit,
    this.onDelete,
    this.formatAmount,
  });

  String _formatDueDate(DateTime? scheduledDate) {
    if (scheduledDate == null) return 'No date set';
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final scheduledDay = DateTime(scheduledDate.year, scheduledDate.month, scheduledDate.day);
    
    if (scheduledDay == today) {
      return 'Due Today';
    } else if (scheduledDay == tomorrow) {
      return 'Due Tomorrow';
    } else {
      return 'Due ${scheduledDate.day}/${scheduledDate.month}/${scheduledDate.year}';
    }
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

  Widget _buildBillItem(
    BuildContext context,
    TransactionData bill,
    int index,
  ) {
    final amount = formatAmount?.call(bill.amount) ?? 
      '\$${bill.amount.toStringAsFixed(2)}';

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 4.0,
      ),
      child: ListTile(
        onTap: () => onBillTap?.call(bill),
        leading: CircleAvatar(
          backgroundColor: AppColors.warningColor,
          child: Icon(
            _getCategoryIcon(bill.category),
            color: AppColors.primary,
          ),
        ),
        title: Text(
          bill.title,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          bill.category.toString().split('.').last,
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
              '-$amount',
              style: TextStyle(
                color: AppColors.errorColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              _formatTime(DateTime.parse(bill.date)),
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

  @override
  Widget build(BuildContext context) {
    return Consumer<WalletProvider>(
      builder: (context, provider, _) {
        final upcomingBills = provider.upcomingBills;
        
        if (upcomingBills.isEmpty) {
          return Center(
            child: Text(
              'No upcoming bills',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
          );
        }

        // Group bills by due date
        final groupedBills = <String, List<TransactionData>>{};
        for (var bill in upcomingBills) {
          final dueDate = _formatDueDate(bill.scheduledDate);
          groupedBills.putIfAbsent(dueDate, () => []).add(bill);
        }

        // Sort due dates
        final sortedDueDates = groupedBills.keys.toList()
          ..sort((a, b) {
            if (a == 'Due Today') return -1;
            if (b == 'Due Today') return 1;
            if (a == 'Due Tomorrow') return -1;
            if (b == 'Due Tomorrow') return 1;
            if (a == 'No date set') return 1;
            if (b == 'No date set') return -1;
            
            final dateA = DateTime.parse(a.replaceAll('Due ', ''));
            final dateB = DateTime.parse(b.replaceAll('Due ', ''));
            return dateA.compareTo(dateB);
          });

        return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: sortedDueDates.length,
          itemBuilder: (context, dateIndex) {
            final dueDate = sortedDueDates[dateIndex];
            final dateBills = groupedBills[dueDate]!;
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Text(
                    dueDate,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                ...dateBills.map((bill) => _buildBillItem(
                  context,
                  bill,
                  dateBills.indexOf(bill),
                )),
              ],
            );
          },
        );
      },
    );
  }
}