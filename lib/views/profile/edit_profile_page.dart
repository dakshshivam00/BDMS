import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/user_controller.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
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
    final user = userController.currentUser.value;
    if (user != null) {
      _nameController.text = user.name;
      _emailController.text = user.email;
      _phoneController.text = user.phoneNumber;
      _addressController.text = user.address;
      _cityController.text = user.city;
      _stateController.text = user.state;
      _selectedBloodType = user.bloodType;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        elevation: 0,
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
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
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Phone',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    if (value.length < 10) {
                      return 'Please enter a valid phone number';
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
                CustomButton(text: 'Update Profile', onPressed: _updateProfile),
              ],
            ),
          ),
        );
      }),
    );
  }

  void _updateProfile() async {
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
        await userController.updateUserProfile(
          name: _nameController.text,
          email: _emailController.text,
          phoneNumber: _phoneController.text,
          address: _addressController.text,
          city: _cityController.text,
          state: _stateController.text,
          bloodType: _selectedBloodType,
        );

        Get.back();
        Get.snackbar(
          'Success',
          'Profile updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green,
        );
      } catch (e) {
        Get.snackbar(
          'Error',
          'Failed to update profile: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red,
        );
      }
    }
  }
}
