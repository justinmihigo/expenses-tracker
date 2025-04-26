import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:expenses_tracker/models/user.dart' as app_models;

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Future<Database> get database async {
    WidgetsFlutterBinding.ensureInitialized();
    final String dbpath = join(await getDatabasesPath(), "user_db.db");
    return openDatabase(
      dbpath,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE users (id INTEGER PRIMARY KEY, name TEXT, email TEXT, password TEXT)',
        );
      },
      version: 1,
    );
  }

  Future<void> insertUser(app_models.User user) async {
    final db = await database;
    await db.insert("users", user.toMap());
  }

  Future<List<app_models.User>> getUsers() async {
    final db = await database;
    List<Map<String, Object?>> users = await db.query("users");
    return [
      for (final {
            "id": id as int,
            "name": name as String,
            "email": email as String,
            "password": password as String,
          } in users)
        app_models.User(id: id, name: name, email: email, password: password),
    ];
  }
} 