import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/user_model.dart';
import '../../controllers/user_controller.dart';
import '../../controllers/blood_request_controller.dart';
import '../../widgets/custom_button.dart';

class AvailableDonorsPage extends StatefulWidget {
  const AvailableDonorsPage({Key? key}) : super(key: key);

  @override
  State<AvailableDonorsPage> createState() => _AvailableDonorsPageState();
}

class _AvailableDonorsPageState extends State<AvailableDonorsPage>
    with WidgetsBindingObserver {
  final TextEditingController _searchController = TextEditingController();
  final _userController = Get.find<UserController>();
  final _bloodRequestController = Get.find<BloodRequestController>();

  final RxList<UserModel> _donors = <UserModel>[].obs;
  final RxBool _isLoading = true.obs;
  final RxString _selectedBloodType = 'All'.obs;

  final List<String> _bloodTypes = [
    'All',
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  String _searchLocation = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    fetchDonors();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refetch donors when dependencies change
    fetchDonors();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh data when app is resumed
      fetchDonors();
    }
  }

  Future<void> fetchDonors() async {
    try {
      _isLoading.value = true;

      print("Fetching donors from Firestore...");
      // Use the new fetchAllDonors method from UserController
      final donors = await _userController.fetchAllDonors(
        bloodType:
            _selectedBloodType.value == 'All' ? null : _selectedBloodType.value,
      );

      print("Found ${donors.length} donors");
      _donors.value = donors;

      // Update the controller to refresh the UI
      _userController.update(['donors_list']);
    } catch (e) {
      print('Error fetching donors: $e');
      Get.snackbar(
        'Error',
        'Failed to fetch donors',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  List<UserModel> get filteredDonors {
    if (_searchLocation.isEmpty) return _donors;

    return _donors.where((donor) {
      final address = donor.address.toLowerCase();
      final city = donor.city.toLowerCase();
      final state = donor.state.toLowerCase();
      final searchTerm = _searchLocation.toLowerCase();

      return address.contains(searchTerm) ||
          city.contains(searchTerm) ||
          state.contains(searchTerm);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Donors'),
        backgroundColor: Colors.red,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchDonors,
            tooltip: 'Refresh donor list',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.red.shade50,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search by location...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchLocation = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.filter_list),
                      tooltip: 'Filter by blood type',
                      onSelected: (String value) {
                        _selectedBloodType.value = value;
                        fetchDonors();
                      },
                      itemBuilder: (BuildContext context) {
                        return _bloodTypes.map((String bloodType) {
                          return PopupMenuItem<String>(
                            value: bloodType,
                            child: Text(bloodType),
                          );
                        }).toList();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Obx(
                  () => Text(
                    'Selected Blood Type: ${_selectedBloodType.value}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: GetBuilder<UserController>(
              id: 'donors_list',
              builder: (controller) {
                return Obx(() {
                  if (_isLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.red),
                    );
                  }

                  final donors = filteredDonors;

                  if (donors.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 80,
                            color: Colors.grey.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No donors found',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Try adjusting your search criteria',
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 24),
                          CustomButton(
                            text: 'Register as Donor',
                            onPressed: () => Get.toNamed('/donor-registration'),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: fetchDonors,
                    color: Colors.red,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: donors.length,
                      itemBuilder: (context, index) {
                        final donor = donors[index];
                        final lastDonation = donor.lastDonationDate;
                        final timeSinceLastDonation =
                            lastDonation != null
                                ? _getTimeSinceLastDonation(lastDonation)
                                : 'Never';

                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.red.shade100,
                                    backgroundImage:
                                        donor.profileImageUrl != null
                                            ? NetworkImage(
                                              donor.profileImageUrl!,
                                            )
                                            : null,
                                    child:
                                        donor.profileImageUrl == null
                                            ? Text(
                                              donor.bloodType,
                                              style: const TextStyle(
                                                color: Colors.red,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            )
                                            : null,
                                  ),
                                  title: Text(
                                    donor.name.isEmpty
                                        ? 'Anonymous Donor'
                                        : donor.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Last donated: $timeSinceLastDonation',
                                  ),
                                  trailing: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          _canDonateAgain(
                                                donor.lastDonationDate,
                                              )
                                              ? Colors.green
                                              : Colors.orange,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      _canDonateAgain(donor.lastDonationDate)
                                          ? 'Available'
                                          : 'Unavailable',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                                const Divider(),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        donor.address.isEmpty &&
                                                donor.city.isEmpty
                                            ? 'Location not provided'
                                            : '${donor.city.isEmpty ? "" : donor.city}, ${donor.state.isEmpty ? "" : donor.state}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.bloodtype,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Blood Type: ${donor.bloodType}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Icon(
                                      Icons.volunteer_activism,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 4),
                                    Text('Donations: ${donor.donationCount}'),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: CustomButton(
                                        text: 'Call',
                                        onPressed:
                                            donor.phoneNumber.isEmpty
                                                ? () {}
                                                : () => _callDonor(
                                                  donor.phoneNumber,
                                                ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: CustomButton(
                                        text: 'Message',
                                        onPressed:
                                            donor.phoneNumber.isEmpty
                                                ? () {}
                                                : () => _messageDonor(
                                                  donor.phoneNumber,
                                                ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                });
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: () => Get.toNamed('/donor-registration'),
        child: const Icon(Icons.add),
        tooltip: 'Register as donor',
      ),
    );
  }

  String _getTimeSinceLastDonation(DateTime lastDonation) {
    final now = DateTime.now();
    final difference = now.difference(lastDonation);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else {
      return 'Today';
    }
  }

  bool _canDonateAgain(DateTime? lastDonation) {
    if (lastDonation == null) return true;

    // Donors should wait at least 56 days (8 weeks) between whole blood donations
    final now = DateTime.now();
    final difference = now.difference(lastDonation);
    return difference.inDays >= 56;
  }

  void _callDonor(String phoneNumber) {
    _bloodRequestController.callRequester(phoneNumber);
  }

  void _messageDonor(String phoneNumber) {
    _bloodRequestController.messageRequester(phoneNumber);
  }
}
