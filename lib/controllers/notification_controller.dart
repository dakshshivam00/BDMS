import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/notification_model.dart';
import '../controllers/auth_controller.dart';
import 'dart:async';

class NotificationController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxInt unreadCount = 0.obs;

  StreamSubscription? _notificationsSubscription;

  @override
  void onInit() {
    fetchNotifications();
    super.onInit();
  }

  @override
  void onClose() {
    _notificationsSubscription?.cancel();
    super.onClose();
  }

  Future<void> fetchNotifications() async {
    try {
      isLoading.value = true;

      final authController = Get.find<AuthController>();
      final userId = authController.getCurrentUserId();

      if (userId.isEmpty) return;

      _notificationsSubscription = _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .snapshots()
          .listen(
            (snapshot) {
              notifications.clear();

              for (var doc in snapshot.docs) {
                final data = doc.data();
                final notification = NotificationModel(
                  id: doc.id,
                  userId: data['userId'] ?? '',
                  title: data['title'] ?? '',
                  message: data['message'] ?? '',
                  type: data['type'] ?? '',
                  relatedId: data['relatedId'],
                  createdAt:
                      data['createdAt'] != null
                          ? (data['createdAt'] as Timestamp).toDate()
                          : DateTime.now(),
                  isRead: data['read'] ?? false,
                );

                notifications.add(notification);
              }

              // Update unread count
              unreadCount.value =
                  notifications
                      .where((notification) => !notification.isRead)
                      .length;

              isLoading.value = false;
            },
            onError: (error) {
              print('Error fetching notifications: $error');
              isLoading.value = false;
            },
          );
    } catch (e) {
      print('Error setting up notifications listener: $e');
      isLoading.value = false;
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({
        'read': true,
        'readAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      isLoading.value = true;

      final authController = Get.find<AuthController>();
      final userId = authController.getCurrentUserId();

      if (userId.isEmpty) return;

      final batch = _firestore.batch();
      final unreadNotificationsQuery =
          await _firestore
              .collection('notifications')
              .where('userId', isEqualTo: userId)
              .where('read', isEqualTo: false)
              .get();

      for (var doc in unreadNotificationsQuery.docs) {
        batch.update(doc.reference, {
          'read': true,
          'readAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
    } catch (e) {
      print('Error marking all notifications as read: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).delete();
    } catch (e) {
      print('Error deleting notification: $e');
    }
  }

  Future<void> createNotification({
    required String userId,
    required String title,
    required String message,
    required String type,
    String? relatedId,
  }) async {
    try {
      await _firestore.collection('notifications').add({
        'userId': userId,
        'title': title,
        'message': message,
        'type': type,
        'relatedId': relatedId,
        'read': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error creating notification: $e');
    }
  }

  // New method to create notification for a new donor
  Future<void> notifyNewDonorRegistered(
    String donorId,
    String bloodType,
    String city,
  ) async {
    try {
      // Get users who need this blood type and are in the same city
      final bloodRequests =
          await _firestore
              .collection('bloodRequests')
              .where('bloodType', isEqualTo: bloodType)
              .where('city', isEqualTo: city)
              .where('status', isEqualTo: 'Pending')
              .get();

      // For each blood request, notify the creator
      for (var doc in bloodRequests.docs) {
        final data = doc.data();
        final requesterId = data['createdBy'] as String?;

        if (requesterId != null &&
            requesterId.isNotEmpty &&
            requesterId != donorId) {
          await createNotification(
            userId: requesterId,
            title: 'New Donor Available',
            message:
                'A new donor with blood type $bloodType has registered in your city',
            type: 'new_donor',
            relatedId: donorId,
          );
        }
      }
    } catch (e) {
      print('Error notifying about new donor: $e');
    }
  }
}
