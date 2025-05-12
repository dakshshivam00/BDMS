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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
    Get.put(UserController(), permanent: true);

    return GetMaterialApp(
      title: 'Blood Donation Management System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: Colors.white,
      ),
      initialRoute: authController.isLoggedIn() ? '/home' : '/login',
      // In your GetMaterialApp
      getPages: [
        GetPage(name: '/login', page: () => const LoginPage()),
        GetPage(name: '/home', page: () => const HomePage()),
        GetPage(name: '/blood-requests', page: () => const BloodRequestsPage()),
        GetPage(
          name: '/donor-registration',
          page: () => const DonorRegistrationPage(),
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
      ],
    );
  }
}
