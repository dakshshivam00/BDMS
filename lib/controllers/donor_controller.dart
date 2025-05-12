import 'package:get/get.dart';
import '../models/donor_model.dart';
import '../services/firestore_service.dart';

class DonorController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();
  final RxList<DonorModel> availableDonors = <DonorModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString selectedBloodGroup = ''.obs;
  final RxString selectedCity = ''.obs;

  @override
  void onInit() {
    fetchAvailableDonors();
    super.onInit();
  }

  Future<void> fetchAvailableDonors() async {
    try {
      isLoading.value = true;
      // Implement fetching logic from Firestore
      // Update availableDonors list
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> registerAsDonor(DonorModel donor) async {
    try {
      isLoading.value = true;
      // Implement donor registration logic
      availableDonors.add(donor);
    } finally {
      isLoading.value = false;
    }
  }

  void filterDonors({String? bloodGroup, String? city}) {
    selectedBloodGroup.value = bloodGroup ?? selectedBloodGroup.value;
    selectedCity.value = city ?? selectedCity.value;
    // Implement filtering logic
  }

  Future<void> updateDonorStatus(String donorId, bool isAvailable) async {
    try {
      isLoading.value = true;
      // Implement status update logic
    } finally {
      isLoading.value = false;
    }
  }
}
