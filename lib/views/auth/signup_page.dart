import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../home/home_page.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();
    final ageController = TextEditingController();
    final bloodGroupController = TextEditingController();
    final addressController = TextEditingController();
    final cityController = TextEditingController();
    final stateController = TextEditingController();
    final pincodeController = TextEditingController();

    final authController = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextField(
              label: 'Full Name',
              controller: nameController,
              hint: 'Enter your full name',
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Age',
              controller: ageController,
              keyboardType: TextInputType.number,
              hint: 'Enter your age',
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Blood Group',
              controller: bloodGroupController,
              hint: 'Select your blood group',
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Address',
              controller: addressController,
              hint: 'Enter your address',
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'City',
              controller: cityController,
              hint: 'Enter your city',
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'State',
              controller: stateController,
              hint: 'Enter your state',
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Pin Code',
              controller: pincodeController,
              keyboardType: TextInputType.number,
              hint: 'Enter pin code',
            ),
            const SizedBox(height: 24),
            Obx(() => CustomButton(
                  text: 'Complete Signup',
                  isLoading: authController.isLoading.value,
                  onPressed: () async {
                    // Handle signup logic here
                    Get.offAll(() => const HomePage());
                  },
                )),
          ],
        ),
      ),
    );
  }
}