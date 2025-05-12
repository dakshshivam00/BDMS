import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Rx<User?> currentUser = Rx<User?>(null);
  final isLoading = false.obs;
  String _verificationId = '';

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
  Future<bool> verifyOTP(String otp) async {
    try {
      isLoading.value = true;

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

      isLoading.value = false;

      // Show success message
      Get.snackbar(
        'Success',
        'Phone number verified successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green,
      );

      // Navigate to home page
      Get.offAllNamed('/home');

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

  // Check if user is logged in
  bool isLoggedIn() {
    return _auth.currentUser != null;
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      Get.offAllNamed('/login');
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to sign out: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Add this method to get the current user's ID
  String getCurrentUserId() {
    return _auth.currentUser?.uid ?? '';
  }

  // Add this method to get the current user's phone number if not already added
  String getCurrentUserPhone() {
    return currentUser.value?.phoneNumber ?? 'Not signed in';
  }

  // Add this method to your existing AuthController class

  // Add this method at the end of your class
  Future<bool> createUserInFirestore(String uid, String phoneNumber) async {
    try {
      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (!userDoc.exists) {
        // Create a new user document
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'uid': uid,
          'phoneNumber': phoneNumber,
          'name': '',
          'email': '',
          'bloodType': 'Unknown',
          'isDonor': false,
          'donationCount': 0,
          'createdAt': Timestamp.now(),
        });
      }

      return true;
    } catch (e) {
      print('Error creating user in Firestore: $e');
      return false;
    }
  }

  Future<void> signInWithPhoneNumber(String phoneNumber) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          Get.snackbar(
            'Error',
            e.message ?? 'Verification failed',
            snackPosition: SnackPosition.BOTTOM,
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          // Store verificationId for later use
          Get.toNamed(
            '/verify-otp',
            arguments: {
              'verificationId': verificationId,
              'phoneNumber': phoneNumber,
            },
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to send verification code: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  bool get isAuthenticated => currentUser.value != null;
}
