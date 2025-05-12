import 'package:flutter/material.dart';
import '../../widgets/custom_button.dart';

class AvailableDonorsPage extends StatelessWidget {
  const AvailableDonorsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Donors'),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search by location...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    // Show filter options
                  },
                  icon: const Icon(Icons.filter_list),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 10,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.red[100],
                            child: const Text(
                              'A+',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: const Text(
                            'John Doe',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: const Text('Last donated: 3 months ago'),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Available',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        const Divider(),
                        Row(
                          children: const [
                            Icon(Icons.location_on, size: 16, color: Colors.grey),
                            SizedBox(width: 4),
                            Text('5 km away'),
                            Spacer(),
                            Text('New York City'),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: CustomButton(
                                text: 'Call',
                                onPressed: () {
                                  // Handle call action
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: CustomButton(
                                text: 'Message',
                                onPressed: () {
                                  // Handle message action
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
            ),
          ),
        ],
      ),
    );
  }
}