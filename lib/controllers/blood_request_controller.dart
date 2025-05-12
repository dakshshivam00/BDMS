import 'package:get/get.dart';
import '../models/blood_request.dart';
import 'package:url_launcher/url_launcher.dart';

class BloodRequestController extends GetxController {
  final bloodRequests = <BloodRequest>[].obs;
  final totalDonors = 0.obs;
  final donationsToday = <BloodRequest>[].obs;
  final isLoading = false.obs;
  final currentFilter = 'all'.obs;

  @override
  void onInit() {
    super.onInit();
    // Load mock data for testing
    loadMockData();
  }

  void loadMockData() {
    // Add some mock blood requests
    bloodRequests.add(
      BloodRequest(
        id: '1',
        patientName: 'John Doe',
        bloodType: 'A+',
        hospital: 'City Hospital',
        reason: 'Surgery',
        contactNumber: '1234567890',
        urgency: 'Urgent',
        status: 'Pending',
        requestDate: DateTime.now().subtract(const Duration(days: 1)),
        city: 'New York',
      ),
    );

    bloodRequests.add(
      BloodRequest(
        id: '2',
        patientName: 'Jane Smith',
        bloodType: 'O-',
        hospital: 'General Hospital',
        reason: 'Accident',
        contactNumber: '0987654321',
        urgency: 'Normal',
        status: 'Pending',
        requestDate: DateTime.now().subtract(const Duration(hours: 5)),
        city: 'Chicago',
      ),
    );

    // Set total donors
    totalDonors.value = 2;
  }

  // Fetch blood requests (simulated)
  void fetchBloodRequests() {
    isLoading.value = true;
    // Simulate network delay
    Future.delayed(const Duration(seconds: 1), () {
      // Data is already loaded in loadMockData
      isLoading.value = false;
    });
  }

  // Set filter for blood requests
  void setFilter(String filter) {
    currentFilter.value = filter;
    update();
  }

  // Get filtered blood requests
  List<BloodRequest> get filteredRequests {
    if (currentFilter.value == 'all') {
      return bloodRequests;
    } else if (currentFilter.value == 'urgent') {
      return bloodRequests
          .where((req) => req.urgency.toLowerCase() == 'urgent')
          .toList();
    } else if (currentFilter.value == 'normal') {
      return bloodRequests
          .where((req) => req.urgency.toLowerCase() == 'normal')
          .toList();
    }
    return bloodRequests;
  }

  // Get recent requests (last 5)
  List<BloodRequest> get recentRequests {
    final sorted =
        bloodRequests.toList()
          ..sort((a, b) => b.requestDate.compareTo(a.requestDate));
    return sorted.take(5).toList();
  }

  // Add a new blood request
  void addBloodRequest({
    required String patientName,
    required String bloodType,
    required String hospital,
    required String reason,
    required String contactNumber,
    required String urgency,
    required String city,
  }) {
    final newRequest = BloodRequest(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      patientName: patientName,
      bloodType: bloodType,
      hospital: hospital,
      reason: reason,
      contactNumber: contactNumber,
      urgency: urgency,
      status: 'Pending',
      requestDate: DateTime.now(),
      city: city,
    );

    bloodRequests.add(newRequest);
    update();
  }

  // Update request status
  void updateRequestStatus(String requestId, String newStatus) {
    final index = bloodRequests.indexWhere((req) => req.id == requestId);
    if (index != -1) {
      final request = bloodRequests[index];
      final updatedRequest = BloodRequest(
        id: request.id,
        patientName: request.patientName,
        bloodType: request.bloodType,
        hospital: request.hospital,
        reason: request.reason,
        contactNumber: request.contactNumber,
        urgency: request.urgency,
        status: newStatus,
        requestDate: request.requestDate,
        completedAt: newStatus == 'Fulfilled' ? DateTime.now() : null,
        city: request.city,
      );

      bloodRequests[index] = updatedRequest;

      // Add to today's donations if completed today
      if (newStatus == 'Fulfilled') {
        donationsToday.add(updatedRequest);
      }

      update();
    }
  }

  // Call requester
  void callRequester(String phoneNumber) async {
    final Uri url = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      Get.snackbar(
        'Error',
        'Could not launch phone call',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Message requester
  void messageRequester(String phoneNumber) async {
    final Uri url = Uri.parse('sms:$phoneNumber');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      Get.snackbar(
        'Error',
        'Could not launch messaging app',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Get count of donations completed today
  int get todayDonationsCount {
    final now = DateTime.now();
    return bloodRequests
        .where(
          (req) =>
              req.status == 'Fulfilled' &&
              req.completedAt != null &&
              req.completedAt!.day == now.day &&
              req.completedAt!.month == now.month &&
              req.completedAt!.year == now.year,
        )
        .length;
  }
}
