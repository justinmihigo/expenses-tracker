import 'package:flutter_test/flutter_test.dart';
import 'package:expenses_tracker/models/transaction.dart';
import 'package:expenses_tracker/sqlite.dart';
import 'package:expenses_tracker/services/sync_service.dart';
import 'package:expenses_tracker/repositories/wallet_repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:expenses_tracker/firebase_options.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  late SQLiteDB db;
  late WalletRepository repository;
  late SyncService syncService;

  setUp(() async {
    // Initialize a temporary SQLite database for testing
    databaseFactory = databaseFactoryFfi;
    db = SQLiteDB.instance;
    await db.database; // Ensure database is initialized

    // Initialize Firebase for testing
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Get instances of services
    repository = WalletRepository();
    syncService = SyncService();
  });

  tearDown(() async {
    // Clean up the test database
    final database = await db.database;
    await database.close();
  });

  group('SQLite Operations', () {
    test('Insert and retrieve transaction', () async {
      final transaction = TransactionData(
        id: 'test-1',
        title: 'Test Transaction',
        amount: 100.0,
        isCredit: true,
        date: DateTime.now().toIso8601String(),
        isScheduled: false,
        category: TransactionCategory.salary,
      );

      await db.insertTransaction(transaction.toMap());
      final result = await db.getTransactions();

      expect(result.length, 1);
      expect(result.first['id'], transaction.id);
      expect(result.first['title'], transaction.title);
      expect(result.first['amount'], transaction.amount);
    });

    test('Update transaction', () async {
      final transaction = TransactionData(
        id: 'test-2',
        title: 'Original Title',
        amount: 100.0,
        isCredit: true,
        date: DateTime.now().toIso8601String(),
        isScheduled: false,
        category: TransactionCategory.salary,
      );

      await db.insertTransaction(transaction.toMap());
      
      final updatedTransaction = transaction.copyWith(
        title: 'Updated Title',
        amount: 200.0,
      );

      await db.updateTransaction(transaction.id, updatedTransaction.toMap());
      final result = await db.getTransactions();

      expect(result.length, 1);
      expect(result.first['title'], 'Updated Title');
      expect(result.first['amount'], 200.0);
    });

    test('Delete transaction', () async {
      final transaction = TransactionData(
        id: 'test-3',
        title: 'To Delete',
        amount: 100.0,
        isCredit: true,
        date: DateTime.now().toIso8601String(),
        isScheduled: false,
        category: TransactionCategory.salary,
      );

      await db.insertTransaction(transaction.toMap());
      await db.deleteTransaction(transaction.id);
      final result = await db.getTransactions();

      expect(result.length, 0);
    });
  });

  group('Sync Queue Operations', () {
    test('Add operation to sync queue', () async {
      final transaction = TransactionData(
        id: 'test-4',
        title: 'Sync Test',
        amount: 100.0,
        isCredit: true,
        date: DateTime.now().toIso8601String(),
        isScheduled: false,
        category: TransactionCategory.salary,
      );

      await syncService.addToSyncQueue(
        'INSERT',
        'transactions',
        transaction.id,
        transaction.toMap(),
      );

      final database = await db.database;
      final result = await database.query('sync_queue');

      expect(result.length, 1);
      expect(result.first['operation'], 'INSERT');
      expect(result.first['table_name'], 'transactions');
      expect(result.first['record_id'], transaction.id);
    });

    test('Sync pending operations', () async {
      final transaction = TransactionData(
        id: 'test-5',
        title: 'Sync Test',
        amount: 100.0,
        isCredit: true,
        date: DateTime.now().toIso8601String(),
        isScheduled: false,
        category: TransactionCategory.salary,
      );

      await syncService.addToSyncQueue(
        'INSERT',
        'transactions',
        transaction.id,
        transaction.toMap(),
      );

      await syncService.syncPendingOperations();

      final database = await db.database;
      final result = await database.query('sync_queue');

      expect(result.length, 0); // Queue should be empty after sync
    });
  });

  group('Repository Integration', () {
    test('Add transaction updates both SQLite and sync queue', () async {
      final transaction = TransactionData(
        id: 'test-6',
        title: 'Integration Test',
        amount: 100.0,
        isCredit: true,
        date: DateTime.now().toIso8601String(),
        isScheduled: false,
        category: TransactionCategory.salary,
      );

      await repository.addTransaction(transaction);

      // Check SQLite
      final sqliteResult = await db.getTransactions();
      expect(sqliteResult.length, 1);
      expect(sqliteResult.first['id'], transaction.id);

      // Check sync queue
      final needsSync = await repository.hasPendingSync();
      expect(needsSync, true);
    });
  });
}