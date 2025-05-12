import 'package:flutter/material.dart';
import '../../widgets/custom_button.dart';

class DonorsPage extends StatelessWidget {
  const DonorsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Sample donor data
    final List<Map<String, dynamic>> donors = [
      {
        'name': 'John Doe',
        'bloodGroup': 'O+',
        'lastDonation': '3 months ago',
        'location': 'New Delhi',
        'phone': '+91 9876543210',
        'donations': 5,
      },
      {
        'name': 'Jane Smith',
        'bloodGroup': 'A+',
        'lastDonation': '6 months ago',
        'location': 'Mumbai',
        'phone': '+91 9876543211',
        'donations': 3,
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Donors List'), elevation: 0),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: donors.length,
        itemBuilder: (context, index) {
          final donor = donors[index];
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
                        donor['name'],
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
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          donor['bloodGroup'],
                          style: TextStyle(
                            color: Colors.red[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        donor['location'],
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.phone, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        donor['phone'],
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Last donation: ${donor['lastDonation']}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.favorite, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        'Total donations: ${donor['donations']}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: 'Contact',
                          onPressed: () {
                            // TODO: Implement contact functionality
                          },
                          backgroundColor: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: CustomButton(
                          text: 'View Details',
                          onPressed: () {
                            // TODO: Implement view details functionality
                          },
                          backgroundColor: Colors.green,
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
  }
}
