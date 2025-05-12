import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    // Request permission
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Get FCM token
    String? token = await _messaging.getToken();
    print('FCM Token: $token');

    // Handle messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Handle foreground messages
      if (message.notification != null) {
        Get.snackbar(
          message.notification!.title ?? 'New Notification',
          message.notification!.body ?? '',
          duration: const Duration(seconds: 3),
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Handle when app is opened from notification
      if (message.data.isNotEmpty) {
        // Navigate based on data if needed
      }
    });
  }

  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
  }
}