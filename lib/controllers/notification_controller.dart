import 'package:get/get.dart';
import '../models/notification_model.dart';
import '../services/firestore_service.dart';

class NotificationController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();
  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxInt unreadCount = 0.obs;

  @override
  void onInit() {
    fetchNotifications();
    super.onInit();
  }

  Future<void> fetchNotifications() async {
    try {
      isLoading.value = true;
      // Implement fetching logic from Firestore
      // Update notifications list and unreadCount
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      // Implement mark as read logic
      unreadCount.value--;
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      isLoading.value = true;
      // Implement mark all as read logic
      unreadCount.value = 0;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      // Implement delete notification logic
      notifications.removeWhere((n) => n.id == notificationId);
    } catch (e) {
      print('Error deleting notification: $e');
    }
  }
}