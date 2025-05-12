import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'create_request_page.dart';
import '../../controllers/blood_request_controller.dart';
import '../../models/blood_request.dart';

class BloodRequestsPage extends StatelessWidget {
  const BloodRequestsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Initialize the controller if not already done
    final bloodRequestController = Get.put(BloodRequestController());

    // Trigger data loading
    bloodRequestController.fetchBloodRequests();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Blood Requests'),
        backgroundColor: Colors.red,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterDialog(context, bloodRequestController);
            },
          ),
        ],
      ),
      body: Obx(() {
        if (bloodRequestController.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.red),
          );
        }

        if (bloodRequestController.bloodRequests.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.bloodtype_outlined,
                  size: 80,
                  color: Colors.red.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                const Text(
                  'No blood requests available',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Create a new request by tapping the + button',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: bloodRequestController.filteredRequests.length,
          itemBuilder: (context, index) {
            final request = bloodRequestController.filteredRequests[index];
            return _buildRequestCard(
              bloodType: request.bloodType,
              hospital: request.hospital,
              patientName: request.patientName,
              description: request.reason,
              isUrgent: request.urgency.toLowerCase() == 'urgent',
              date: _formatDate(
                request
                    .requestDate, // Changed back to requestDate since createdAt isn't defined
              ),
              onCallPressed: () {
                // Call action
                bloodRequestController.callRequester(request.contactNumber);
              },
              onMessagePressed: () {
                // Message action
                bloodRequestController.messageRequester(request.contactNumber);
              },
              onDetailsPressed: () {
                // View details action
                Get.toNamed('/request-detail', arguments: request);
              },
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => const CreateRequestPage()),
        backgroundColor: Colors.red.shade50,
        foregroundColor: Colors.red,
        child: const Icon(Icons.add),
      ),
      // Update the bottomNavigationBar section in the BloodRequestsPage
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Requests'),
          BottomNavigationBarItem(
            icon: Icon(Icons.volunteer_activism),
            label: 'Donate',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onTap: (index) {
          if (index == 0) {
            Get.offAllNamed('/home');
          } else if (index == 1) {
            // Already on requests page
          } else if (index == 2) {
            Get.toNamed('/donor-registration');
          } else if (index == 3) {
            Get.offAllNamed('/profile');
          }
        },
      ),
    );
  }

  Widget _buildRequestCard({
    required String bloodType,
    required String hospital,
    required String patientName,
    required String description,
    required bool isUrgent,
    required String date,
    required VoidCallback onCallPressed,
    required VoidCallback onMessagePressed,
    required VoidCallback onDetailsPressed,
  }) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
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
          // Status and Date
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isUrgent ? Colors.red.shade100 : Colors.green.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isUrgent ? 'Urgent' : 'Normal',
                    style: TextStyle(
                      color: isUrgent ? Colors.red : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(date, style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          ),

          // Blood Type and Hospital
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.red.shade100,
                  child: Text(
                    bloodType,
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
                        patientName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        hospital,
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Description
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(description, style: const TextStyle(fontSize: 14)),
          ),

          // Action Buttons - Made responsive
          Padding(
            padding: const EdgeInsets.all(16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // For smaller screens, stack buttons vertically
                if (constraints.maxWidth < 400) {
                  return Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: onCallPressed,
                          icon: const Icon(Icons.phone, size: 18),
                          label: const Text('Call'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: onMessagePressed,
                          icon: const Icon(Icons.message, size: 18),
                          label: const Text('Message'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: onDetailsPressed,
                          icon: const Icon(Icons.visibility, size: 18),
                          label: const Text('Details'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }

                // For larger screens, keep buttons in a row
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onCallPressed,
                        icon: const Icon(Icons.phone),
                        label: const Text('Call'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onMessagePressed,
                        icon: const Icon(Icons.message),
                        label: const Text('Message'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onDetailsPressed,
                        icon: const Icon(Icons.visibility),
                        label: const Text('Details'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showFilterDialog(
    BuildContext context,
    BloodRequestController controller,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Filter Requests'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('All Requests'),
                  leading: Radio<String>(
                    value: 'all',
                    groupValue: controller.currentFilter.value,
                    onChanged: (value) {
                      controller.setFilter(value!);
                      Get.back();
                    },
                    activeColor: Colors.red,
                  ),
                ),
                ListTile(
                  title: const Text('Urgent Only'),
                  leading: Radio<String>(
                    value: 'urgent',
                    groupValue: controller.currentFilter.value,
                    onChanged: (value) {
                      controller.setFilter(value!);
                      Get.back();
                    },
                    activeColor: Colors.red,
                  ),
                ),
                ListTile(
                  title: const Text('Normal Only'),
                  leading: Radio<String>(
                    value: 'normal',
                    groupValue: controller.currentFilter.value,
                    onChanged: (value) {
                      controller.setFilter(value!);
                      Get.back();
                    },
                    activeColor: Colors.red,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Cancel'),
              ),
            ],
          ),
    );
  }
}
