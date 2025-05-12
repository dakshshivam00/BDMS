import 'package:bdms1/controllers/blood_request_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreateRequestPage extends StatefulWidget {
  const CreateRequestPage({Key? key}) : super(key: key);

  @override
  State<CreateRequestPage> createState() => _CreateRequestPageState();
}

class _CreateRequestPageState extends State<CreateRequestPage> {
  final _formKey = GlobalKey<FormState>();
  final _patientNameController = TextEditingController();
  final _hospitalController = TextEditingController();
  final _reasonController = TextEditingController();
  final _contactController = TextEditingController();

  String _selectedBloodType = 'A+';
  String _selectedUrgency = 'Normal';

  final List<String> _bloodTypes = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];
  final List<String> _urgencyLevels = ['Normal', 'Urgent'];

  // Add a new controller for city
  final TextEditingController _cityController = TextEditingController();

  // Add this to the dispose method
  @override
  void dispose() {
    _patientNameController.dispose();
    _hospitalController.dispose();
    _contactController.dispose(); // Fixed variable name
    _reasonController.dispose(); // Added missing controller
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Blood'),
        backgroundColor: Colors.red,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Patient Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _patientNameController,
                decoration: InputDecoration(
                  labelText: 'Patient Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter patient name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Blood Type Dropdown
              DropdownButtonFormField<String>(
                value: _selectedBloodType,
                decoration: InputDecoration(
                  labelText: 'Blood Type',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.bloodtype),
                ),
                items:
                    _bloodTypes.map((String type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedBloodType = newValue;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Hospital
              TextFormField(
                controller: _hospitalController,
                decoration: InputDecoration(
                  labelText: 'Hospital Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.local_hospital),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter hospital name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Reason
              TextFormField(
                controller: _reasonController,
                decoration: InputDecoration(
                  labelText: 'Reason for Request',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.description),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter reason for blood request';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Contact
              TextFormField(
                controller: _contactController,
                decoration: InputDecoration(
                  labelText: 'Contact Number',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter contact number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Urgency
              DropdownButtonFormField<String>(
                value: _selectedUrgency,
                decoration: InputDecoration(
                  labelText: 'Urgency Level',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.priority_high),
                ),
                items:
                    _urgencyLevels.map((String level) {
                      return DropdownMenuItem<String>(
                        value: level,
                        child: Text(level),
                      );
                    }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedUrgency = newValue;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // City
              TextFormField(
                controller: _cityController,
                decoration: InputDecoration(
                  labelText: 'City',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.location_city),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter city';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  // In the Submit Button's onPressed method, update to add the request to the controller
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Create a new blood request and add it to the controller
                      final bloodRequestController =
                          Get.find<BloodRequestController>();
                      bloodRequestController.addBloodRequest(
                        patientName: _patientNameController.text,
                        bloodType: _selectedBloodType,
                        hospital: _hospitalController.text,
                        reason: _reasonController.text,
                        contactNumber: _contactController.text,
                        urgency: _selectedUrgency,
                        city: _cityController.text,
                      );
                      Get.back();
                      Get.snackbar(
                        'Success',
                        'Blood request submitted successfully',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.green.withOpacity(0.1),
                        colorText: Colors.green,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Submit Request',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
