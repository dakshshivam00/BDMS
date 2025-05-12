import 'package:get/get.dart';
import '../models/blood_request_model.dart';
import '../services/firestore_service.dart';

class RequestController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();
  final RxList<BloodRequestModel> activeRequests = <BloodRequestModel>[].obs;
  final RxList<BloodRequestModel> pendingRequests = <BloodRequestModel>[].obs;
  final RxList<BloodRequestModel> fulfilledRequests = <BloodRequestModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    fetchRequests();
    super.onInit();
  }

  Future<void> fetchRequests() async {
    try {
      isLoading.value = true;
      // Implement fetching logic from Firestore
      // Update the respective lists
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createRequest(BloodRequestModel request) async {
    try {
      isLoading.value = true;
      // Implement create request logic
      activeRequests.add(request);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateRequestStatus(String requestId, String status) async {
    try {
      isLoading.value = true;
      // Implement status update logic
      // Move request between lists based on status
    } finally {
      isLoading.value = false;
    }
  }
}