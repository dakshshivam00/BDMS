import 'package:bdms1/views/home/dashboard_widgets/dashboard_card.dart';
import 'package:bdms1/views/profile/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/user_controller.dart';
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
    final userController = Get.put(UserController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('BDMS'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Get.toNamed('/user-search'),
            tooltip: 'Search Users',
          ),
          Obx(() {
            final unreadCount = bloodRequestController.unreadNotificationsCount;
            return Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {
                    _showNotifications(context, bloodRequestController);
                  },
                ),
                if (unreadCount > 0)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        unreadCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            );
          }),
        ],
      ),
      body: Obx(() {
        if (userController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = userController.currentUser.value;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Card with User Info
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.red.shade100,
                      backgroundImage:
                          user?.profileImageUrl != null
                              ? NetworkImage(user!.profileImageUrl!)
                              : null,
                      child:
                          user?.profileImageUrl == null
                              ? const Icon(
                                Icons.person,
                                size: 30,
                                color: Colors.red,
                              )
                              : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back!',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            user?.name.isNotEmpty == true
                                ? user!.name
                                : authController.getCurrentUserPhone(),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          // if (user?.bloodType.isNotEmpty == true) ...[
                          //   const SizedBox(height: 4),
                          //   Container(
                          //     padding: const EdgeInsets.symmetric(
                          //       horizontal: 8,
                          //       vertical: 4,
                          //     ),
                          //     decoration: BoxDecoration(
                          //       color: Colors.red.shade100,
                          //       borderRadius: BorderRadius.circular(10),
                          //     ),
                          //     child: Text(
                          //       'Blood Type: ${user!.bloodType}',
                          //       style: const TextStyle(
                          //         color: Colors.red,
                          //         fontWeight: FontWeight.bold,
                          //       ),
                          //     ),
                          //   ),
                          // ],
                          // if (user?.isDonor == true) ...[
                          //   const SizedBox(height: 4),
                          //   Text(
                          //     'Registered Donor',
                          //     style: TextStyle(
                          //       color: Colors.green,
                          //       fontWeight: FontWeight.bold,
                          //     ),
                          //   ),
                          // ],
                        ],
                      ),
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
                    // First StatCard (Total Donors)
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Get.to(() => const DonorsPage());
                        },
                        child: Obx(
                          () => StatCard(
                            icon: Icons.people,
                            iconColor: Colors.blue,
                            value: '${bloodRequestController.totalDonors}',
                            label: 'Total Donors',
                          ),
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
                        child: Obx(
                          () => StatCard(
                            icon: Icons.bloodtype,
                            iconColor: Colors.red,
                            value:
                                '${bloodRequestController.bloodRequests.where((r) => r.status == 'Pending').length}',
                            label: 'Active Requests',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    // Donations Today StatCard
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          _showTodaysDonations(context, bloodRequestController);
                        },
                        child: Obx(
                          () => StatCard(
                            icon: Icons.favorite,
                            iconColor: Colors.green,
                            value:
                                '${bloodRequestController.todayDonationsCount}',
                            label: 'Donations Today',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Urgent Cases StatCard
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          // Navigate to filtered blood requests page
                          Get.to(
                            () => const BloodRequestsPage(
                              initialFilter: 'urgent',
                            ),
                          );
                        },
                        child: Obx(
                          () => StatCard(
                            icon: Icons.warning,
                            iconColor: Colors.orange,
                            value: '${bloodRequestController.urgentCasesCount}',
                            label: 'Urgent Cases',
                          ),
                        ),
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
                        onTap:
                            () => Get.to(() => const DonorRegistrationPage()),
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
                        onTap: () {
                          Get.to(
                            () => const BloodRequestsPage(
                              initialFilter: 'history',
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ActionCard(
                        icon: Icons.emergency,
                        iconColor: Colors.orange,
                        title: 'Emergency Contacts',
                        onTap: () {
                          _showEmergencyContacts(context);
                        },
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
                      if (bloodRequestController.isLoading.value) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      if (bloodRequestController.recentRequests.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(
                            child: Text('No recent blood requests'),
                          ),
                        );
                      }

                      return Column(
                        children:
                            bloodRequestController.recentRequests.map((
                              request,
                            ) {
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
        );
      }),
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

  void _showNotifications(
    BuildContext context,
    BloodRequestController controller,
  ) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Notifications',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Icon(Icons.notifications_outlined),
                ],
              ),
              const SizedBox(height: 16),
              Obx(() {
                if (controller.notifications.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: Text('No notifications yet')),
                  );
                }

                return ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 300),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: controller.notifications.length,
                    itemBuilder: (context, index) {
                      final notification = controller.notifications[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              notification['read'] == true
                                  ? Colors.grey.shade200
                                  : Colors.red.shade100,
                          child: Icon(
                            _getNotificationIcon(notification['type'] ?? ''),
                            color:
                                notification['read'] == true
                                    ? Colors.grey
                                    : Colors.red,
                          ),
                        ),
                        title: Text(notification['title'] ?? ''),
                        subtitle: Text(notification['message'] ?? ''),
                        onTap: () {
                          if (notification['read'] == false) {
                            controller.markNotificationAsRead(
                              notification['id'],
                            );
                          }
                          Get.back();

                          // Handle notification tap based on type
                          if (notification['type'] == 'blood_request') {
                            Get.toNamed('/blood-requests');
                          }
                        },
                      );
                    },
                  ),
                );
              }),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'blood_request':
        return Icons.bloodtype;
      case 'donor_registered':
        return Icons.person_add;
      case 'donation_complete':
        return Icons.volunteer_activism;
      default:
        return Icons.notifications;
    }
  }

  void _showTodaysDonations(
    BuildContext context,
    BloodRequestController controller,
  ) {
    Get.dialog(
      AlertDialog(
        title: const Text('Today\'s Donations'),
        content: SizedBox(
          width: double.maxFinite,
          child: Obx(() {
            if (controller.donationsToday.isEmpty) {
              return const Center(child: Text('No donations completed today'));
            }
            return ListView.builder(
              shrinkWrap: true,
              itemCount: controller.donationsToday.length,
              itemBuilder: (context, index) {
                final donation = controller.donationsToday[index];
                return ListTile(
                  title: Text(
                    '${donation.patientName} (${donation.bloodType})',
                  ),
                  subtitle: Text(donation.hospital),
                  trailing: Text(
                    donation.completedAt != null
                        ? '${donation.completedAt!.hour}:${donation.completedAt!.minute}'
                        : '',
                  ),
                );
              },
            );
          }),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Close')),
        ],
      ),
    );
  }

  void _showEmergencyContacts(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Emergency Contacts'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.local_hospital, color: Colors.red),
              title: const Text('Ambulance'),
              subtitle: const Text('108'),
              onTap: () => _launchPhoneCall('108'),
            ),
            ListTile(
              leading: const Icon(Icons.medical_services, color: Colors.red),
              title: const Text('Blood Bank'),
              subtitle: const Text('+91 1234567890'),
              onTap: () => _launchPhoneCall('+911234567890'),
            ),
            ListTile(
              leading: const Icon(Icons.health_and_safety, color: Colors.red),
              title: const Text('Medical Helpline'),
              subtitle: const Text('104'),
              onTap: () => _launchPhoneCall('104'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Close')),
        ],
      ),
    );
  }

  void _launchPhoneCall(String phoneNumber) async {
    Get.find<BloodRequestController>().callRequester(phoneNumber);
  }
}
