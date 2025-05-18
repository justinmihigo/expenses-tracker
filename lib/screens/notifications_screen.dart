import 'package:flutter/material.dart';
import '../models/notification.dart';

class NotificationsScreen extends StatelessWidget {
  final List<NotificationData> notifications;
  final Function(String) onNotificationRead;

  const NotificationsScreen({
    required this.notifications,
    required this.onNotificationRead,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Column(
        children: [
          // Back button and title
          Container(
            color: Theme.of(context).colorScheme.primary,
            padding: const EdgeInsets.only(top: 48.0, bottom: 16.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const Text(
                  'Notifications',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Notifications list
          Expanded(
            child: notifications.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_none,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No notifications',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final notification = notifications[index];
                      return Dismissible(
                        key: Key(notification.id),
                        background: Container(
                          color: Colors.green,
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(left: 20),
                          child: const Icon(Icons.check, color: Colors.white),
                        ),
                        direction: DismissDirection.startToEnd,
                        onDismissed: (_) => onNotificationRead(notification.id),
                        child: Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: ListTile(
                            title: Text(
                              notification.title,
                              style: TextStyle(
                                fontWeight:
                                    notification.isRead ? FontWeight.normal : FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(notification.message),
                                const SizedBox(height: 4),
                                Text(
                                  _formatTimestamp(notification.timestamp),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                            leading: CircleAvatar(
                              backgroundColor: notification.isRead
                                  ? Colors.grey.shade200
                                  : Theme.of(context).colorScheme.primary,
                              child: Icon(
                                _getNotificationIcon(notification),
                                color: notification.isRead
                                    ? Colors.grey
                                    : Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                            onTap: () => onNotificationRead(notification.id),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  IconData _getNotificationIcon(NotificationData notification) {
    if (notification.title.contains('Income')) {
      return Icons.arrow_upward;
    } else if (notification.title.contains('Expense')) {
      return Icons.arrow_downward;
    } else if (notification.title.contains('Bill')) {
      return Icons.calendar_today;
    } else if (notification.title.contains('Updated')) {
      return Icons.edit;
    } else if (notification.title.contains('Deleted')) {
      return Icons.delete;
    }
    return Icons.notifications;
  }
}