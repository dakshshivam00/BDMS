import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () {
              // Mark all as read
            },
            child: const Text(
              'Mark all as read',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: 5, // Replace with actual notifications count
        itemBuilder: (context, index) {
          return _buildNotificationItem(
            title: 'Blood Request Nearby',
            message: 'Someone needs A+ blood in your area',
            time: '2 hours ago',
            isRead: index % 2 == 0,
          );
        },
      ),
    );
  }

  Widget _buildNotificationItem({
    required String title,
    required String message,
    required String time,
    required bool isRead,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isRead ? Colors.grey : Colors.red,
        child: const Icon(Icons.notifications, color: Colors.white),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message),
          const SizedBox(height: 4),
          Text(
            time,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
      onTap: () {
        // Handle notification tap
      },
    );
  }
}