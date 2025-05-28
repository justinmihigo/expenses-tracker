import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/notification.dart';
import '../models/transaction.dart';
import '../sqlite.dart';
import '../services/notification_service.dart';
import '../services/wallet_service.dart';
import 'package:expenses_tracker/models/budget_goal.dart';
import 'package:expenses_tracker/models/wallet_data.dart';
import 'package:expenses_tracker/repositories/wallet_repository.dart';

class WalletProvider extends ChangeNotifier {
  final WalletRepository _repository = WalletRepository();
  final NotificationService _notificationService = NotificationService();
  final WalletService _walletService = WalletService();
  final _db = SQLiteDB.instance;
  
  List<TransactionData> _transactions = [];
  List<TransactionData> _upcomingBills = [];
  List<NotificationData> _notifications = [];
  double _totalBalance = 0.0;
  bool _isLoading = true;
  WalletData _walletData = WalletData.initial();
  BudgetGoal? _currentBudgetGoal;

  WalletProvider() {
    _initializeData();
  }

  List<TransactionData> get transactions => _transactions;
  List<TransactionData> get upcomingBills => _upcomingBills;
  List<NotificationData> get notifications => _notifications;
  double get totalBalance => _totalBalance;
  bool get isLoading => _isLoading;
  WalletData get walletData => _walletData;
  BudgetGoal? get currentBudgetGoal => _currentBudgetGoal;

