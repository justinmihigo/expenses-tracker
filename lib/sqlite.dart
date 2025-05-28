import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart';

class SQLiteDB {
  static SQLiteDB? _instance;
  static Database? _database;

  SQLiteDB._();

  static SQLiteDB get instance {
    _instance ??= SQLiteDB._();
    return _instance!;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final String databasePath = await getDatabasesPath();
    final String path = join(databasePath, 'expenses.db');
    debugPrint('Initializing database at: $path');

    return await openDatabase(
      path,
      version: 2,
      onCreate: (Database db, int version) async {
        debugPrint('Creating database tables for version $version');
        await _createTables(db);
      },
      onUpgrade: (Database db, int oldVersion, int newVersion) async {
        debugPrint('Upgrading database from version $oldVersion to $newVersion');
        if (oldVersion < 1) {
          await _createTables(db);
        }
        if (oldVersion < 2) {
          debugPrint('Adding category column to transactions table');
          await db.execute('ALTER TABLE transactions ADD COLUMN category TEXT');
        }
      },
    );
  }

  Future<void> _createTables(Database db) async {
    // Create transactions table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS transactions (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        date TEXT NOT NULL,
        amount REAL NOT NULL,
        isCredit INTEGER NOT NULL,
        isScheduled INTEGER NOT NULL,
        scheduledDate TEXT,
        category TEXT,
        synced INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Create wallet_meta table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS wallet_meta (
        key TEXT PRIMARY KEY,
        value REAL NOT NULL
      )
    ''');

    // Create notifications table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS notifications (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        message TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        isRead INTEGER NOT NULL DEFAULT 0,
        transactionId TEXT,
        FOREIGN KEY (transactionId) REFERENCES transactions (id) ON DELETE CASCADE
      )
    ''');

    // Create sync_queue table for handling offline operations
    await db.execute('''
      CREATE TABLE IF NOT EXISTS sync_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        operation TEXT NOT NULL,
        table_name TEXT NOT NULL,
        record_id TEXT NOT NULL,
        data TEXT NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');

    // Initialize wallet_meta with default total balance if not exists
    await db.insert(
      'wallet_meta',
      {'key': 'total_balance', 'value': 0.0},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  // Transaction methods
  Future<void> insertTransaction(Map<String, dynamic> transaction) async {
    final db = await database;
    debugPrint('Inserting transaction: $transaction');
    try {
      await db.insert(
        'transactions',
        transaction,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      debugPrint('Transaction inserted successfully');
    } catch (e) {
      debugPrint('Error inserting transaction: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getTransactions({bool? scheduled}) async {
    final db = await database;
    debugPrint('Getting transactions${scheduled != null ? ' (scheduled: $scheduled)' : ''}');
    try {
      List<Map<String, dynamic>> result;
      if (scheduled != null) {
        result = await db.query(
          'transactions',
          where: 'isScheduled = ?',
          whereArgs: [scheduled ? 1 : 0],
        );
      } else {
        result = await db.query('transactions');
      }
      debugPrint('Retrieved ${result.length} transactions');
      return result;
    } catch (e) {
      debugPrint('Error getting transactions: $e');
      rethrow;
    }
  }

  Future<void> updateTransaction(String id, Map<String, dynamic> transaction) async {
    final db = await database;
    await db.update(
      'transactions',
      transaction,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteTransaction(String id) async {
    final db = await database;
    await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Balance methods
  Future<void> updateTotalBalance(double balance) async {
    final db = await database;
    await db.insert(
      'wallet_meta',
      {'key': 'total_balance', 'value': balance},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<double> getTotalBalance() async {
    final db = await database;
    final result = await db.query(
      'wallet_meta',
      where: 'key = ?',
      whereArgs: ['total_balance'],
    );
    
    if (result.isEmpty) {
      return 0.0;
    }
    return result.first['value'] as double;
  }

  // Notification methods
  Future<void> insertNotification(Map<String, dynamic> notification) async {
    final db = await database;
    await db.insert(
      'notifications',
      notification,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getNotifications() async {
    final db = await database;
    return db.query('notifications', orderBy: 'timestamp DESC');
  }

  Future<void> markNotificationAsRead(String id) async {
    final db = await database;
    await db.update(
      'notifications',
      {'isRead': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
