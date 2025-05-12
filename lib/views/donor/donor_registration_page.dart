import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/user_controller.dart';

class DonorRegistrationPage extends StatefulWidget {
  const DonorRegistrationPage({Key? key}) : super(key: key);

  @override
  State<DonorRegistrationPage> createState() => _DonorRegistrationPageState();
}

class _DonorRegistrationPageState extends State<DonorRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  String _selectedBloodType = 'A+';
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
  final TextEditingController _lastDonationController = TextEditingController();
  bool _hasHealthConditions = false;
  DateTime? _lastDonationDate;

  final userController = Get.find<UserController>();

  @override
  void dispose() {
    _lastDonationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register as Donor'),
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
                'Donor Registration',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Blood Group
              const Text(
                'Blood Group',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedBloodType,
                decoration: InputDecoration(
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

              // Last Donation Date
              TextFormField(
                controller: _lastDonationController,
                decoration: InputDecoration(
                  labelText: 'Last Donation Date (DD/MM/YYYY)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() {
                      _lastDonationDate = picked;
                      _lastDonationController.text =
                          '${picked.day}/${picked.month}/${picked.year}';
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Health Conditions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Do you have any health conditions?',
                    style: TextStyle(fontSize: 16),
                  ),
                  Switch(
                    value: _hasHealthConditions,
                    onChanged: (value) {
                      setState(() {
                        _hasHealthConditions = value;
                      });
                    },
                    activeColor: Colors.red,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Register Button
              SizedBox(
                width: double.infinity,
                child: Obx(
                  () => ElevatedButton(
                    onPressed:
                        userController.isLoading.value
                            ? null
                            : () async {
                              if (_formKey.currentState!.validate()) {
                                if (_hasHealthConditions) {
                                  Get.snackbar(
                                    'Registration Failed',
                                    'You cannot register as a donor if you have health conditions',
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: Colors.red.withOpacity(
                                      0.1,
                                    ),
                                    colorText: Colors.red,
                                  );
                                  return;
                                }

                                final success = await userController
                                    .registerAsDonor(
                                      bloodType: _selectedBloodType,
                                      lastDonationDate: _lastDonationDate,
                                    );
                                Get.back();
                                if (success) {
                                  Get.snackbar(
                                    'Success',
                                    'Registered as donor successfully',
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: Colors.green.withOpacity(
                                      0.1,
                                    ),
                                    colorText: Colors.green,
                                  );
                                }
                              }
                            },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child:
                        userController.isLoading.value
                            ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                            : const Text(
                              'Register as Donor',
                              style: TextStyle(fontSize: 16),
                            ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Donor Guidelines
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Donor Guidelines',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('• Must be at least 18 years old'),
                    Text('• Must wait at least 56 days between donations'),
                    Text('• Must be in good health at the time of donation'),
                    Text('• Must not have any blood-borne diseases'),
                    Text('• Must not be pregnant or breastfeeding'),
                    Text('• Must not have taken certain medications recently'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      // Add this at the end of the Scaffold, before the closing parenthesis
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
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
            Get.offAllNamed('/blood-requests');
          } else if (index == 2) {
            // Already on donor page
          } else if (index == 3) {
            Get.offAllNamed('/profile');
          }
        },
      ),
    );
  }
}