  Future<void> _initializeData() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _loadLocalData();
    } catch (e) {
      debugPrint('Error initializing data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadLocalData() async {
    try {
      debugPrint('Loading local data from SQLite...');
      final db = await _db.database;
      if (db == null) {
        debugPrint('Database is null, cannot load data');
        return;
      }

      // Load transactions
      final transactionsList = await _db.getTransactions();
      debugPrint('Loaded ${transactionsList.length} transactions from database');
      for (var transaction in transactionsList) {
        debugPrint('Transaction: ${transaction['title']} - ${transaction['amount']} - ${transaction['category']} - ${transaction['date']}');
      }
      _transactions = transactionsList.map((map) => TransactionData.fromMap(map)).toList();
      debugPrint('Converted ${_transactions.length} transactions to TransactionData objects');
      notifyListeners();
      debugPrint('Notified listeners about transaction updates');

      // Load bills
      final billsList = await _db.getTransactions(scheduled: true);
      debugPrint('Loaded ${billsList.length} bills from database');
      _upcomingBills = billsList.map((map) => TransactionData.fromMap(map)).toList();
      debugPrint('Converted ${_upcomingBills.length} bills to TransactionData objects');
      notifyListeners();
      debugPrint('Notified listeners about bill updates');

      // Load notifications
      final notificationsList = await _db.getNotifications();
      debugPrint('Loaded ${notificationsList.length} notifications from database');
      _notifications = notificationsList.map((map) => NotificationData.fromMap(map)).toList();
      debugPrint('Converted ${_notifications.length} notifications to NotificationData objects');

      // Calculate total balance
      _calculateTotalBalance();
      debugPrint('Total balance calculated: $_totalBalance');

      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint('Error loading local data: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  Future<void> refreshData() async {
    await _loadLocalData();
    notifyListeners();
  }

  Future<void> addTransaction(TransactionData transaction) async {
    try {
      debugPrint('Adding transaction: ${transaction.title}');
      await _db.insertTransaction(transaction.toMap());
      debugPrint('Transaction inserted successfully');
      
      _transactions.add(transaction);
      _calculateTotalBalance();
      notifyListeners();
      debugPrint('Notified listeners after adding transaction');
    } catch (e, stackTrace) {
      debugPrint('Error adding transaction: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> updateTransaction(TransactionData old, TransactionData updated) async {
    try {
      await _db.updateTransaction(old.id, updated.toMap());
      
      if (old.isScheduled) {
        final index = _upcomingBills.indexWhere((t) => t.id == old.id);
        if (index != -1) {
          _upcomingBills[index] = updated;
        }
      } else {
        final index = _transactions.indexWhere((t) => t.id == old.id);
        if (index != -1) {
          _updateTotalBalance(
            -old.amount * (old.isCredit ? 1 : -1) + 
            updated.amount * (updated.isCredit ? 1 : -1)
          );
          _transactions[index] = updated;
        }
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating transaction: $e');
    }
  }

  Future<void> deleteTransaction(TransactionData transaction) async {
    try {
      debugPrint('Deleting transaction: ${transaction.id}');
      await WalletService.deleteTransaction(transaction);
      debugPrint('Transaction deleted successfully from database');
      
      if (transaction.isScheduled) {
        _upcomingBills.removeWhere((t) => t.id == transaction.id);
      } else {
        _transactions.removeWhere((t) => t.id == transaction.id);
        _totalBalance = await _repository.getTotalBalance();
      }
      
      notifyListeners();
      debugPrint('Notified listeners after deleting transaction');
    } catch (e, stackTrace) {
      debugPrint('Error deleting transaction: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> markNotificationAsRead(String id) async {
    try {
      debugPrint('Marking notification $id as read...');
      await _db.markNotificationAsRead(id);
      
      // Update local notifications list
      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        notifyListeners();
      }
      
      debugPrint('Notification marked as read successfully');
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  Future<void> _updateTotalBalance(double amount) async {
    _totalBalance += amount;
    await _db.updateTotalBalance(_totalBalance);
  }

  void setWalletData(WalletData data) {
    _walletData = data;
    notifyListeners();
  }

  void setBudgetGoal(BudgetGoal goal) {
    _currentBudgetGoal = goal;
    notifyListeners();
  }

  Map<TransactionCategory, double> getCategoryTotals() {
    final totals = <TransactionCategory, double>{};
    
    for (var category in TransactionCategory.values) {
      totals[category] = 0;
    }
    
    for (var transaction in _walletData.transactions) {
      totals[transaction.category] = (totals[transaction.category] ?? 0) + 
        (transaction.isCredit ? transaction.amount : -transaction.amount);
    }
    
    return totals;
  }

  Map<TransactionCategory, double> getCategoryProgress() {
    if (_currentBudgetGoal == null) return {};
    
    final totals = getCategoryTotals();
    final progress = <TransactionCategory, double>{};
    
    for (var entry in _currentBudgetGoal!.categoryLimits.entries) {
      final category = TransactionCategory.values.firstWhere(
        (c) => c.toString().split('.').last == entry.key,
        orElse: () => TransactionCategory.others,
      );
      
      final total = totals[category] ?? 0;
      final limit = entry.value;
      
      progress[category] = (total / limit) * 100;
    }
    
    return progress;
  }

  double getSavingsProgress() {
    if (_currentBudgetGoal == null) return 0;
    
    final totalIncome = _walletData.transactions
        .where((t) => t.isCredit)
        .fold(0.0, (sum, t) => sum + t.amount);
    
    final totalExpenses = _walletData.transactions
        .where((t) => !t.isCredit)
        .fold(0.0, (sum, t) => sum + t.amount);
    
    final savings = totalIncome - totalExpenses;
    return (savings / _currentBudgetGoal!.savingsTarget) * 100;
  }

  Future<void> checkUpcomingBills() async {
    try {
      final now = DateTime.now();
      final upcomingBills = _upcomingBills.where((bill) {
        if (bill.scheduledDate == null) return false;
        final daysUntilDue = bill.scheduledDate!.difference(now).inDays;
        return daysUntilDue >= 0 && daysUntilDue <= 2;
      }).toList();

      for (final bill in upcomingBills) {
        if (bill.scheduledDate == null) continue;
        final daysUntilDue = bill.scheduledDate!.difference(now).inDays;
        
        // Check if we already have a recent notification for this bill
        final hasRecentNotification = _notifications.any((n) =>
            n.transactionId == bill.id &&
            n.title.contains('Upcoming Bill') &&
            n.timestamp.isAfter(now.subtract(const Duration(days: 1))));

        if (!hasRecentNotification) {
          final notification = NotificationData(
            title: 'Upcoming Bill',
            message: '${bill.title} - ${bill.amount.toStringAsFixed(2)} Rwf is due ${daysUntilDue == 0 ? 'today' : 'in $daysUntilDue days'}',
            timestamp: now,
            transactionId: bill.id,
          );

          await _notificationService.addNotification(notification);
          _notifications.add(notification);
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error checking upcoming bills: $e');
    }
  }

  void _calculateTotalBalance() {
    debugPrint('Calculating total balance...');
    _totalBalance = _transactions.fold<double>(
      0,
      (sum, transaction) => sum + (transaction.isCredit ? transaction.amount : -transaction.amount),
    );
    debugPrint('New total balance: $_totalBalance');
  }
}