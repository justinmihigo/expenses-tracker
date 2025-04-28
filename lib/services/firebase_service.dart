import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
import '../models/transaction.dart';

class FirebaseException implements Exception {
  final String message;
  FirebaseException(this.message);
}

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final messageStreamController = BehaviorSubject<RemoteMessage>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? get userId => _auth.currentUser?.uid;

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
      
      // Create user profile in Firestore
      if (credential.user != null) {
        await _firestore.collection('users').doc(credential.user!.uid).set({
          'email': email,
          'displayName': email.split('@')[0],
          'createdAt': FieldValue.serverTimestamp(),
          'totalBalance': 0.0,
        });
      }
      
      return credential;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  Future<UserCredential?> signin(String email, String password) async {
    try {
      return await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  Future<void> signout() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> syncTransactions(List<TransactionData> transactions) async {
    if (userId == null) throw FirebaseException('User not authenticated');

    try {
      final batch = _firestore.batch();
      final userTransactions = _firestore.collection('users').doc(userId).collection('transactions');

      // First, delete all existing transactions
      final existingDocs = await userTransactions.get();
      for (var doc in existingDocs.docs) {
        batch.delete(doc.reference);
      }

      // Then add all current transactions
      for (var transaction in transactions) {
        final data = transaction.toMap();
        // Ensure data types match Firestore expectations
        data['amount'] = (data['amount'] as num).toDouble();
        data['isCredit'] = data['isCredit'] == 1;
        data['isScheduled'] = data['isScheduled'] == 1;
        
        batch.set(
          userTransactions.doc(transaction.id),
          data,
        );
      }

      await batch.commit();
    } catch (e) {
      debugPrint('Error syncing transactions: $e');
      throw FirebaseException('Failed to sync transactions');
    }
  }

  Future<void> updateTotalBalance(double balance) async {
    if (userId == null) throw FirebaseException('User not authenticated');

    await _firestore
        .collection('users')
        .doc(userId)
        .set({'totalBalance': balance}, SetOptions(merge: true));
  }

  Future<void> deleteFirebaseTransaction(String id) async {
    if (userId == null) throw FirebaseException('User not authenticated');

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .doc(id)
        .delete();
  }

  Future<void> createTransaction(TransactionData transaction) async {
    if (userId == null) throw FirebaseException('User not authenticated');

    try {
      final userTransactions = _firestore.collection('users').doc(userId).collection('transactions');
      final data = transaction.toMap();
      
      // Ensure data types match Firestore expectations
      data['amount'] = (data['amount'] as num).toDouble();
      data['isCredit'] = data['isCredit'] == 1;
      data['isScheduled'] = data['isScheduled'] == 1;
      
      await userTransactions.doc(transaction.id).set(data);
    } catch (e) {
      debugPrint('Error creating transaction: $e');
      throw FirebaseException('Failed to create transaction');
    }
  }

  Stream<List<TransactionData>> watchTransactions() {
    if (userId == null) return Stream.value([]);
    
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TransactionData.fromMap({...doc.data(), 'id': doc.id}))
            .toList());
  }

  Stream<double> watchTotalBalance() {
    if (userId == null) return Stream.value(0.0);
    
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) => (doc.data()?['totalBalance'] as num?)?.toDouble() ?? 0.0);
  }

  void dispose() {
    messageStreamController.close();
  }
}