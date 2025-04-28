import '../services/firebase_service.dart';
import '../services/sync_service.dart';
import '../sqlite.dart';
import '../models/transaction.dart';
import '../models/notification.dart';

class WalletRepository {
  final SQLiteDB _db = SQLiteDB.instance;
  final FirebaseService _firebaseService = FirebaseService();
  final SyncService _syncService = SyncService();

  // Singleton pattern
  static final WalletRepository _instance = WalletRepository._internal();
  factory WalletRepository() => _instance;
  WalletRepository._internal() {
    _syncService.startSync();
  }

  // Transaction methods
  Future<void> addTransaction(TransactionData transaction) async {
    // Save to SQLite
    await _db.insertTransaction(transaction.toMap());
    
    // Update total balance in SQLite if not scheduled
    if (!transaction.isScheduled) {
      final currentBalance = await _db.getTotalBalance();
      final newBalance = currentBalance + (transaction.isCredit ? transaction.amount : -transaction.amount);
      await _db.updateTotalBalance(newBalance);
    }
    
    // Add to sync queue
    await _syncService.addToSyncQueue(
      'INSERT',
      'transactions',
      transaction.id,
      transaction.toMap(),
    );

    // Try to sync immediately
    _syncService.syncPendingOperations();
  }

  Future<void> updateTransaction(TransactionData transaction) async {
    // Save to SQLite
    await _db.updateTransaction(transaction.id, transaction.toMap());
    
    // Add to sync queue
    await _syncService.addToSyncQueue(
      'UPDATE',
      'transactions',
      transaction.id,
      transaction.toMap(),
    );

    // Try to sync immediately
    _syncService.syncPendingOperations();
  }

  Future<void> deleteTransaction(String id) async {
    // Delete from SQLite
    await _db.deleteTransaction(id);
    
    // Add to sync queue
    await _syncService.addToSyncQueue(
      'DELETE',
      'transactions',
      id,
      {'id': id},
    );

    // Try to sync immediately
    _syncService.syncPendingOperations();
  }

  Future<List<TransactionData>> getTransactions({bool scheduled = false}) async {
    final maps = await _db.getTransactions(scheduled: scheduled);
    return maps.map((map) => TransactionData.fromMap(map)).toList();
  }

  Future<void> updateTotalBalance(double newBalance) async {
    // Update in SQLite
    await _db.updateTotalBalance(newBalance);
    
    // Add to sync queue
    await _syncService.addToSyncQueue(
      'UPDATE',
      'wallet_meta',
      'total_balance',
      {'key': 'total_balance', 'value': newBalance},
    );

    // Try to sync immediately
    _syncService.syncPendingOperations();
  }

  Future<double> getTotalBalance() async {
    return await _db.getTotalBalance();
  }

  // Notification methods
  Future<void> addNotification(NotificationData notification) async {
    await _db.insertNotification(notification.toMap());
  }

  Future<List<NotificationData>> getNotifications() async {
    final maps = await _db.getNotifications();
    return maps.map((map) => NotificationData.fromMap(map)).toList();
  }

  Future<void> markNotificationAsRead(String id) async {
    await _db.markNotificationAsRead(id);
  }

  // Firebase streams
  Stream<List<TransactionData>> watchTransactions() {
    return _firebaseService.watchTransactions();
  }

  Stream<double> watchTotalBalance() {
    return _firebaseService.watchTotalBalance();
  }

  // Sync status
  Future<bool> hasPendingSync() async {
    return await _syncService.needsSync();
  }

  Future<void> syncPendingChanges() async {
    await _syncService.syncPendingOperations();
  }

  void dispose() {
    _syncService.dispose();
  }
}