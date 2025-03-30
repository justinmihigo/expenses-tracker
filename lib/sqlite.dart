import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:rxdart/rxdart.dart';

class Sqlite {
  final messageStreamController = BehaviorSubject<RemoteMessage>();
  Future<void> firebaseInit() async {
    // await FirebaseAuth.instance.useAuthEmulator("localhost", 9000);
    FirebaseAuth.instance.authStateChanges().listen((Object? user) {
      if (user is User) {
        debugPrint("User is not signed in");
      } else {
        debugPrint("User is in");
      }
    });
    final messaging = FirebaseMessaging.instance;
    final settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      criticalAlert: false,
      carPlay: true,
      provisional: false,
      sound: true,
    );
    if (kDebugMode) {
      debugPrint('Permission granted ${settings.authorizationStatus}');
    }
    String? token = await messaging.getToken();
    if (kDebugMode) {
      debugPrint('Registration token=$token');
    }
  }

  Future<void> sendNotifications() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        debugPrint(
          'Handling foreground message messageid= ${message.messageId}',
        );
        debugPrint('Message data ${message.data}');
        debugPrint('Message title= ${message.notification?.title}');
        debugPrint('message notifaction title= ${message.notification?.body}');
      }
      messageStreamController.sink.add(message);
    });
  }

  Future<void> signup(String email, String password) async {
    try {
      await firebaseInit();
      final credentialUser = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      final user = credentialUser.user?.email;
      if (user != null) {
        debugPrint(user);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

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
