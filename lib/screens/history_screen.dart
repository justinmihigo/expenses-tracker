import 'package:flutter/material.dart';
import '../tabs/wallet.dart';

class HistoryScreen extends StatelessWidget {
  final List<TransactionData> transactions;
  final List<TransactionData> upcomingBills;

  const HistoryScreen({
    required this.transactions,
    required this.upcomingBills,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Combine and sort all transactions by date
    final allTransactions = [...transactions, ...upcomingBills];
    allTransactions.sort((a, b) {
      DateTime dateA = _parseDate(a.date);
      DateTime dateB = _parseDate(b.date);
      return dateB.compareTo(dateA); // Sort in descending order (newest first)
    });

    // Group transactions by date
    final groupedTransactions = <String, List<TransactionData>>{};
    for (var transaction in allTransactions) {
      final date = transaction.date;
      if (!groupedTransactions.containsKey(date)) {
        groupedTransactions[date] = [];
      }
      groupedTransactions[date]!.add(transaction);
    }

    // Sort dates to ensure newest first
    final sortedDates = groupedTransactions.keys.toList()
      ..sort((a, b) {
        DateTime dateA = _parseDate(a);
        DateTime dateB = _parseDate(b);
        return dateB.compareTo(dateA);
      });

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text(
          "Transaction History",
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: allTransactions.isEmpty
          ? const Center(
              child: Text(
                "No transactions found",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sortedDates.length,
              itemBuilder: (context, dateIndex) {
                final date = sortedDates[dateIndex];
                final dateTransactions = groupedTransactions[date]!;
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date header
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        date,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    // Transactions for this date
                    ...dateTransactions.map((transaction) => Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: transaction.isCredit
                              ? Colors.green.shade100
                              : Colors.red.shade100,
                          child: Icon(
                            transaction.isCredit
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            color: transaction.isCredit ? Colors.green : Colors.red,
                          ),
                        ),
                        title: Text(
                          transaction.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: transaction.isScheduled
                            ? Text(
                                "Scheduled Bill",
                                style: TextStyle(
                                  color: Colors.orange.shade700,
                                  fontSize: 12,
                                ),
                              )
                            : null,
                        trailing: Text(
                          (transaction.isCredit ? "+" : "-") +
                              "${transaction.amount.toStringAsFixed(2)}",
                          style: TextStyle(
                            color: transaction.isCredit ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )).toList(),
                    if (dateIndex < sortedDates.length - 1)
                      const Divider(height: 24),
                  ],
                );
              },
            ),
    );
  }

  DateTime _parseDate(String dateStr) {
    if (dateStr == "Today") {
      return DateTime.now();
    } else if (dateStr == "Yesterday") {
      return DateTime.now().subtract(const Duration(days: 1));
    } else {
      // Parse date in format "MMM DD, YYYY"
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