import 'package:uuid/uuid.dart';

class NotificationData {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final String? transactionId;

  NotificationData({
    String? id,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.transactionId,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead ? 1 : 0,
      'transactionId': transactionId,
    };
  }

  factory NotificationData.fromMap(Map<String, dynamic> map) {
    return NotificationData(
      id: map['id'] as String,
      title: map['title'] as String,
      message: map['message'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
      isRead: map['isRead'] == 1,
      transactionId: map['transactionId'] as String?,
    );
  }

  NotificationData copyWith({
    String? title,
    String? message,
    DateTime? timestamp,
    bool? isRead,
    String? transactionId,
  }) {
    return NotificationData(
      id: id,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      transactionId: transactionId ?? this.transactionId,
    );
  }
}