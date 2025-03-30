import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class Sqlite {
  Future<Database> dbinit() async {
    WidgetsFlutterBinding.ensureInitialized();
    final String dbpath = join(await getDatabasesPath(), "user_db.db");
    final database = openDatabase(
      dbpath,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE users (id INTEGER PRIMARY KEY, name TEXT, email TEXT, password TEXT)',
        );
      },
      version: 1,
    );
    return database;
  }

  Future<void> insert(User user) async {
    final db = await dbinit();
    await db.insert("users", user.toMap());
  }

  Future<List<User>> listUsers() async {
    final db = await dbinit();
    List<Map<String, Object?>> users = await db.query("users");
    return [
      for (final {
            "id": id as int,
            "name": name as String,
            "email": email as String,
            "password": password as String,
          }
          in users)
        User(id: id, name: name, email: email, password: password),
    ];
  }
}

class User {
  final int? id;
  final String email;
  final String name;
  final String password;

  const User({
    this.id,
    required this.email,
    required this.name,
    required this.password,
  });
  Map<String, Object?> toMap() {
    return ({"id": id, "name": name, "email": email, "password": password});
  }

  @override
  String toString() {
    return "User(id: $id, name: $name, email: $email, password: $password)";
  }
}
