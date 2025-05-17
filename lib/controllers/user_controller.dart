import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../models/user_model.dart';
import '../controllers/notification_controller.dart';

class UserController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final Rx<UserModel?> searchedUser = Rx<UserModel?>(null);
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

      print('Fetching user data for ID: $userId');

      if (userId.isEmpty) {
        print('No user ID found, clearing user data');
        currentUser.value = null;
        return;
      }

      // Check if this is a test user
      bool isTestUser = userId.startsWith('test-');
      print('Is test user: $isTestUser');

      if (isTestUser) {
        // For test users, try to fetch by phone number first
        String phoneNumber = auth.getCurrentUserPhone();
        print('Fetching test user by phone: $phoneNumber');

        final querySnapshot =
            await _firestore
                .collection('users')
                .where('phoneNumber', isEqualTo: phoneNumber)
                .limit(1)
                .get();

        if (querySnapshot.docs.isNotEmpty) {
          final userData = querySnapshot.docs.first.data();
          print('Found test user data: $userData');
          currentUser.value = UserModel.fromMap(userData);
          return;
        }
      }

      // If not a test user or test user not found by phone, try by ID
      final doc = await _firestore.collection('users').doc(userId).get();
      print('Firestore document fetched: ${doc.exists}');

      if (doc.exists) {
        final userData = doc.data()!;
        print('User data found: $userData');
        currentUser.value = UserModel.fromMap(userData);
        print('Current user updated: ${currentUser.value?.name}');
      } else {
        print('No user document found, creating new user');
        // Create a new user document if it doesn't exist
        final newUser = UserModel(
          id: userId,
          name: '',
          email: auth.currentUser.value?.email ?? '',
          phoneNumber: auth.getCurrentUserPhone(),
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
        print('New user created and saved');
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

  void clearUserData() {
    print('Clearing user data');
    currentUser.value = null;
    searchedUser.value = null;
    isLoading.value = false;
  }

  // Add this method to fetch user by phone number for test users
  Future<void> fetchCurrentUserByPhone(String phoneNumber) async {
    try {
      isLoading.value = true;

      print('Fetching test user by phone number: $phoneNumber');

      // Query Firestore to find user by phone number
      final querySnapshot =
          await _firestore
              .collection('users')
              .where('phoneNumber', isEqualTo: phoneNumber)
              .limit(1)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Found user by phone number
        final userData = querySnapshot.docs.first.data();
        print('Found user data by phone: $userData');

        // Create UserModel from data
        currentUser.value = UserModel.fromMap(userData);
        print('Updated current user: ${currentUser.value?.id}');
      } else {
        // No user found with this phone number
        print('No user found with phone number: $phoneNumber');
        currentUser.value = null;
      }
    } catch (e) {
      print('Error fetching user by phone: $e');
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

  Future<void> createNewUser({
    required String userId,
    required String phoneNumber,
    String name = '',
    String email = '',
    String bloodType = '',
    String address = '',
    String city = '',
    String state = '',
  }) async {
    try {
      print('Starting new user creation process...');
      print('User ID: $userId');
      print('Phone Number: $phoneNumber');

      // Verify if user already exists
      final existingUser =
          await _firestore.collection('users').doc(userId).get();
      if (existingUser.exists) {
        print('User document already exists, updating instead of creating');
      }

      final newUser = UserModel(
        id: userId,
        name: name,
        email: email,
        phoneNumber: phoneNumber,
        bloodType: bloodType,
        isDonor: false,
        donationCount: 0,
        address: address,
        city: city,
        state: state,
        profileImageUrl: null,
        lastDonationDate: null,
      );

      print('Creating/updating user document with data: ${newUser.toMap()}');
      await _firestore.collection('users').doc(userId).set(newUser.toMap());
      currentUser.value = newUser;
      print('User document created/updated successfully');
    } catch (e) {
      print('Error in createNewUser: $e');
      print('Stack trace: ${StackTrace.current}');
      throw e;
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
      final auth = Get.find<AuthController>();
      final userId = auth.getCurrentUserId();

      print('Updating profile for user ID: $userId');

      if (userId.isEmpty) {
        throw Exception('User not found');
      }

      // Check if user document exists
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        print('User document not found, creating new user');
        // Create new user if document doesn't exist
        await createNewUser(
          userId: userId,
          phoneNumber: phoneNumber,
          name: name,
          email: email,
          bloodType: bloodType ?? '',
          address: address,
          city: city,
          state: state,
        );
      } else {
        print('Updating existing user document');
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
      }

      // Refresh current user data
      await fetchCurrentUser();

      print('Profile updated successfully');
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

      print(
        'Starting donor registration for user $userId with blood type: $bloodType',
      );

      if (userId == null) {
        throw Exception('User not found');
      }

      // Verify user has required information
      if (currentUser.value?.name.isEmpty ?? true) {
        Get.snackbar(
          'Missing Information',
          'Please update your profile with your name before registering as a donor',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.withOpacity(0.1),
          colorText: Colors.orange,
        );
        return false;
      }

      if (currentUser.value?.phoneNumber.isEmpty ?? true) {
        Get.snackbar(
          'Missing Information',
          'Please update your profile with your phone number before registering as a donor',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.withOpacity(0.1),
          colorText: Colors.orange,
        );
        return false;
      }

      if (currentUser.value?.city.isEmpty ?? true) {
        Get.snackbar(
          'Missing Information',
          'Please update your profile with your city before registering as a donor',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.withOpacity(0.1),
          colorText: Colors.orange,
        );
        return false;
      }

      print('User has all required fields. Proceeding with registration...');

      final updatedData = {
        'isDonor': true,
        'bloodType': bloodType,
        'lastDonationDate':
            lastDonationDate != null
                ? Timestamp.fromDate(lastDonationDate)
                : null,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      print('Updating Firestore document with donor data...');
      await _firestore.collection('users').doc(userId).update(updatedData);
      print('Firestore document updated successfully');

      // Update local user data
      currentUser.value = currentUser.value?.copyWith(
        isDonor: true,
        bloodType: bloodType,
        lastDonationDate: lastDonationDate,
      );
      print('Local user data updated');

      // Notify users who need this blood type
      try {
        print('Attempting to notify users about new donor...');
        final notificationController = Get.find<NotificationController>();
        await notificationController.notifyNewDonorRegistered(
          userId,
          bloodType,
          currentUser.value?.city ?? '',
        );
        print('Notifications sent successfully');
      } catch (e) {
        print('Error sending notifications about new donor: $e');
        // Continue with registration even if notification fails
      }

      print('Donor registration completed successfully');

      // Notify UI to update donors list
      update(['donors_list']);

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

  // New method to fetch all donors
  Future<List<UserModel>> fetchAllDonors({String? bloodType}) async {
    try {
      print(
        'Starting donor fetch from Firestore. Filter by blood type: $bloodType',
      );

      Query query = _firestore
          .collection('users')
          .where('isDonor', isEqualTo: true);

      if (bloodType != null && bloodType != 'All') {
        query = query.where('bloodType', isEqualTo: bloodType);
      }

      print('Executing Firestore query for donors...');
      // Force a server fetch instead of using cache
      final snapshot = await query.get();
      print('Donor query complete. Found ${snapshot.docs.length} donors.');

      final List<UserModel> donors = [];
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final donor = UserModel.fromMap({...data, 'id': doc.id});
        print('Adding donor: ${donor.name} (${donor.bloodType})');
        donors.add(donor);
      }

      return donors;
    } catch (e) {
      print('Error fetching donors: $e');
      return [];
    }
  }

  Future<void> fetchUserByPhone(String phoneNumber) async {
    try {
      isLoading.value = true;

      // Query Firestore to find user by phone number
      final querySnapshot =
          await _firestore
              .collection('users')
              .where('phoneNumber', isEqualTo: phoneNumber)
              .limit(1)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Found user by phone number
        final userData = querySnapshot.docs.first.data();
        searchedUser.value = UserModel.fromMap(userData);
      } else {
        // No user found with this phone number
        searchedUser.value = null;
      }
    } catch (e) {
      print('Error fetching user by phone: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }
}
