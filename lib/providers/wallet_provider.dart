import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/notification.dart';
import '../models/transaction.dart';
import '../models/wallet_data.dart';
import '../services/firebase_service.dart';
import '../sqlite.dart';

class WalletProvider extends ChangeNotifier {
  final _db = SQLiteDB.instance;
  final _firebaseService = FirebaseService();
  
  List<TransactionData> _transactions = [];
  List<TransactionData> _upcomingBills = [];
  List<NotificationData> _notifications = [];
  double _totalBalance = 0.0;
  bool _isLoading = true;
  bool _needsSync = false;

  WalletProvider() {
    _initializeData();
  }

  List<TransactionData> get transactions => _transactions;
  List<TransactionData> get upcomingBills => _upcomingBills;
  List<NotificationData> get notifications => _notifications;
  double get totalBalance => _totalBalance;
  bool get isLoading => _isLoading;
  bool get needsSync => _needsSync;

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
      final transactionMaps = await _db.getTransactions();
      _transactions = transactionMaps
          .map((map) => TransactionData.fromMap(map))
          .toList();

      final upcomingMaps = await _db.getTransactions(scheduled: true);
      _upcomingBills = upcomingMaps
          .map((map) => TransactionData.fromMap(map))
          .toList();

      final notificationMaps = await _db.getNotifications();
      _notifications = notificationMaps
          .map((map) => NotificationData.fromMap(map))
          .toList();

      _totalBalance = await _db.getTotalBalance();
    } catch (e) {
      debugPrint('Error loading local data: $e');
    }
  }

  Future<void> syncWithFirebase() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      // Sync data to Firebase
      await _firebaseService.syncTransactions(_transactions + _upcomingBills);
      await _firebaseService.updateTotalBalance(_totalBalance);
      
      _needsSync = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error syncing with Firebase: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Future<void> pullFromFirebase() async {
  //   try {
  //     _isLoading = true;
  //     notifyListeners();

  //     // Get latest data from Firebase
  //     final firebaseTransactions = await _firebaseService.getTransactions();
  //     final firebaseBalance = await _firebaseService.getTotalBalance();

  //     // Update local database
  //     for (var transaction in firebaseTransactions) {
  //       await _db.insertTransaction(transaction.toMap());
  //     }
  //     await _db.updateTotalBalance(firebaseBalance);

  //     // Reload local data
  //     await _loadLocalData();
  //   } catch (e) {
  //     debugPrint('Error pulling from Firebase: $e');
  //   } finally {
  //     _isLoading = false;
  //     notifyListeners();
  //   }
  // }

  Future<void> addTransaction(TransactionData transaction) async {
    try {
      await _db.insertTransaction(transaction.toMap());
      if (transaction.isScheduled) {
        _upcomingBills.add(transaction);
      } else {
        _transactions.add(transaction);
        _updateTotalBalance(transaction.amount * (transaction.isCredit ? 1 : -1));
      }
      _needsSync = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding transaction: $e');
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
      
      _needsSync = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating transaction: $e');
    }
  }

  Future<void> deleteTransaction(TransactionData transaction) async {
    try {
      await _db.deleteTransaction(transaction.id);
      
      if (transaction.isScheduled) {
        _upcomingBills.removeWhere((t) => t.id == transaction.id);
      } else {
        _transactions.removeWhere((t) => t.id == transaction.id);
        _updateTotalBalance(-transaction.amount * (transaction.isCredit ? 1 : -1));
      }
      
      _needsSync = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting transaction: $e');
    }
  }

  Future<void> markNotificationAsRead(String id) async {
    try {
      await _db.markNotificationAsRead(id);
      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        final notification = _notifications[index];
        _notifications[index] = NotificationData(
          id: notification.id,
          title: notification.title,
          message: notification.message,
          timestamp: notification.timestamp,
          isRead: true,
          transactionId: notification.transactionId,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  Future<void> checkUpcomingBills() async {
    // Implementation for checking upcoming bills
    // This will be called periodically to check for due bills
  }

  Future<void> refreshData() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _loadLocalData();
    } catch (e) {
      debugPrint('Error refreshing data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _updateTotalBalance(double change) {
    _totalBalance += change;
    _db.updateTotalBalance(_totalBalance);
  }

}