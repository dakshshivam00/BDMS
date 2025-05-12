import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class OTPVerificationPage extends StatefulWidget {
  final String phoneNumber;
  
  const OTPVerificationPage({
    Key? key, 
    required this.phoneNumber,
  }) : super(key: key);

  @override
  State<OTPVerificationPage> createState() => _OTPVerificationPageState();
}

class _OTPVerificationPageState extends State<OTPVerificationPage> {
  final otpController = TextEditingController();
  late AuthController authController;
  int timeLeft = 60;
  late Timer timer;
  bool canResend = false;

  @override
  void initState() {
    super.initState();
    authController = Get.find<AuthController>();
    startTimer();
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
      body: SafeArea(
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
              Obx(() => CustomButton(
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
                      
                      try {
                        final result = await authController.verifyOTP(otpController.text);
                        if (result) {
                          Get.snackbar(
                            'Success', 
                            'OTP verified successfully',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.green.withOpacity(0.1),
                            colorText: Colors.green,
                          );
                          // Navigate to home page or next screen
                        }
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
                  )),
              const SizedBox(height: 20),
              Center(
                child: TextButton(
                  onPressed: canResend ? () async {
                    try {
                      startTimer();
                      await authController.sendOTP(widget.phoneNumber);
                      Get.snackbar(
                        'Success', 
                        'OTP resent successfully',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.green.withOpacity(0.1),
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
                  } : null,
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
    );
  }
}