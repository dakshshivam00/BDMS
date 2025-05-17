import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/user_controller.dart';
import '../../models/user_model.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class UserSearchPage extends StatefulWidget {
  const UserSearchPage({Key? key}) : super(key: key);

  @override
  State<UserSearchPage> createState() => _UserSearchPageState();
}

class _UserSearchPageState extends State<UserSearchPage> {
  final _phoneController = TextEditingController();
  final userController = Get.find<UserController>();
  final RxBool _isSearching = false.obs;
  final Rx<UserModel?> _foundUser = Rx<UserModel?>(null);

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _searchUser() async {
    if (_phoneController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a phone number',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
      return;
    }

    try {
      _isSearching.value = true;
      await userController.fetchUserByPhone(_phoneController.text);
      _foundUser.value = userController.searchedUser.value;

      if (_foundUser.value == null) {
        Get.snackbar(
          'Not Found',
          'No user found with this phone number',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.withOpacity(0.1),
          colorText: Colors.orange,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to search user: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    } finally {
      _isSearching.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search User'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomTextField(
              label: 'Phone Number',
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              prefixIcon: const Icon(Icons.phone),
              hintText: 'Enter phone number to search',
            ),
            const SizedBox(height: 16),
            CustomButton(text: 'Search User', onPressed: _searchUser),
            const SizedBox(height: 24),
            Expanded(
              child: Obx(() {
                if (_isSearching.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.red),
                  );
                }

                final user = _foundUser.value;
                if (user == null) {
                  return const Center(
                    child: Text(
                      'No user found',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                return SingleChildScrollView(
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.red.shade100,
                              backgroundImage:
                                  user.profileImageUrl != null
                                      ? NetworkImage(user.profileImageUrl!)
                                      : null,
                              child:
                                  user.profileImageUrl == null
                                      ? const Icon(
                                        Icons.person,
                                        size: 50,
                                        color: Colors.red,
                                      )
                                      : null,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: Text(
                              user.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (user.bloodType.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade100,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'Blood Type: ${user.bloodType}',
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),
                          _buildInfoRow('Email', user.email),
                          _buildInfoRow('Phone', user.phoneNumber),
                          _buildInfoRow('Address', user.address),
                          _buildInfoRow('City', user.city),
                          _buildInfoRow('State', user.state),
                          if (user.isDonor) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Donor Information',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Donations: ${user.donationCount}',
                                    style: const TextStyle(color: Colors.green),
                                  ),
                                  if (user.lastDonationDate != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      'Last Donation: ${_formatDate(user.lastDonationDate!)}',
                                      style: const TextStyle(
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
