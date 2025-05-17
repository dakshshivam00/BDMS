import 'package:get/get.dart';
import '../models/blood_request.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../controllers/auth_controller.dart';

class BloodRequestController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final bloodRequests = <BloodRequest>[].obs;
  final totalDonors = 0.obs;
  final donationsToday = <BloodRequest>[].obs;
  final isLoading = false.obs;
  final currentFilter = 'all'.obs;
  final urgentCasesCount = 0.obs;
  final notifications = <Map<String, dynamic>>[].obs;

  StreamSubscription? _requestsSubscription;
  StreamSubscription? _donorsSubscription;
  StreamSubscription? _notificationsSubscription;

  @override
  void onInit() {
    super.onInit();
    fetchBloodRequests();
    fetchTotalDonors();
    fetchNotifications();
  }

  @override
  void onClose() {
    _requestsSubscription?.cancel();
    _donorsSubscription?.cancel();
    _notificationsSubscription?.cancel();
    super.onClose();
  }

  // Fetch blood requests from Firestore
  void fetchBloodRequests() {
    isLoading.value = true;

    try {
      _requestsSubscription = _firestore
          .collection('bloodRequests')
          .orderBy('requestDate', descending: true)
          .snapshots()
          .listen(
            (snapshot) {
              bloodRequests.clear();

              for (var doc in snapshot.docs) {
                final data = doc.data();
                bloodRequests.add(
                  BloodRequest(
                    id: doc.id,
                    patientName: data['patientName'] ?? '',
                    bloodType: data['bloodType'] ?? '',
                    hospital: data['hospital'] ?? '',
                    reason: data['reason'] ?? '',
                    contactNumber: data['contactNumber'] ?? '',
                    urgency: data['urgency'] ?? 'Normal',
                    status: data['status'] ?? 'Pending',
                    requestDate: (data['requestDate'] as Timestamp).toDate(),
                    completedAt:
                        data['completedAt'] != null
                            ? (data['completedAt'] as Timestamp).toDate()
                            : null,
                    city: data['city'] ?? '',
                    createdBy: data['createdBy'] ?? '',
                  ),
                );
              }

              // Update urgent cases count
              urgentCasesCount.value =
                  bloodRequests
                      .where(
                        (req) =>
                            req.urgency == 'Urgent' && req.status == 'Pending',
                      )
                      .length;

              // Update today's donations
              final now = DateTime.now();
              donationsToday.value =
                  bloodRequests
                      .where(
                        (req) =>
                            req.status == 'Fulfilled' &&
                            req.completedAt != null &&
                            req.completedAt!.day == now.day &&
                            req.completedAt!.month == now.month &&
                            req.completedAt!.year == now.year,
                      )
                      .toList();

              isLoading.value = false;
            },
            onError: (error) {
              print('Error fetching blood requests: $error');
              isLoading.value = false;
            },
          );
    } catch (e) {
      print('Error setting up blood requests listener: $e');
      isLoading.value = false;
    }
  }

  // Fetch total donors count
  void fetchTotalDonors() {
    try {
      _donorsSubscription = _firestore
          .collection('users')
          .where('isDonor', isEqualTo: true)
          .snapshots()
          .listen(
            (snapshot) {
              totalDonors.value = snapshot.size;
            },
            onError: (error) {
              print('Error fetching donors: $error');
            },
          );
    } catch (e) {
      print('Error setting up donors listener: $e');
    }
  }

  // Fetch notifications
  void fetchNotifications() {
    try {
      final authController = Get.find<AuthController>();
      final userId = authController.getCurrentUserId();

      if (userId.isEmpty) return;

      _notificationsSubscription = _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(10)
          .snapshots()
          .listen(
            (snapshot) {
              notifications.clear();

              for (var doc in snapshot.docs) {
                notifications.add({'id': doc.id, ...doc.data()});
              }
            },
            onError: (error) {
              print('Error fetching notifications: $error');
            },
          );
    } catch (e) {
      print('Error setting up notifications listener: $e');
    }
  }

  // Set filter for blood requests
  void setFilter(String filter) {
    currentFilter.value = filter;
    update();
  }

  // Get filtered blood requests
  List<BloodRequest> get filteredRequests {
    if (currentFilter.value == 'all') {
      return bloodRequests;
    } else if (currentFilter.value == 'urgent') {
      return bloodRequests
          .where(
            (req) =>
                req.urgency.toLowerCase() == 'urgent' &&
                req.status == 'Pending',
          )
          .toList();
    } else if (currentFilter.value == 'normal') {
      return bloodRequests
          .where(
            (req) =>
                req.urgency.toLowerCase() == 'normal' &&
                req.status == 'Pending',
          )
          .toList();
    } else if (currentFilter.value == 'history') {
      return bloodRequests.where((req) => req.status == 'Fulfilled').toList();
    }
    return bloodRequests;
  }

  // Get recent requests (last 5)
  List<BloodRequest> get recentRequests {
    final sorted =
        bloodRequests.where((req) => req.status == 'Pending').toList()
          ..sort((a, b) => b.requestDate.compareTo(a.requestDate));
    return sorted.take(5).toList();
  }

  // Add a new blood request
  Future<void> addBloodRequest({
    required String patientName,
    required String bloodType,
    required String hospital,
    required String reason,
    required String contactNumber,
    required String urgency,
    required String city,
  }) async {
    try {
      isLoading.value = true;

      final authController = Get.find<AuthController>();
      final userId = authController.getCurrentUserId();

      final newRequest = {
        'patientName': patientName,
        'bloodType': bloodType,
        'hospital': hospital,
        'reason': reason,
        'contactNumber': contactNumber,
        'urgency': urgency,
        'status': 'Pending',
        'requestDate': FieldValue.serverTimestamp(),
        'city': city,
        'createdBy': userId,
      };

      await _firestore.collection('bloodRequests').add(newRequest);

      // Create notification for all donors with matching blood type
      await _createRequestNotification(bloodType, patientName, hospital);

      isLoading.value = false;
    } catch (e) {
      print('Error adding blood request: $e');
      isLoading.value = false;
      throw e;
    }
  }

  // Create notification for all matching donors
  Future<void> _createRequestNotification(
    String bloodType,
    String patientName,
    String hospital,
  ) async {
    try {
      // Get all donors with matching blood type
      final donorsSnapshot =
          await _firestore
              .collection('users')
              .where('isDonor', isEqualTo: true)
              .where('bloodType', isEqualTo: bloodType)
              .get();

      final batch = _firestore.batch();

      for (var donorDoc in donorsSnapshot.docs) {
        final notificationRef = _firestore.collection('notifications').doc();
        batch.set(notificationRef, {
          'userId': donorDoc.id,
          'title': 'Blood Request',
          'message':
              'New $bloodType blood request for $patientName at $hospital',
          'type': 'blood_request',
          'read': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
    } catch (e) {
      print('Error creating notification: $e');
    }
  }

  // Update request status
  Future<void> updateRequestStatus(String requestId, String newStatus) async {
    try {
      isLoading.value = true;

      final updateData = {
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (newStatus == 'Fulfilled') {
        updateData['completedAt'] = FieldValue.serverTimestamp();
      }

      await _firestore
          .collection('bloodRequests')
          .doc(requestId)
          .update(updateData);

      isLoading.value = false;
    } catch (e) {
      print('Error updating request status: $e');
      isLoading.value = false;
      throw e;
    }
  }

  // Call requester
  void callRequester(String phoneNumber) async {
    final Uri url = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      Get.snackbar(
        'Error',
        'Could not launch phone call',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Message requester
  void messageRequester(String phoneNumber) async {
    final Uri url = Uri.parse('sms:$phoneNumber');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      Get.snackbar(
        'Error',
        'Could not launch messaging app',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Get count of donations completed today
  int get todayDonationsCount => donationsToday.length;

  // Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({
        'read': true,
        'readAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  // Get unread notifications count
  int get unreadNotificationsCount {
    return notifications
        .where((notification) => notification['read'] == false)
        .length;
  }
}
