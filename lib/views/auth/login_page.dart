import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import 'otp_verification_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final phoneController = TextEditingController();
    final authController = Get.put(AuthController(), permanent: true);

    // Set test number when in test mode
    if (AuthController.useTestOTP) {
      // Show test phone numbers in a dropdown
      phoneController.text = AuthController.testPhoneNumbers[0];
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                Image.asset(
                  'assets/images/logo.png',
                  height: 120,
                  errorBuilder: (context, error, stackTrace) {
                    print('Error loading image: $error');
                    return const Icon(Icons.image, size: 120);
                  },
                ),
                const SizedBox(height: 40),
                const Text(
                  'Welcome to Blood Donation\nManagement System',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Phone verification is required for all users',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 40),

                // Test mode indicator
                if (AuthController.useTestOTP)
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.yellow.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.yellow.shade700),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.orange.shade800,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'DEVELOPMENT MODE',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Using test OTP: ${AuthController.testOTP}\nSelect a test phone number below',
                          style: TextStyle(color: Colors.orange.shade900),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Each test phone number creates a separate user account',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),

                // Show test phone numbers dropdown when in test mode
                if (AuthController.useTestOTP)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: phoneController.text,
                        hint: const Text('Select test phone number'),
                        items:
                            AuthController.testPhoneNumbers.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text('Test Phone: $value'),
                              );
                            }).toList(),
                        onChanged: (newValue) {
                          if (newValue != null) {
                            phoneController.text = newValue;
                          }
                        },
                      ),
                    ),
                  ),

                // Phone number field with country code prefix
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: 56,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text('+91', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: CustomTextField(
                        label: 'Phone Number',
                        hint: 'Enter your 10-digit number',
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        prefixIcon: const Icon(Icons.phone),
                        maxLength: 10,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Obx(
                  () => CustomButton(
                    text: 'Send OTP',
                    isLoading: authController.isLoading.value,
                    onPressed: () async {
                      if (phoneController.text.isEmpty) {
                        Get.snackbar(
                          'Error',
                          'Please enter a phone number',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.red.withOpacity(0.1),
                          colorText: Colors.red,
                        );
                        return;
                      }

                      if (phoneController.text.length != 10) {
                        Get.snackbar(
                          'Error',
                          'Please enter a valid 10-digit phone number',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.red.withOpacity(0.1),
                          colorText: Colors.red,
                        );
                        return;
                      }

                      try {
                        Get.snackbar(
                          'Processing',
                          'Sending OTP to +91 ${phoneController.text}',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.blue.withOpacity(0.1),
                          colorText: Colors.blue,
                        );

                        final result = await authController.sendOTP(
                          phoneController.text,
                        );
                        if (result) {
                          Get.snackbar(
                            'Success',
                            'OTP sent successfully',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.green.withOpacity(0.1),
                            colorText: Colors.green,
                          );
                          Get.to(
                            () => OTPVerificationPage(
                              phoneNumber: phoneController.text,
                            ),
                          );
                        }
                      } catch (e) {
                        Get.snackbar(
                          'Error',
                          'Failed to send OTP: ${e.toString()}',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.red.withOpacity(0.1),
                          colorText: Colors.red,
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
