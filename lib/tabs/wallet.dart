import 'dart:async';
import 'package:expenses_tracker/pages/test_transaction_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/wallet_provider.dart';
import '../screens/notifications_screen.dart';
import '../widgets/wallet_balance_card.dart';
import '../widgets/wallet_actions.dart';
import '../widgets/transactions_list.dart';
import '../widgets/upcoming_bills_list.dart';
import '../widgets/transaction_form.dart';
import '../sqlite.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  int selectedIndex = 0;
  Timer? _upcomingBillsCheckTimer;
  double totalBalance = 0.0;

  @override
  void initState() {
    super.initState();
    _loadTotalBalance();
    _upcomingBillsCheckTimer = Timer.periodic(
      const Duration(hours: 1),
      (_) => context.read<WalletProvider>().checkUpcomingBills(),
    );
  }

  @override
  void dispose() {
    _upcomingBillsCheckTimer?.cancel();
    super.dispose();
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

  Future<void> _handleRefresh() async {
    final provider = context.read<WalletProvider>();
    await provider.refreshData();
    await _loadTotalBalance();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WalletProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return Scaffold(
            backgroundColor: Colors.grey.shade100,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          backgroundColor: Colors.grey.shade100,
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(120),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              child: AppBar(
                backgroundColor: Theme.of(context).colorScheme.primary,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                title: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Wallet",
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ),
                actions: [
                  if (provider.needsSync)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: IconButton(
                        icon: const Icon(Icons.sync, color: Colors.white70),
                        onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(builder: (context) => const TestTransactionPage()));

                          // provider.refreshData();
                          // ScaffoldMessenger.of(context).showSnackBar(
                          //   const SnackBar(
                          //     content: Text('Syncing data...'),
                          //     duration: Duration(seconds: 2),
                          //   ),
                          // );
                        },
                      ),
                    ),
                  Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications, color: Colors.white),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NotificationsScreen(
                                notifications: provider.notifications,
                                onNotificationRead: (String id) => provider.markNotificationAsRead(id),
                              ),
                            ),
                          );
                        },
                      ),
                      if (provider.notifications.any((n) => !n.isRead))
                        Positioned(
                          right: 8,
                          top: 8,
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
                ],
                toolbarHeight: 120,
              ),
            ),
          ),
          body: RefreshIndicator(
            onRefresh: _handleRefresh,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  WalletBalanceCard(
                    balance: totalBalance,
                    formatAmount: _formatAmount,
                  ),
                  if (provider.needsSync)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Some changes haven\'t been synced yet',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                  WalletActions(
                    onTransactionAdded: (transaction) {
                      provider.addTransaction(transaction);
                      _loadTotalBalance();
                    },
                    transactions: provider.transactions,
                    upcomingBills: provider.upcomingBills,
                  ),
                  const SizedBox(height: 20),
                  ToggleButtons(
                    borderRadius: BorderRadius.circular(10),
                    selectedColor: Colors.white,
                    fillColor: Theme.of(context).colorScheme.primary,
                    isSelected: [selectedIndex == 0, selectedIndex == 1],
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        child: Text("Transactions"),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        child: Text("Upcoming Bills"),
                      ),
                    ],
                    onPressed: (int index) {
                      setState(() => selectedIndex = index);
                    },
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: selectedIndex == 0
                        ? TransactionsList(
                            transactions: provider.transactions,
                            formatAmount: _formatAmount,
                            onEdit: (index, transaction) => showDialog(
                              context: context,
                              builder: (context) => TransactionForm(
                                initialData: transaction,
                                isEditing: true,
                                onSave: (updatedTransaction) {
                                  provider.updateTransaction(transaction, updatedTransaction);
                                  _loadTotalBalance();
                                  Navigator.of(context).pop();
                                },
                                onClose: () => Navigator.of(context).pop(),
                              ),
                            ),
                            onDelete: (index, transaction) => showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Confirm Delete'),
                                content: Text('Are you sure you want to delete this transaction?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    child: Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      provider.deleteTransaction(transaction);
                                      _loadTotalBalance();
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Delete', style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : UpcomingBillsList(
                            upcomingBills: provider.upcomingBills,
                            formatAmount: _formatAmount,
                            onEdit: (index, bill) => showDialog(
                              context: context,
                              builder: (context) => TransactionForm(
                                initialData: bill,
                                isEditing: true,
                                onSave: (updatedBill) {
                                  provider.updateTransaction(bill, updatedBill);
                                  _loadTotalBalance();
                                  Navigator.of(context).pop();
                                },
                                onClose: () => Navigator.of(context).pop(),
                              ),
                            ),
                            onDelete: (index, bill) => showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Confirm Delete'),
                                content: Text('Are you sure you want to delete this bill?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    child: Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      provider.deleteTransaction(bill);
                                      _loadTotalBalance();
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Delete', style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
