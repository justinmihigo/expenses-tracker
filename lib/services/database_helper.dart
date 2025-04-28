import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/transaction.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'wallet.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE transactions (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            date TEXT NOT NULL,
            amount REAL NOT NULL,
            isCredit INTEGER NOT NULL,
            isScheduled INTEGER NOT NULL,
            scheduledDate TEXT
          )
        ''');
      },
    );
  }

  Future<void> insertTransaction(TransactionData transaction) async {
    final Database db = await database;
    await db.insert(
      'transactions',
      transaction.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<TransactionData>> getTransactions({bool scheduled = false}) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'isScheduled = ?',
      whereArgs: [scheduled ? 1 : 0],
    );

    return List.generate(maps.length, (i) => TransactionData.fromMap(maps[i]));
  }

  Future<void> updateTransaction(TransactionData transaction) async {
    final db = await database;
    await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
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

  Future<void> updateTotalBalance(double newBalance) async {
    final db = await database;
    await db.insert(
      'wallet_meta',
      {'key': 'total_balance', 'value': newBalance},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<double> getTotalBalance() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'wallet_meta',
      where: 'key = ?',
      whereArgs: ['total_balance'],
    );
    
    if (result.isEmpty) {
      return 0.0;
    }
    return result.first['value'] as double;
  }
}