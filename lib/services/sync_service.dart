import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../sqlite.dart';
import 'firebase_service.dart';

class SyncService {
  final SQLiteDB _db = SQLiteDB.instance;
  final FirebaseService _firebaseService = FirebaseService();
  Timer? _syncTimer;
  bool _isSyncing = false;

  // Singleton pattern
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  void startSync() {
    // Check for connectivity changes
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (result != ConnectivityResult.none) {
        syncPendingOperations();
      }
    });

    // Periodically try to sync even if we think we're online
    _syncTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      syncPendingOperations();
    });
  }

  void dispose() {
    _syncTimer?.cancel();
  }

  Future<void> addToSyncQueue(String operation, String tableName, String recordId, Map<String, dynamic> data) async {
    final db = await _db.database;
    await db.insert('sync_queue', {
      'operation': operation,
      'table_name': tableName,
      'record_id': recordId,
      'data': jsonEncode(data),
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Future<void> syncPendingOperations() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      final db = await _db.database;
      final operations = await db.query('sync_queue', orderBy: 'timestamp ASC');

      for (final op in operations) {
        final operation = op['operation'] as String;
        final tableName = op['table_name'] as String;
        final recordId = op['record_id'] as String;
        final data = jsonDecode(op['data'] as String);

        bool success = false;

        try {
          if (tableName == 'transactions') {
            if (operation == 'INSERT' || operation == 'UPDATE') {
              await _firebaseService.syncTransactions([data]);
              success = true;
            } else if (operation == 'DELETE') {
              await _firebaseService.deleteFirebaseTransaction(recordId);
              success = true;
            }
          } else if (tableName == 'wallet_meta' && operation == 'UPDATE') {
            if (data['key'] == 'total_balance') {
              await _firebaseService.updateTotalBalance(data['value']);
              success = true;
            }
          }

          if (success) {
            // Remove the successful operation from the queue
            await db.delete(
              'sync_queue',
              where: 'id = ?',
              whereArgs: [op['id']],
            );
          }
        } catch (e) {
          print('Error syncing operation: $e');
          // Leave the operation in the queue to try again later
        }
      }
    } finally {
      _isSyncing = false;
    }
  }

  Future<bool> needsSync() async {
    final db = await _db.database;
    final result = await db.query('sync_queue');
    return result.isNotEmpty;
  }
}