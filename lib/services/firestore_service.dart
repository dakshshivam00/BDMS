import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/blood_request_model.dart';
import '../models/donor_model.dart';
import '../models/notification_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Blood Requests Methods
  Future<List<BloodRequestModel>> getRequests(String status) async {
    final snapshot =
        await _firestore
            .collection('requests')
            .where('status', isEqualTo: status)
            .get();
    return snapshot.docs
        .map((doc) => BloodRequestModel.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  }

  Future<void> createRequest(BloodRequestModel request) async {
    await _firestore
        .collection('requests')
        .doc(request.id)
        .set(request.toJson());
  }

  Future<void> updateRequestStatus(String requestId, String status) async {
    await _firestore.collection('requests').doc(requestId).update({
      'status': status,
    });
  }

  // Donor Methods
  Future<List<DonorModel>> getAvailableDonors({
    String? bloodGroup,
    String? city,
  }) async {
    Query query = _firestore
        .collection('donors')
        .where('isAvailable', isEqualTo: true);

    if (bloodGroup != null) {
      query = query.where('bloodGroup', isEqualTo: bloodGroup);
    }
    if (city != null) {
      query = query.where('city', isEqualTo: city);
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map(
          (doc) => DonorModel.fromJson({
            ...(doc.data() as Map<String, dynamic>),
            'id': doc.id,
          }),
        )
        .toList();
  }

  Future<void> registerDonor(DonorModel donor) async {
    await _firestore.collection('donors').doc(donor.id).set(donor.toJson());
  }

  Future<void> updateDonorStatus(String donorId, bool isAvailable) async {
    await _firestore.collection('donors').doc(donorId).update({
      'isAvailable': isAvailable,
    });
  }

  // Notification Methods
  Future<List<NotificationModel>> getNotifications(String userId) async {
    final snapshot =
        await _firestore
            .collection('notifications')
            .where('userId', isEqualTo: userId)
            .orderBy('createdAt', descending: true)
            .get();
    return snapshot.docs
        .map((doc) => NotificationModel.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  }

  Future<void> createNotification(NotificationModel notification) async {
    await _firestore
        .collection('notifications')
        .doc(notification.id)
        .set(notification.toJson());
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).update({
      'isRead': true,
    });
  }

  Future<void> markAllNotificationsAsRead(String userId) async {
    final batch = _firestore.batch();
    final notifications =
        await _firestore
            .collection('notifications')
            .where('userId', isEqualTo: userId)
            .where('isRead', isEqualTo: false)
            .get();

    for (var doc in notifications.docs) {
      batch.update(doc.reference, {'isRead': true});
    }

    await batch.commit();
  }

  Future<void> deleteNotification(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).delete();
  }

  Future<bool> userExists(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    return doc.exists;
  }

  Future<UserModel> getUser(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (!doc.exists) {
      throw Exception('User not found');
    }
    return UserModel.fromMap({...doc.data()!, 'id': doc.id});
  }

  Future<void> createUser(UserModel user) async {
    await _firestore.collection('users').doc(user.id).set(user.toMap());
  }
}
