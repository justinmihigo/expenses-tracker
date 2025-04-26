import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final messageStreamController = BehaviorSubject<RemoteMessage>();

  Future<void> initialize() async {
    await _initializeAuth();
    await _initializeMessaging();
  }

  Future<void> _initializeAuth() async {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        debugPrint("User is not signed in");
      } else {
        debugPrint("User is signed in");
      }
    });
  }

  Future<void> _initializeMessaging() async {
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
      String? token = await messaging.getToken();
      debugPrint('Registration token=$token');
    }

    _setupMessageHandling();
  }

  void _setupMessageHandling() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        debugPrint('Message ID: ${message.messageId}');
        debugPrint('Message data: ${message.data}');
        debugPrint('Message title: ${message.notification?.title}');
        debugPrint('Message body: ${message.notification?.body}');
      }
      messageStreamController.sink.add(message);
    });
  }

  Future<UserCredential?> signup(String email, String password) async {
    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      return credential;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  void dispose() {
    messageStreamController.close();
  }
} 