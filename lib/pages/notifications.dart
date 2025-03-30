import 'package:expenses_tracker/api/firebase_api.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class Notifications extends StatelessWidget {
  const Notifications({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Notifications')),
      body: NotificationsState(),
    );
  }
}

class NotificationsState extends StatefulWidget {
  const NotificationsState({super.key});
  @override
  State<NotificationsState> createState() => _NotificationsState();
}

class _NotificationsState extends State<NotificationsState> {
  final firebaseApi = FirebaseApi();
  String _lastMessage = '';
  Future<void> handleBackgroundMessaging(RemoteMessage message) async {
    print('Message data ${message.data}');
    print('Message title= ${message.notification?.title}');
    print('message notifaction title= ${message.notification?.body}');
  }

  @override
  void initState() {
    super.initState();
    firebaseApi.firebaseInit();
    firebaseApi.handleForegroundMessaging();
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessaging);
  }

  _NotificationsState() {
    firebaseApi.firebaseInit();
    firebaseApi.messageStreamController.listen((message) {
      if (message.notification != null) {
        setState(() {
          _lastMessage =
              'Title: ${message.notification?.title}\n'
              'Body: ${message.notification?.body}\n';
          // 'Data: ${message.data}';
        });
      } else {
        setState(() {
          _lastMessage = 'Data Message: ${message.data}';
        });
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    final message = ModalRoute.of(context)?.settings.arguments;
    final RemoteMessage? lastMessage = message as dynamic;
    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: Column(
            children: [
              Text(_lastMessage),
              Text(
                '${lastMessage?.notification?.title} body ${lastMessage?.notification?.body}',
              ),
            ],
          ),
        );
      },
    );
  }
}
