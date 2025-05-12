import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../models/user_model.dart';

class UserController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCurrentUser();
  }

  Future<void> fetchCurrentUser() async {
    try {
      isLoading.value = true;
      final auth = Get.find<AuthController>();
      final userId = auth.getCurrentUserId();

      if (userId.isEmpty) {
        currentUser.value = null;
        return;
      }

      final doc = await _firestore.collection('users').doc(userId).get();

      if (doc.exists) {
        currentUser.value = UserModel.fromMap(doc.data()!);
      } else {
        // Create a new user document if it doesn't exist
        final newUser = UserModel(
          id: userId,
          name: '',
          email: auth.currentUser.value?.email ?? '',
          phoneNumber: auth.currentUser.value?.phoneNumber ?? '',
          bloodType: '',
          isDonor: false,
          donationCount: 0,
          address: '',
          city: '',
          state: '',
          profileImageUrl: null,
          lastDonationDate: null,
        );

        await _firestore.collection('users').doc(userId).set(newUser.toMap());
        currentUser.value = newUser;
      }
    } catch (e) {
      print('Error fetching user: $e');
      Get.snackbar(
        'Error',
        'Failed to fetch user data',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateUserProfile({
    required String name,
    required String email,
    required String phoneNumber,
    required String address,
    required String city,
    required String state,
    String? bloodType,
  }) async {
    try {
      isLoading.value = true;
      final userId = currentUser.value?.id;

      if (userId == null) {
        throw Exception('User not found');
      }

      final updatedData = {
        'name': name,
        'email': email,
        'phoneNumber': phoneNumber,
        'address': address,
        'city': city,
        'state': state,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (bloodType != null) {
        updatedData['bloodType'] = bloodType;
      }

      await _firestore.collection('users').doc(userId).update(updatedData);

      // Update local user data
      currentUser.value = currentUser.value?.copyWith(
        name: name,
        email: email,
        phoneNumber: phoneNumber,
        address: address,
        city: city,
        state: state,
        bloodType: bloodType ?? currentUser.value?.bloodType,
      );
    } catch (e) {
      print('Error updating user profile: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProfileImage(String imageUrl) async {
    try {
      isLoading.value = true;
      final userId = currentUser.value?.id;

      if (userId == null) {
        throw Exception('User not found');
      }

      await _firestore.collection('users').doc(userId).update({
        'profileImageUrl': imageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update local user data
      currentUser.value = currentUser.value?.copyWith(
        profileImageUrl: imageUrl,
      );
    } catch (e) {
      print('Error updating profile image: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateDonorStatus({
    required bool isDonor,
    required String bloodType,
  }) async {
    try {
      isLoading.value = true;
      final userId = currentUser.value?.id;

      if (userId == null) {
        throw Exception('User not found');
      }

      final updatedData = {
        'isDonor': isDonor,
        'bloodType': bloodType,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('users').doc(userId).update(updatedData);

      // Update local user data
      currentUser.value = currentUser.value?.copyWith(
        isDonor: isDonor,
        bloodType: bloodType,
      );
    } catch (e) {
      print('Error updating donor status: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> incrementDonationCount() async {
    try {
      isLoading.value = true;
      final userId = currentUser.value?.id;

      if (userId == null) {
        throw Exception('User not found');
      }

      final newCount = (currentUser.value?.donationCount ?? 0) + 1;

      await _firestore.collection('users').doc(userId).update({
        'donationCount': newCount,
        'lastDonationDate': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update local user data
      currentUser.value = currentUser.value?.copyWith(
        donationCount: newCount,
        lastDonationDate: DateTime.now(),
      );
    } catch (e) {
      print('Error incrementing donation count: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<UserModel?> getUserById(String userId) async {
    try {
      final docSnapshot =
          await _firestore.collection('users').doc(userId).get();

      if (docSnapshot.exists) {
        return UserModel.fromMap(docSnapshot.data() as Map<String, dynamic>);
      }

      return null;
    } catch (e) {
      print('Error getting user by ID: $e');
      return null;
    }
  }

  Future<bool> registerAsDonor({
    required String bloodType,
    DateTime? lastDonationDate,
  }) async {
    try {
      isLoading.value = true;
      final userId = currentUser.value?.id;

      if (userId == null) {
        throw Exception('User not found');
      }

      final updatedData = {
        'isDonor': true,
        'bloodType': bloodType,
        'lastDonationDate':
            lastDonationDate != null
                ? Timestamp.fromDate(lastDonationDate)
                : null,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('users').doc(userId).update(updatedData);

      // Update local user data
      currentUser.value = currentUser.value?.copyWith(
        isDonor: true,
        bloodType: bloodType,
        lastDonationDate: lastDonationDate,
      );

      return true;
    } catch (e) {
      print('Error registering as donor: $e');
      Get.snackbar(
        'Error',
        'Failed to register as donor: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
