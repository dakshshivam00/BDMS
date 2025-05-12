import 'package:bdms1/views/home/dashboard_widgets/dashboard_card.dart';
import 'package:bdms1/views/profile/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../blood_requests/blood_requests_page.dart';
import '../blood_requests/create_request_page.dart';
import '../donor/donor_registration_page.dart';
import '../donors/donors_page.dart';
import 'dashboard_widgets/stat_card.dart';
import 'dashboard_widgets/action_card.dart';
import 'dashboard_widgets/request_list_item.dart';
import '../../controllers/blood_request_controller.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final bloodRequestController = Get.put(BloodRequestController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.red.shade50,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome back!',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    authController.getCurrentUserPhone(),
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

            // Statistics Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Statistics',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ),

            // Statistics Cards
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // In the Statistics Cards section, update the StatCard widgets to use dynamic data and make them tappable

                  // First StatCard (Total Donors)
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Get.to(() => const DonorsPage());
                      },
                      child: StatCard(
                        icon: Icons.people,
                        iconColor: Colors.blue,
                        value: '${bloodRequestController.totalDonors}',
                        label: 'Total Donors',
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Second StatCard (Active Requests)
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        // Navigate to blood requests page
                        Get.toNamed('/blood-requests');
                      },
                      child: StatCard(
                        icon: Icons.bloodtype,
                        iconColor: Colors.red,
                        value:
                            '${bloodRequestController.bloodRequests.where((r) => r.status == 'Pending').length}',
                        label: 'Active Requests',
                      ),
                    ),
                  ),

                  // Then remove the duplicate "Active Requests and Total Donors" section that was added later
                  // Delete this entire section:
                  /*
                  // Active Requests and Total Donors
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Active Requests',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Obx(() {
                                  return Text(
                                    '${bloodRequestController.bloodRequests.where((r) => r.status == 'Pending').length}',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Total Donors',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Obx(() {
                                  return Text(
                                    '${bloodRequestController.totalDonors}',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  */
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // Update the "Donations Today" StatCard to use the actual count
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        // Show today's donations in a dialog or navigate to a list
                        Get.dialog(
                          AlertDialog(
                            title: const Text('Today\'s Donations'),
                            content: SizedBox(
                              width: double.maxFinite,
                              child: Obx(() {
                                if (bloodRequestController
                                    .donationsToday
                                    .isEmpty) {
                                  return const Center(
                                    child: Text('No donations completed today'),
                                  );
                                }
                                return ListView.builder(
                                  shrinkWrap: true,
                                  itemCount:
                                      bloodRequestController
                                          .donationsToday
                                          .length,
                                  itemBuilder: (context, index) {
                                    final donation =
                                        bloodRequestController
                                            .donationsToday[index];
                                    return ListTile(
                                      title: Text(
                                        '${donation.patientName} (${donation.bloodType})',
                                      ),
                                      subtitle: Text(donation.hospital),
                                      trailing: Text(
                                        '${donation.completedAt!.hour}:${donation.completedAt!.minute}',
                                      ),
                                    );
                                  },
                                );
                              }),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Get.back(),
                                child: const Text('Close'),
                              ),
                            ],
                          ),
                        );
                      },
                      child: StatCard(
                        icon: Icons.favorite,
                        iconColor: Colors.green,
                        value: '${bloodRequestController.todayDonationsCount}',
                        label: 'Donations Today',
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: StatCard(
                      icon: Icons.warning,
                      iconColor: Colors.orange,
                      value: '1',
                      label: 'Urgent Cases',
                    ),
                  ),
                ],
              ),
            ),

            // Quick Actions
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ),

            // Action Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: ActionCard(
                      icon: Icons.bloodtype,
                      iconColor: Colors.red,
                      title: 'Request Blood',
                      onTap: () => Get.to(() => const CreateRequestPage()),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ActionCard(
                      icon: Icons.person_add,
                      iconColor: Colors.blue,
                      title: 'Register as Donor',
                      onTap: () => Get.to(() => const DonorRegistrationPage()),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: ActionCard(
                      icon: Icons.history,
                      iconColor: Colors.green,
                      title: 'View History',
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ActionCard(
                      icon: Icons.emergency,
                      iconColor: Colors.orange,
                      title: 'Emergency Contacts',
                      onTap: () {},
                    ),
                  ),
                ],
              ),
            ),

            // Active Requests and Total Donors
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Active Requests',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Obx(() {
                            return Text(
                              '${bloodRequestController.bloodRequests.where((r) => r.status == 'Pending').length}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total Donors',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Obx(() {
                            return Text(
                              '${bloodRequestController.totalDonors}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Recent Blood Requests
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Blood Requests',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      TextButton(
                        onPressed: () => Get.toNamed('/blood-requests'),
                        child: const Text(
                          'View All',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                  Obx(() {
                    if (bloodRequestController.recentRequests.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(child: Text('No recent blood requests')),
                      );
                    }

                    return Column(
                      children:
                          bloodRequestController.recentRequests.map((request) {
                            return RequestListItem(
                              bloodType: request.bloodType,
                              hospital: request.hospital,
                              isUrgent: request.urgency == 'Urgent',
                              contactNumber: request.contactNumber,
                              city: request.city,
                              onTap:
                                  () => Get.toNamed(
                                    '/request-detail',
                                    arguments: request,
                                  ),
                            );
                          }).toList(),
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
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
            // Already on home page
          } else if (index == 1) {
            Get.offAllNamed('/blood-requests');
          } else if (index == 2) {
            Get.toNamed('/donor-registration');
          } else if (index == 3) {
            Get.offAllNamed('/profile');
          }
        },
      ),
    );
  }
}
