import '../models/notification.dart';
import '../models/transaction.dart';
import '../sqlite.dart';

class NotificationService {
  final SQLiteDB _db = SQLiteDB.instance;

  // Singleton pattern
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  Future<List<NotificationData>> getNotifications() async {
    final maps = await _db.getNotifications();
    return maps.map((map) => NotificationData.fromMap(map)).toList();
  }

  Future<void> addNotification(NotificationData notification) async {
    await _db.insertNotification(notification.toMap());
  }

  Future<void> markAsRead(String id) async {
    await _db.markNotificationAsRead(id);
  }

  Future<void> checkUpcomingBill(
    TransactionData bill, 
    int daysUntilDue,
    Function(String) onNotification,
  ) async {
    final notifications = await getNotifications();
    final existingNotification = notifications.any((n) =>
        n.transactionId == bill.id &&
        n.title.contains('Upcoming Bill') &&
        n.timestamp.isAfter(DateTime.now().subtract(const Duration(days: 1))));

    if (!existingNotification) {
      final notification = NotificationData(
        title: 'Upcoming Bill',
        message: '${bill.title} - ${bill.amount.toStringAsFixed(2)} Rwf is due ${daysUntilDue == 0 ? 'today' : 'in 2 days'}',
        timestamp: DateTime.now(),
        transactionId: bill.id,
      );

      await addNotification(notification);
      onNotification(notification.message);
    }
  }
}