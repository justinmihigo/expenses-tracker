import 'dart:async';
import 'package:expenses_tracker/screens/notifications_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/wallet_provider.dart';
import '../widgets/wallet_balance_card.dart';
import '../widgets/wallet_actions.dart';
import '../widgets/transactions_list.dart';
import '../widgets/upcoming_bills_list.dart';
import '../widgets/transaction_form.dart';
import '../sqlite.dart';
import '../styles/app_colors.dart';
import '../models/transaction.dart';
import '../services/notification_service.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  int selectedIndex = 0;
  Timer? _refreshTimer;
  Timer? _upcomingBillsCheckTimer;
  final _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    debugPrint('WalletScreen.initState() called');
    _initializeData();
    _initializeNotifications();
    
    // Set up periodic refresh every 30 seconds
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) {
        debugPrint('WalletScreen: Periodic refresh triggered');
        _handleRefresh();
      },
    );

    // Check upcoming bills every hour
    _upcomingBillsCheckTimer = Timer.periodic(
      const Duration(hours: 1),
      (_) {
        debugPrint('WalletScreen: Checking upcoming bills');
        context.read<WalletProvider>().checkUpcomingBills();
      },
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _upcomingBillsCheckTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeData() async {
    debugPrint('WalletScreen: Initializing data...');
    final provider = context.read<WalletProvider>();
    await provider.refreshData();
    debugPrint('WalletScreen: Data refreshed, transactions count: ${provider.transactions.length}');
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _initializeNotifications() async {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'transactions',
          channelName: 'Transaction Notifications',
          channelDescription: 'Notifications for transaction updates',
          defaultColor: const Color(0xFF2C1F63),
          ledColor: Colors.white,
          importance: NotificationImportance.High,
          channelShowBadge: true,
          enableVibration: true,
          enableLights: true,
        ),
      ],
    );

    // Request permission to show notifications
    await AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
  }

  String _formatAmount(double amount) {
    return amount.toStringAsFixed(2);
  }

  Future<void> _handleRefresh() async {
    debugPrint('WalletScreen: Handling refresh...');
    final provider = context.read<WalletProvider>();
    await provider.refreshData();
    debugPrint('WalletScreen: Refresh completed, transactions count: ${provider.transactions.length}');
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _handleEditTransaction(TransactionData transaction) async {
    await showDialog(
      context: context,
      builder: (context) => TransactionForm(
        initialData: transaction,
        isEditing: true,
        onSave: (updatedTransaction) async {
          await context.read<WalletProvider>().updateTransaction(
            transaction,
            updatedTransaction,
          );
        },
        onClose: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }

  Future<void> _handleDeleteTransaction(TransactionData transaction) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: Text('Are you sure you want to delete "${transaction.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.errorColor,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<WalletProvider>().deleteTransaction(transaction);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        elevation: 0,
        title: const Text(
          'Wallet',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: AppColors.primary),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotificationsScreen(
                    notifications: context.read<WalletProvider>().notifications,
                    onNotificationRead: (id) async {
                      await context.read<WalletProvider>().markNotificationAsRead(id);
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.secondary,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                WalletBalanceCard(formatAmount: _formatAmount),
                const SizedBox(height: 24),
                const WalletActions(),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => selectedIndex = 0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: selectedIndex == 0
                                  ? AppColors.secondary
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Transactions',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: selectedIndex == 0
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => selectedIndex = 1),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: selectedIndex == 1
                                  ? AppColors.secondary
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Upcoming Bills',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: selectedIndex == 1
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _handleRefresh,
                    child: selectedIndex == 0
                        ? TransactionsList(
                            formatAmount: _formatAmount,
                            onTransactionTap: (transaction) {
                              _handleEditTransaction(transaction);
                            },
                            onEdit: (index, transaction) {
                              _handleEditTransaction(transaction);
                            },
                            onDelete: (index, transaction) {
                              _handleDeleteTransaction(transaction);
                            },
                          )
                        : UpcomingBillsList(
                            formatAmount: _formatAmount,
                            onBillTap: (bill) {
                              _handleEditTransaction(bill);
                            },
                            onEdit: (index, bill) {
                              _handleEditTransaction(bill);
                            },
                            onDelete: (index, bill) {
                              _handleDeleteTransaction(bill);
                            },
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
