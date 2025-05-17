import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/blood_request_controller.dart';
import '../../controllers/user_controller.dart';
import '../../controllers/notification_controller.dart';
import '../../models/blood_request.dart';

class RequestDetailPage extends StatelessWidget {
  final BloodRequest request;

  const RequestDetailPage({Key? key, required this.request}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloodRequestController = Get.find<BloodRequestController>();
    final userController = Get.put(UserController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Details'),
        backgroundColor: Colors.red,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:
                    request.urgency.toLowerCase() == 'urgent'
                        ? Colors.red.shade50
                        : Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color:
                              request.urgency.toLowerCase() == 'urgent'
                                  ? Colors.red.shade100
                                  : Colors.green.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          request.urgency,
                          style: TextStyle(
                            color:
                                request.urgency.toLowerCase() == 'urgent'
                                    ? Colors.red
                                    : Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(
                            request.status,
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          request.status,
                          style: TextStyle(
                            color: _getStatusColor(request.status),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Text(
                          request.bloodType,
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              request.patientName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Requested on ${_formatDate(request.requestDate)}',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            if (request.status == 'Fulfilled' &&
                                request.completedAt != null)
                              Text(
                                'Fulfilled on ${_formatDate(request.completedAt!)}',
                                style: TextStyle(
                                  color: Colors.green[600],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Details Section
            const Text(
              'Request Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            _buildDetailItem(
              icon: Icons.local_hospital,
              title: 'Hospital',
              value: request.hospital,
            ),

            _buildDetailItem(
              icon: Icons.location_on,
              title: 'City',
              value: request.city,
            ),

            _buildDetailItem(
              icon: Icons.description,
              title: 'Reason',
              value: request.reason,
            ),

            _buildDetailItem(
              icon: Icons.phone,
              title: 'Contact',
              value: request.contactNumber,
            ),

            const SizedBox(height: 24),

            // Action Buttons
            if (request.status == 'Pending')
              Obx(() {
                final isLoading =
                    bloodRequestController.isLoading.value ||
                    userController.isLoading.value;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton.icon(
                      onPressed:
                          isLoading
                              ? null
                              : () {
                                bloodRequestController.callRequester(
                                  request.contactNumber,
                                );
                              },
                      icon: const Icon(Icons.phone),
                      label: const Text('Call Requester'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    ElevatedButton.icon(
                      onPressed:
                          isLoading
                              ? null
                              : () {
                                bloodRequestController.messageRequester(
                                  request.contactNumber,
                                );
                              },
                      icon: const Icon(Icons.message),
                      label: const Text('Message Requester'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    ElevatedButton.icon(
                      onPressed:
                          isLoading
                              ? null
                              : () => _showDonationDialog(
                                context,
                                bloodRequestController,
                                userController,
                              ),
                      icon:
                          isLoading
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                              : const Icon(Icons.volunteer_activism),
                      label: const Text('I Want to Donate'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.red, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Fulfilled':
        return Colors.green;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showDonationDialog(
    BuildContext context,
    BloodRequestController bloodRequestController,
    UserController userController,
  ) {
    final user = userController.currentUser.value;

    if (user == null) {
      Get.snackbar(
        'Error',
        'User information not found',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
      return;
    }

    // Check if user's blood type matches request
    if (user.bloodType != request.bloodType) {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Blood Type Mismatch'),
              content: Text(
                'Your blood type (${user.bloodType}) does not match the requested blood type (${request.bloodType}). Are you sure you want to proceed?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Get.back();
                    _showConfirmationDialog(
                      context,
                      bloodRequestController,
                      userController,
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Proceed Anyway'),
                ),
              ],
            ),
      );
    } else {
      _showConfirmationDialog(context, bloodRequestController, userController);
    }
  }

  void _showConfirmationDialog(
    BuildContext context,
    BloodRequestController bloodRequestController,
    UserController userController,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm Donation'),
            content: const Text(
              'Are you confirming that you will donate blood for this request? '
              'The system will mark this request as fulfilled once you confirm.',
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Get.back(); // Close dialog

                  try {
                    // Update request status to Fulfilled
                    await bloodRequestController.updateRequestStatus(
                      request.id,
                      'Fulfilled',
                    );

                    // Increment donation count for the user
                    await userController.incrementDonationCount();

                    // Create a notification for the request creator
                    final notificationController = Get.put(
                      NotificationController(),
                    );
                    await notificationController.createNotification(
                      userId: request.createdBy,
                      title: 'Request Fulfilled',
                      message:
                          'Your blood request for ${request.patientName} has been fulfilled',
                      type: 'donation_complete',
                      relatedId: request.id,
                    );

                    Get.back(); // Return to previous screen

                    Get.snackbar(
                      'Thank You!',
                      'You have successfully committed to donate blood',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.green.withOpacity(0.1),
                      colorText: Colors.green,
                      duration: const Duration(seconds: 5),
                    );
                  } catch (e) {
                    Get.snackbar(
                      'Error',
                      'Failed to complete donation: $e',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.red.withOpacity(0.1),
                      colorText: Colors.red,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Confirm Donation'),
              ),
            ],
          ),
    );
  }
}
