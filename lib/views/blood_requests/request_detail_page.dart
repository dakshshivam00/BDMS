import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/blood_request_controller.dart';
import '../../models/blood_request.dart';

class RequestDetailPage extends StatelessWidget {
  final BloodRequest request;
  
  const RequestDetailPage({
    Key? key,
    required this.request,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BloodRequestController>();
    
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
                color: request.urgency.toLowerCase() == 'urgent' 
                    ? Colors.red.shade50 
                    : Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: request.urgency.toLowerCase() == 'urgent' 
                              ? Colors.red.shade100 
                              : Colors.green.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          request.urgency,
                          style: TextStyle(
                            color: request.urgency.toLowerCase() == 'urgent' 
                                ? Colors.red 
                                : Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        'Status: ${request.status}',
                        style: TextStyle(
                          color: request.status == 'Pending' 
                              ? Colors.orange 
                              : Colors.green,
                          fontWeight: FontWeight.bold,
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
                            // Update the line that's causing the error (around line 76)
                            Text(
                              'Requested on ${_formatDate(request.requestDate)}',
                              style: TextStyle(
                                color: Colors.grey[600],
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
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      controller.callRequester(request.contactNumber);
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
                    onPressed: () {
                      controller.messageRequester(request.contactNumber);
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
                    onPressed: () {
                      _showConfirmationDialog(context, controller);
                    },
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Mark as Fulfilled'),
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
              ),
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
          Icon(
            icon,
            color: Colors.red,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
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

  void _showConfirmationDialog(BuildContext context, BloodRequestController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Action'),
        content: const Text('Are you sure you want to mark this request as fulfilled?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.updateRequestStatus(request.id, 'Fulfilled');
              Get.back();
              Get.back();
              Get.snackbar(
                'Success',
                'Request marked as fulfilled',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green.withOpacity(0.1),
                colorText: Colors.green,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}