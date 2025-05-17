import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../controllers/user_controller.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Rx<User?> currentUser = Rx<User?>(null);
  final isLoading = false.obs;
  String _verificationId = '';

  // Store the last verified phone number
  String lastVerifiedPhone = '';

  // Test credentials for development - COMMENT OUT IN PRODUCTION
  static const String testPhoneNumber = "7668494931";
  static const String testOTP = "121212";

  // Additional test phone numbers for verification
  static const List<String> testPhoneNumbers = [
    "7668494931", // Original test number
    "9876543210",
    "8765432109",
    "7654321098",
    "6543210987",
    "5432109876",
    "4321098765",
    "3210987654",
    "2109876543",
    "9988776655",
    // Adding Firebase test numbers from the screenshot
    "98765 43210",
    "76543 21098",
    "3210 987 654",
    "99887 76655",
    "2109 876 543",
    "76684 94931",
    "6543 210 987",
    "4321 098 765",
    "87654 32109",
    "5432 109 876",
  ];

  // Set this to false to use real Firebase OTP authentication
  static const bool useTestOTP = true;

  @override
  void onInit() {
    super.onInit();
    currentUser.value = _auth.currentUser;
    _auth.authStateChanges().listen((User? user) {
      currentUser.value = user;
    });
  }

  // Send OTP to the provided phone number
  Future<bool> sendOTP(String phoneNumber) async {
    try {
      isLoading.value = true;

      // DEVELOPMENT ONLY: For test phone number, bypass actual OTP sending
      // COMMENT THIS SECTION FOR PRODUCTION
      if (useTestOTP && testPhoneNumbers.contains(phoneNumber)) {
        print('Using test phone number: $phoneNumber - OTP is: $testOTP');
        _verificationId = "test-verification-id";
        isLoading.value = false;
        return true;
      }
      // END DEVELOPMENT SECTION

      // Format phone number with country code
      String formattedPhone = phoneNumber;
      if (!phoneNumber.startsWith('+')) {
        formattedPhone = '+91$phoneNumber'; // Adding India country code
      }

      print('Sending OTP to: $formattedPhone');

      await _auth.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification on some Android devices
          print('Auto verification completed');
          await _auth.signInWithCredential(credential);
          isLoading.value = false;
          // Check if user exists and navigate accordingly
          await checkUserExistsAndNavigate();
        },
        verificationFailed: (FirebaseAuthException e) {
          print('Verification failed: ${e.message}');
          isLoading.value = false;
          throw e;
        },
        codeSent: (String verificationId, int? resendToken) {
          print('Code sent successfully, verification ID: $verificationId');
          _verificationId = verificationId;
          isLoading.value = false;
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          print('Auto retrieval timeout');
          _verificationId = verificationId;
          isLoading.value = false;
        },
      );

      return true;
    } catch (e) {
      print('Error sending OTP: $e');
      isLoading.value = false;
      throw e;
    }
  }

  // Verify the OTP entered by the user
  Future<bool> verifyOTP(String otp, {Map<String, dynamic>? arguments}) async {
    try {
      isLoading.value = true;

      // DEVELOPMENT ONLY: For test phone/OTP, bypass actual verification
      // COMMENT THIS SECTION FOR PRODUCTION
      if (useTestOTP && otp == testOTP) {
        print('Using test OTP verification');

        // Instead of using signInAnonymously which requires admin privileges,
        // we'll simulate a successful sign-in by checking if we're already signed in
        // or by directly navigating to the appropriate screen

        // Get the current phone number being verified
        String testPhoneNumber = lastVerifiedPhone;

        if (testPhoneNumber.isEmpty) {
          // Fallback to first test number if no last verified phone
          testPhoneNumber = testPhoneNumbers[0];
          print('No last verified phone, using default: $testPhoneNumber');
        } else {
          print('Using last verified phone number: $testPhoneNumber');
        }

        // This is a unique ID generated for test users based on phone number
        // This ensures each test phone creates a unique user
        String testUserId = 'test-${testPhoneNumber.replaceAll(' ', '')}';
        print(
          'Generated test user ID: $testUserId based on phone: $testPhoneNumber',
        );

        // Simulate user authentication by updating the auth state
        currentUser.value = null; // Reset current user

        // Setup phone number for lookup
        String formattedPhone = '+91$testPhoneNumber';

        // Check if a user with this phone number already exists in Firestore
        try {
          final querySnapshot =
              await _firestore
                  .collection('users')
                  .where('phoneNumber', isEqualTo: formattedPhone)
                  .limit(1)
                  .get();

          if (querySnapshot.docs.isNotEmpty) {
            // User already exists, get the user data
            print('Found existing user with phone number: $formattedPhone');
            final userData = querySnapshot.docs.first.data();
            final existingUserId = userData['id'];

            print('Existing user ID: $existingUserId');

            // Navigate based on profile completeness
            if (userData['name'] != null &&
                userData['name'].toString().isNotEmpty) {
              print("User exists with complete profile, navigating to home");
              Get.offAllNamed('/home');
            } else {
              print(
                "User exists but profile incomplete, navigating to profile setup",
              );
              Get.offAllNamed('/profile-setup');
            }
          } else {
            // No user found with this phone number, create a new user record
            print("Creating new user for test phone number: $formattedPhone");

            await _firestore.collection('users').doc(testUserId).set({
              'id': testUserId,
              'phoneNumber': formattedPhone,
              'name': '',
              'email': '',
              'bloodType': '',
              'isDonor': false,
              'donationCount': 0,
              'address': '',
              'city': '',
              'state': '',
              'createdAt': FieldValue.serverTimestamp(),
            });

            // Update user controller
            try {
              final userController = Get.find<UserController>();
              await userController.fetchCurrentUserByPhone(formattedPhone);
            } catch (e) {
              print('Error refreshing user data: $e');
            }

            print(
              "New user created for test phone, navigating to profile setup",
            );
            Get.offAllNamed('/profile-setup');
          }

          isLoading.value = false;
          return true;
        } catch (e) {
          print('Error checking user by phone number: $e');
          isLoading.value = false;

          // Navigate to profile setup as fallback
          Get.offAllNamed('/profile-setup');
          return true;
        }
      }
      // END DEVELOPMENT SECTION

      if (_verificationId.isEmpty) {
        throw Exception('Verification ID is empty. Please request OTP again.');
      }

      print('Verifying OTP: $otp with verification ID: $_verificationId');

      // Create a PhoneAuthCredential with the code
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: otp,
      );

      // Sign in the user with the credential
      UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      // Force update the current user value
      currentUser.value = userCredential.user;

      print('User signed in: ${userCredential.user?.uid}');

      // Show success message
      Get.snackbar(
        'Success',
        'Phone number verified successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green,
      );

      isLoading.value = false;

      // Check if user exists and navigate accordingly
      await checkUserExistsAndNavigate();

      return true;
    } catch (e) {
      print('Error verifying OTP: $e');
      isLoading.value = false;

      // Show error message
      Get.snackbar(
        'Error',
        'Failed to verify OTP: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );

      throw e;
    }
  }

  // Check if user exists in Firestore and navigate accordingly
  Future<void> checkUserExistsAndNavigate() async {
    try {
      final userId = getCurrentUserId();

      // For test users, we need a different approach since there's no actual Firebase auth
      bool isTestUser = userId.isEmpty || userId.startsWith('test-');
      String userIdToUse = userId;

      if (isTestUser) {
        // If we're in test mode and don't have a real Firebase user
        print("Test user detected or empty ID. Handling specially.");

        // Get the last verified phone number
        String phoneToCheck = '';

        if (lastVerifiedPhone.isNotEmpty) {
          phoneToCheck = '+91${lastVerifiedPhone}';
          userIdToUse = 'test-${lastVerifiedPhone.replaceAll(' ', '')}';
          print("Using test ID: $userIdToUse for phone $phoneToCheck");
        }

        if (phoneToCheck.isEmpty) {
          print("No verified phone number found, redirecting to login");
          Get.offAllNamed('/login');
          return;
        }
      } else if (userId.isEmpty) {
        print("Error: Empty user ID when checking user existence");
        // Instead of going back to login, we'll fix the issue - maybe the currentUser wasn't set properly
        print(
          "User ID is empty but we should be authenticated. Checking auth status...",
        );

        if (_auth.currentUser != null) {
          print(
            "Auth shows user is logged in with ID: ${_auth.currentUser!.uid}",
          );
          // Force update the user ID
          currentUser.value = _auth.currentUser;

          // Try again with the correct user ID
          await checkUserExistsAndNavigate();
          return;
        } else {
          print("No authenticated user found in Firebase Auth");
          Get.offAllNamed('/login');
          return;
        }
      }

      print("Checking if user exists in Firestore, UID: $userIdToUse");

      // Get phone number from authenticated user
      String phoneNumber = currentUser.value?.phoneNumber ?? '';
      if (phoneNumber.isEmpty) {
        // If phone number is empty, we're probably in test mode
        // Use a test phone number or the first one from our list
        phoneNumber = '+91${testPhoneNumbers[0]}';
        print("Using test phone number: $phoneNumber for lookup");
      } else {
        print(
          "Using authenticated user's phone number: $phoneNumber for lookup",
        );
      }

      // First try to find user by userId
      var userDoc = await _firestore.collection('users').doc(userIdToUse).get();

      // If not found by userId, try by phone number
      if (!userDoc.exists) {
        print(
          "User not found by ID, trying to find by phone number: $phoneNumber",
        );
        final querySnapshot =
            await _firestore
                .collection('users')
                .where('phoneNumber', isEqualTo: phoneNumber)
                .limit(1)
                .get();

        if (querySnapshot.docs.isNotEmpty) {
          userDoc = querySnapshot.docs.first;
          print("Found user by phone number instead of ID");
        }
      }

      if (userDoc.exists) {
        final userData = userDoc.data();
        print("Found user data: $userData");

        // If we found user by phone number, update the userId field
        if (userDoc.id != userIdToUse) {
          print(
            "User found by phone number, updating userId from ${userDoc.id} to $userIdToUse",
          );
          await _firestore.collection('users').doc(userDoc.id).update({
            'id': userIdToUse,
          });

          // Also create a reference at the new ID
          await _firestore.collection('users').doc(userIdToUse).set(userData!);
        }

        // Refresh user data in UserController
        try {
          final userController = Get.find<UserController>();
          await userController.fetchCurrentUser();
        } catch (e) {
          print('Error refreshing user data: $e');
        }

        // Check if user profile is complete
        if (userData != null &&
            userData['name'] != null &&
            userData['name'].toString().isNotEmpty) {
          // User exists and has a complete profile, go to home
          print("User exists with complete profile, navigating to home");
          Get.offAllNamed('/home');
        } else {
          // User exists but profile is incomplete, go to profile setup
          print(
            "User exists but profile incomplete, navigating to profile setup",
          );
          Get.offAllNamed('/profile-setup');
        }
      } else {
        // User doesn't exist in Firestore, create basic record and go to profile setup
        print("User doesn't exist in Firestore, creating new user");

        await _firestore.collection('users').doc(userIdToUse).set({
          'id': userIdToUse,
          'phoneNumber': phoneNumber,
          'name': '',
          'email': '',
          'bloodType': '',
          'isDonor': false,
          'donationCount': 0,
          'address': '',
          'city': '',
          'state': '',
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Refresh user data in UserController
        try {
          final userController = Get.find<UserController>();
          await userController.fetchCurrentUser();
        } catch (e) {
          print('Error refreshing user data: $e');
        }

        print("New user created, navigating to profile setup");
        Get.offAllNamed('/profile-setup');
      }
    } catch (e) {
      print('Error checking user existence: $e');
      // Default to profile setup if there's an error
      Get.offAllNamed('/profile-setup');
    }
  }

  // Check if user is logged in
  bool isLoggedIn() {
    return _auth.currentUser != null;
  }

  // Sign out
  Future<void> signOut() async {
    try {
      // Clear user data from UserController
      final userController = Get.find<UserController>();
      userController.clearUserData();

      // Clear last verified phone
      lastVerifiedPhone = '';

      // Sign out from Firebase
      await _auth.signOut();

      // Clear local auth data
      currentUser.value = null;

      // Navigate to login page
      Get.offAllNamed('/login');
    } catch (e) {
      print('Error during sign out: $e');
      Get.snackbar(
        'Error',
        'Failed to sign out: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    }
  }

  // Get the current user's ID
  String getCurrentUserId() {
    // First check if we have a Firebase user
    String? firebaseUid = _auth.currentUser?.uid;
    if (firebaseUid != null && firebaseUid.isNotEmpty) {
      return firebaseUid;
    }

    // If no Firebase user, check if we're using a test phone number
    if (lastVerifiedPhone.isNotEmpty) {
      // Generate test user ID from phone number
      return 'test-${lastVerifiedPhone.replaceAll(' ', '')}';
    }

    // If we have neither, return empty string
    return '';
  }

  // Get the current user's phone number
  String getCurrentUserPhone() {
    // First check Firebase user's phone
    String? firebasePhone = currentUser.value?.phoneNumber;
    if (firebasePhone != null && firebasePhone.isNotEmpty) {
      return firebasePhone;
    }

    // If no Firebase phone, check if we have a test phone
    if (lastVerifiedPhone.isNotEmpty) {
      return '+91${lastVerifiedPhone}';
    }

    return 'Not signed in';
  }

  // Add this method at the end of your class
  Future<bool> createUserInFirestore(String uid, String phoneNumber) async {
    try {
      // Check if this is a test phone number
      bool isTestPhone = false;
      String testUserId = uid;

      // Strip the country code for comparison
      String phoneWithoutCode = phoneNumber;
      if (phoneNumber.startsWith('+91')) {
        phoneWithoutCode = phoneNumber.substring(3);
      }

      // Check if this is one of our test phone numbers
      if (useTestOTP && testPhoneNumbers.contains(phoneWithoutCode)) {
        isTestPhone = true;
        testUserId = 'test-${phoneWithoutCode.replaceAll(' ', '')}';
        print('Using test user ID: $testUserId for phone $phoneNumber');
      }

      // Document ID depends on whether this is a test user or real user
      String docId = isTestPhone ? testUserId : uid;

      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(docId).get();

      if (!userDoc.exists) {
        // Create a new user document
        await FirebaseFirestore.instance.collection('users').doc(docId).set({
          'id': docId,
          'phoneNumber': phoneNumber,
          'name': '',
          'email': '',
          'bloodType': '',
          'isDonor': false,
          'donationCount': 0,
          'address': '',
          'city': '',
          'state': '',
          'createdAt': Timestamp.now(),
        });
      }

      return true;
    } catch (e) {
      print('Error creating user in Firestore: $e');
      return false;
    }
  }

  bool get isAuthenticated => currentUser.value != null;
}
