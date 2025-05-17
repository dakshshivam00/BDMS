import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/blood_request_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../models/blood_request.dart';
import '../../widgets/custom_button.dart';

class ViewRequestsPage extends StatefulWidget {
  const ViewRequestsPage({Key? key}) : super(key: key);

  @override
  State<ViewRequestsPage> createState() => _ViewRequestsPageState();
}

class _ViewRequestsPageState extends State<ViewRequestsPage> {
  final bloodRequestController = Get.put(BloodRequestController());
  final authController = Get.find<AuthController>();
  final RxList<BloodRequest> myRequests = <BloodRequest>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void initState() {
    super.initState();
    fetchMyRequests();
  }

  Future<void> fetchMyRequests() async {
    try {
      isLoading.value = true;
      bloodRequestController.fetchBloodRequests();
      await Future.delayed(
        const Duration(milliseconds: 500),
      ); // Wait for data to load

      final userId = authController.getCurrentUserId();

      // Filter requests to show only those created by the current user
      myRequests.value =
          bloodRequestController.bloodRequests
              .where((request) => request.createdBy == userId)
              .toList();
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Blood Requests'),
          backgroundColor: Colors.red,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Pending'),
              Tab(text: 'Fulfilled'),
              Tab(text: 'All'),
            ],
            indicatorColor: Colors.white,
          ),
        ),
        body: Obx(() {
          if (isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.red),
            );
          }

          if (myRequests.isEmpty) {
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
                    'No blood requests found',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'You haven\'t created any blood requests yet',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    text: 'Create New Request',
                    onPressed: () => Get.toNamed('/create-request'),
                  ),
                ],
              ),
            );
          }

          return TabBarView(
            children: [
              _buildRequestsList('Pending'),
              _buildRequestsList('Fulfilled'),
              _buildRequestsList('All'),
            ],
          );
        }),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.red,
          onPressed: () => Get.toNamed('/create-request'),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildRequestsList(String status) {
    List<BloodRequest> filteredRequests;

    if (status == 'All') {
      filteredRequests = myRequests;
    } else {
      filteredRequests =
          myRequests.where((request) => request.status == status).toList();
    }

    if (filteredRequests.isEmpty) {
      return Center(child: Text('No $status requests found'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredRequests.length,
      itemBuilder: (context, index) {
        final request = filteredRequests[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${request.bloodType} Blood Needed',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(request.status),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        request.status.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildInfoRow(Icons.person, 'Patient: ${request.patientName}'),
                _buildInfoRow(Icons.local_hospital, request.hospital),
                _buildInfoRow(Icons.location_on, request.city),
                _buildInfoRow(
                  Icons.access_time,
                  'Created: ${_formatDate(request.requestDate)}',
                ),
                if (request.status == 'Fulfilled' &&
                    request.completedAt != null)
                  _buildInfoRow(
                    Icons.check_circle_outline,
                    'Fulfilled: ${_formatDate(request.completedAt!)}',
                  ),
                const SizedBox(height: 16),
                if (request.status == 'Pending')
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: 'Edit Request',
                          onPressed: () {
                            // Navigate to edit page
                            Get.toNamed('/edit-request', arguments: request);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: CustomButton(
                          text: 'Cancel Request',
                          onPressed: () async {
                            final confirm = await Get.dialog<bool>(
                              AlertDialog(
                                title: const Text('Cancel Request'),
                                content: const Text(
                                  'Are you sure you want to cancel this blood request?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Get.back(result: false),
                                    child: const Text('No'),
                                  ),
                                  TextButton(
                                    onPressed: () => Get.back(result: true),
                                    child: const Text('Yes'),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              // Cancel the request
                              await bloodRequestController.updateRequestStatus(
                                request.id,
                                'Cancelled',
                              );
                              fetchMyRequests();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Flexible(child: Text(text)),
        ],
      ),
    );
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
