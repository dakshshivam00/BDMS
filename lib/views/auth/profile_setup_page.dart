import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/user_controller.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../controllers/auth_controller.dart';

class ProfileSetupPage extends StatefulWidget {
  const ProfileSetupPage({Key? key}) : super(key: key);

  @override
  State<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final userController = Get.find<UserController>();
  String _selectedBloodType = '';

  final List<String> _bloodTypes = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  @override
  void initState() {
    super.initState();

    // Try to populate any existing user data
    final user = userController.currentUser.value;
    if (user != null) {
      if (user.name.isNotEmpty) _nameController.text = user.name;
      if (user.email.isNotEmpty) _emailController.text = user.email;
      if (user.address.isNotEmpty) _addressController.text = user.address;
      if (user.city.isNotEmpty) _cityController.text = user.city;
      if (user.state.isNotEmpty) _stateController.text = user.state;
      if (user.bloodType.isNotEmpty) _selectedBloodType = user.bloodType;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Check if user already exists (has phone number) or is completely new
    final isExistingUser =
        userController.currentUser.value?.phoneNumber?.isNotEmpty ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isExistingUser ? 'Complete Your Profile' : 'Create Profile',
        ),
        backgroundColor: Colors.red,
        automaticallyImplyLeading: false, // Disable back button
      ),
      body: Obx(() {
        if (userController.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.red),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isExistingUser ? 'Welcome Back!' : 'Welcome to BDMS!',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isExistingUser
                      ? 'Please complete your profile information to continue.'
                      : 'This is your first time logging in. Please create your profile to use the app.',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 24),

                // Profile image placeholder
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.red.shade100,
                    child: const Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.red,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                const Text(
                  'Personal Information',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Full Name',
                  controller: _nameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!GetUtils.isEmail(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                const Text(
                  'Blood Information',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      hint: const Text('Select Blood Type'),
                      value:
                          _selectedBloodType.isNotEmpty
                              ? _selectedBloodType
                              : null,
                      onChanged: (value) {
                        setState(() {
                          _selectedBloodType = value ?? '';
                        });
                      },
                      items:
                          _bloodTypes.map((String bloodType) {
                            return DropdownMenuItem<String>(
                              value: bloodType,
                              child: Text(bloodType),
                            );
                          }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                const Text(
                  'Address Information',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Address',
                  controller: _addressController,
                  maxLines: 2,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'City',
                  controller: _cityController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your city';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'State',
                  controller: _stateController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your state';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                CustomButton(
                  text:
                      isExistingUser
                          ? 'Update Profile & Continue'
                          : 'Create Profile & Continue',
                  onPressed: _saveProfile,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedBloodType.isEmpty) {
        Get.snackbar(
          'Error',
          'Please select your blood type',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red,
        );
        return;
      }

      try {
        print('Starting profile save process...');
        final auth = Get.find<AuthController>();
        final phoneNumber = auth.getCurrentUserPhone();

        print('Current auth state:');
        print('Phone Number: $phoneNumber');
        print('User ID: ${auth.getCurrentUserId()}');
        print('Is logged in: ${auth.isLoggedIn()}');

        print('Attempting to update user profile...');
        await userController.updateUserProfile(
          name: _nameController.text,
          email: _emailController.text,
          phoneNumber: phoneNumber,
          address: _addressController.text,
          city: _cityController.text,
          state: _stateController.text,
          bloodType: _selectedBloodType,
        );

        print('Profile updated successfully, navigating to home...');
        Get.snackbar(
          'Success',
          'Profile created successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green,
        );

        // Navigate to home page
        Get.offAllNamed('/home');
      } catch (e) {
        print('Error in _saveProfile:');
        print('Error details: $e');
        print('Stack trace: ${StackTrace.current}');

        Get.snackbar(
          'Error',
          'Failed to create profile: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red,
          duration: const Duration(seconds: 5),
        );
      }
    }
  }
}
