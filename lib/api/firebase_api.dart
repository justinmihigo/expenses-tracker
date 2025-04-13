import 'package:expenses_tracker/auth/signup.dart';
import 'package:expenses_tracker/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rxdart/rxdart.dart';

class FirebaseApi {
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
    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessaging);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
    // handleForegroundMessaging();
  }

  Future<void> handleBackgroundMessaging(RemoteMessage message) async {
    await Firebase.initializeApp();
    debugPrint('Message data ${message.data}');
    debugPrint('Message title= ${message.notification?.title}');
    debugPrint('message notifaction title= ${message.notification?.body}');
  }

  void handleMessage(RemoteMessage? message) {
    if (message == null) return;
    navigatorKey.currentState?.pushNamed(
      SignupScreen.route,
      arguments: message,
    );
  }

  Future<void> handleForegroundMessaging() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('Handling foreground message messageid= ${message.messageId}');
        print('Message data ${message.data}');
        print('Message title= ${message.notification?.title}');
        print('message notifaction title= ${message.notification?.body}');
      }
      messageStreamController.sink.add(message);
    });
  }

  Future<bool> signup(String email, String password) async {
    try {
      await firebaseInit();
      final credentialUser = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      final user = credentialUser.user?.email;
      if (user != null) {
        debugPrint(user);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  Future<bool?> loginWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn().signIn();
      final userCredentials = await googleUser?.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: userCredentials?.idToken,
        accessToken: userCredentials?.accessToken,
      );
      final user = await FirebaseAuth.instance.signInWithCredential(credential);
      if (user.user != null) {
        debugPrint(user.user.toString());
        return true;
      } else {
        return false;
      }
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      await firebaseInit();
      final attempt = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = attempt.user?.email;
      if (user != null) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }
}
