import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/user_controller.dart';

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
  String _selectedBloodType = 'A+';
  final List<String> _bloodTypes = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
    'Unknown',
  ];

  final userController = Get.find<UserController>();

  // Add these controllers to the _EditProfilePageState class
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();

  // Update the initState method
  @override
  void initState() {
    super.initState();

    final user = userController.currentUser.value;
    if (user != null) {
      _nameController.text = user.name;
      _emailController.text = user.email;
      _phoneController.text = user.phoneNumber;
      _selectedBloodType = user.bloodType;
      _addressController.text = user.address;
      _cityController.text = user.city;
      _stateController.text = user.state;
    }
  }

  // Update the dispose method
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
        backgroundColor: Colors.red,
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
                // Profile Image
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.red.shade100,
                        backgroundImage:
                            userController.currentUser.value?.profileImageUrl !=
                                    null
                                ? NetworkImage(
                                  userController
                                      .currentUser
                                      .value!
                                      .profileImageUrl!,
                                )
                                : null,
                        child:
                            userController.currentUser.value?.profileImageUrl ==
                                    null
                                ? const Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Colors.red,
                                )
                                : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 20,
                          child: IconButton(
                            icon: const Icon(
                              Icons.camera_alt,
                              color: Colors.red,
                              size: 20,
                            ),
                            onPressed: () {
                              // Image upload functionality would go here
                              Get.snackbar(
                                'Feature Coming Soon',
                                'Profile image upload will be available soon',
                                snackPosition: SnackPosition.BOTTOM,
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Name
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Email
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value != null &&
                        value.isNotEmpty &&
                        !GetUtils.isEmail(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Phone
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Blood Type
                DropdownButtonFormField<String>(
                  value: _selectedBloodType,
                  decoration: InputDecoration(
                    labelText: 'Blood Type',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.bloodtype),
                  ),
                  items:
                      _bloodTypes.map((String type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedBloodType = newValue;
                      });
                    }
                  },
                ),
                const SizedBox(height: 24),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
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
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Save Changes',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
