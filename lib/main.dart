import 'package:bdms1/views/blood_requests/request_detail_page.dart';
import 'package:bdms1/views/donor/donor_registration_page.dart';
import 'package:bdms1/views/profile/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'controllers/auth_controller.dart';
import 'views/auth/login_page.dart';
import 'views/home/home_page.dart';
import 'views/blood_requests/blood_requests_page.dart';
import 'views/blood_requests/create_request_page.dart';
import 'controllers/user_controller.dart';
import 'views/donor/available_donors_page.dart';
import 'views/auth/profile_setup_page.dart';
import 'views/profile/user_search_page.dart';
import 'package:flutter/foundation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Suppress debug logging in development
  if (!kReleaseMode) {
    debugPrint = (String? message, {int? wrapWidth}) {};
  }

  try {
    await Firebase.initializeApp();
    print("Firebase initialized successfully");
  } catch (e) {
    print("Failed to initialize Firebase: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Initialize controllers
    final authController = Get.put(AuthController(), permanent: true);
    final userController = Get.put(UserController(), permanent: true);

    return GetMaterialApp(
      title: 'Blood Donation Management System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: Colors.white,
      ),
      initialRoute: '/login',
      onInit: () async {
        print("App initialization started");
        // Check if user is already logged in
        if (authController.isLoggedIn()) {
          print("User is logged in, fetching user data");
          try {
            // For test users, we need to ensure we have the phone number
            String userId = authController.getCurrentUserId();
            if (userId.startsWith('test-')) {
              // Extract phone number from test user ID
              String phoneNumber = userId.replaceAll('test-', '');
              authController.lastVerifiedPhone = phoneNumber;
              print("Restored test user phone number: $phoneNumber");
            }

            await userController.fetchCurrentUser();
            print("User data fetched successfully");

            // Check if user has a complete profile
            if (userController.currentUser.value != null &&
                userController.currentUser.value!.name.isNotEmpty) {
              print("User has complete profile, navigating to home");
              Get.offAllNamed('/home');
            } else {
              print("User profile incomplete, navigating to profile setup");
              Get.offAllNamed('/profile-setup');
            }
          } catch (e) {
            print("Error during initialization: $e");
            // If there's an error, redirect to login
            Get.offAllNamed('/login');
          }
        } else {
          print("No user logged in");
        }
      },
      getPages: [
        GetPage(name: '/login', page: () => const LoginPage()),
        GetPage(name: '/home', page: () => const HomePage()),
        GetPage(name: '/profile-setup', page: () => const ProfileSetupPage()),
        GetPage(name: '/blood-requests', page: () => const BloodRequestsPage()),
        GetPage(
          name: '/donor-registration',
          page: () => const DonorRegistrationPage(),
        ),
        GetPage(
          name: '/available-donors',
          page: () => const AvailableDonorsPage(),
        ),
        GetPage(name: '/profile', page: () => const ProfilePage()),
        GetPage(
          name: '/request-detail',
          page: () {
            if (Get.arguments != null) {
              return RequestDetailPage(request: Get.arguments);
            } else {
              // Handle the case when arguments are not provided
              // You could redirect to another page or show an error
              Get.snackbar(
                'Error',
                'Request details not found',
                snackPosition: SnackPosition.BOTTOM,
              );
              return const BloodRequestsPage();
            }
          },
        ),
        GetPage(name: '/create-request', page: () => const CreateRequestPage()),
        GetPage(name: '/user-search', page: () => const UserSearchPage()),
      ],
    );
  }
}
