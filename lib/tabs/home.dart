import "package:flutter/material.dart";
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../providers/wallet_provider.dart';
import '../widgets/wallet/wallet_transaction_item.dart';
import '../screens/notifications_screen.dart';
import '../sqlite.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String userName = '';
  double totalBalance = 0.0;

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _loadTotalBalance();
  }

  String _formatAmount(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return amount.toStringAsFixed(0);
    }
  }

  Future<void> _loadUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        String rawName;
        if (user.displayName != null && user.displayName!.isNotEmpty) {
          rawName = user.displayName!;
        } else if (user.email != null) {
          rawName = user.email!.split('@')[0].replaceAll(RegExp(r'[._]'), ' ');
        } else {
          rawName = 'User';
        }

        final nameParts = rawName.trim().split(RegExp(r'\s+'));
        final formattedParts = nameParts.map((part) {
          if (part.isEmpty) return '';
          return part[0].toUpperCase() + part.substring(1).toLowerCase();
        }).where((part) => part.isNotEmpty).toList();

        if (formattedParts.length > 1) {
          userName = '${formattedParts[0]} ${formattedParts.sublist(1).join(' ')}';
        } else {
          userName = formattedParts.first;
        }
      });
    }
  }

  Future<void> _loadTotalBalance() async {
    final transactions = await SQLiteDB.instance.getTransactions();
    double balance = 0.0;
    
    for (var transaction in transactions) {
      if (transaction['isCredit'] == 1) {
        balance += transaction['amount'] as double;
      } else {
        balance -= transaction['amount'] as double;
      }
    }
    
    setState(() {
      totalBalance = balance;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WalletProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // Calculate income and expenses
        final income = provider.transactions
            .where((t) => t.isCredit)
            .fold(0.0, (sum, t) => sum + t.amount);
            
        final expenses = provider.transactions
            .where((t) => !t.isCredit)
            .fold(0.0, (sum, t) => sum + t.amount);

        // Get recent transactions
        final recentTransactions = List.from(provider.transactions)
          ..sort((a, b) {
            final dateA = _parseDate(a.date);
            final dateB = _parseDate(b.date);
            return dateB.compareTo(dateA);
          })
          ..take(5).toList();

        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          body: RefreshIndicator(
            onRefresh: () async {
              await provider.refreshData();
              await _loadTotalBalance();
            },
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with profile
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.grey.shade200,
                                child: Icon(Icons.person, color: Colors.grey.shade700),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Hello!',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    userName,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          IconButton(
                            icon: Stack(
                              children: [
                                const Icon(Icons.notifications_outlined),
                                if (provider.notifications.any((n) => !n.isRead))
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      constraints: const BoxConstraints(
                                        minWidth: 14,
                                        minHeight: 14,
                                      ),
                                      child: Text(
                                        '${provider.notifications.where((n) => !n.isRead).length}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 8,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => NotificationsScreen(
                                    notifications: provider.notifications,
                                    onNotificationRead: (String id) => 
                                      provider.markNotificationAsRead(id),
                                  ),
                                ),
                              );
                            },
                            iconSize: 24,
                            color: Colors.grey.shade700,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Balance Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2C1F63),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Total Balance',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.8),
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Rwf ${_formatAmount(totalBalance)}',
                                        style: TextStyle(
                                          color: totalBalance >= 0 ? Colors.white : Colors.red,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFB800),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.all(8),
                                  child: const Icon(Icons.add, color: Colors.black, size: 20),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Statistics header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Statistics',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                'Aug',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14,
                                ),
                              ),
                              Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.grey.shade600,
                                size: 20,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Income and Expenses Cards
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE5F5EC),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Income',
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Rwf ${_formatAmount(income)}',
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        size: 14,
                                        color: Colors.grey.shade600,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFBE7E7),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Expenses',
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Rwf ${_formatAmount(expenses)}',
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        size: 14,
                                        color: Colors.grey.shade600,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Recent Transactions
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Recent Transactions',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              // Navigate to transactions history
                            },
                            child: Text(
                              'View all',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Transaction List
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: recentTransactions.length,
                        itemBuilder: (context, index) {
                          final transaction = recentTransactions[index];
                          return WalletTransactionItem(
                            title: transaction.title,
                            date: transaction.date,
                            amount: "${transaction.isCredit ? "+" : "-"}${_formatAmount(transaction.amount)}",
                            isCredit: transaction.isCredit,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
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
