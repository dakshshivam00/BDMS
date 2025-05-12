import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../widgets/custom_button.dart';

class ViewRequestsPage extends StatelessWidget {
  const ViewRequestsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Blood Requests'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Active'),
              Tab(text: 'Pending'),
              Tab(text: 'Fulfilled'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildRequestsList('active'),
            _buildRequestsList('pending'),
            _buildRequestsList('fulfilled'),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestsList(String status) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'A+ Blood Needed',
                      style: TextStyle(
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
                        color: _getStatusColor(status),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildInfoRow(Icons.person, 'Patient: John Doe'),
                _buildInfoRow(Icons.local_hospital, 'City Hospital'),
                _buildInfoRow(Icons.location_on, 'New York City'),
                _buildInfoRow(Icons.access_time, '2 hours ago'),
                const SizedBox(height: 16),
                if (status == 'active')
                  CustomButton(
                    text: 'I Want to Donate',
                    onPressed: () {
                      // Handle donation offer
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'fulfilled':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}