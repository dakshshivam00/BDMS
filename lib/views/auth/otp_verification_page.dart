import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class OTPVerificationPage extends StatefulWidget {
  final String phoneNumber;

  const OTPVerificationPage({Key? key, required this.phoneNumber})
    : super(key: key);

  @override
  State<OTPVerificationPage> createState() => _OTPVerificationPageState();
}

class _OTPVerificationPageState extends State<OTPVerificationPage> {
  final otpController = TextEditingController();
  late AuthController authController;
  int timeLeft = 60;
  late Timer timer;
  bool canResend = false;

  // Check if using test mode
  bool get isTestMode =>
      AuthController.useTestOTP &&
      widget.phoneNumber == AuthController.testPhoneNumber;

  @override
  void initState() {
    super.initState();
    authController = Get.find<AuthController>();
    startTimer();

    // Auto-fill test OTP when in test mode
    if (isTestMode) {
      otpController.text = AuthController.testOTP;
    }
  }

  void startTimer() {
    canResend = false;
    timeLeft = 60;
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeLeft > 0) {
        setState(() {
          timeLeft--;
        });
      } else {
        timer.cancel();
        setState(() {
          canResend = true;
        });
      }
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OTP Verification'),
        backgroundColor: Colors.red,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Enter the OTP sent to +91 ${widget.phoneNumber}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('Edit'),
                    ),
                  ],
                ),

                const SizedBox(height: 8),
                const Text(
                  'OTP verification is required for all users. After verification, you\'ll be directed to your account or asked to complete your profile if needed.',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),

                // Test mode indicator
                if (isTestMode)
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.yellow.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.yellow.shade700),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.orange.shade800),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'TEST MODE: OTP is ${AuthController.testOTP}',
                            style: TextStyle(color: Colors.orange.shade900),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 20),
                CustomTextField(
                  label: 'OTP',
                  hint: 'Enter the 6-digit OTP',
                  controller: otpController,
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(Icons.lock),
                ),
                const SizedBox(height: 10),
                Center(
                  child: Text(
                    canResend
                        ? 'You can resend OTP now'
                        : 'Resend OTP in $timeLeft seconds',
                    style: TextStyle(
                      color: canResend ? Colors.blue : Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Obx(
                  () => CustomButton(
                    text: 'Verify OTP',
                    isLoading: authController.isLoading.value,
                    onPressed: () async {
                      if (otpController.text.isEmpty) {
                        Get.snackbar(
                          'Error',
                          'Please enter the OTP',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.red.withOpacity(0.1),
                          colorText: Colors.red,
                        );
                        return;
                      }

                      if (otpController.text.length < 6) {
                        Get.snackbar(
                          'Error',
                          'Please enter a valid 6-digit OTP',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.red.withOpacity(0.1),
                          colorText: Colors.red,
                        );
                        return;
                      }

                      try {
                        Get.snackbar(
                          'Verifying',
                          'Please wait while we verify your OTP...',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.blue.withOpacity(0.1),
                          colorText: Colors.blue,
                          duration: const Duration(seconds: 2),
                        );

                        // Store phone number in a global variable
                        authController.lastVerifiedPhone = widget.phoneNumber;

                        // Verify OTP
                        final result = await authController.verifyOTP(
                          otpController.text,
                        );
                        // Navigation is handled by the authController.checkUserExistsAndNavigate method
                      } catch (e) {
                        Get.snackbar(
                          'Error',
                          'Failed to verify OTP: ${e.toString()}',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.red.withOpacity(0.1),
                          colorText: Colors.red,
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: TextButton(
                    onPressed:
                        canResend
                            ? () async {
                              try {
                                startTimer();
                                await authController.sendOTP(
                                  widget.phoneNumber,
                                );
                                Get.snackbar(
                                  'Success',
                                  'OTP resent successfully',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.green.withOpacity(
                                    0.1,
                                  ),
                                  colorText: Colors.green,
                                );
                              } catch (e) {
                                Get.snackbar(
                                  'Error',
                                  'Failed to resend OTP: ${e.toString()}',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.red.withOpacity(0.1),
                                  colorText: Colors.red,
                                );
                              }
                            }
                            : null,
                    child: Text(
                      'Resend OTP',
                      style: TextStyle(
                        color: canResend ? Colors.blue : Colors.grey,
                      ),
                    ),
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
