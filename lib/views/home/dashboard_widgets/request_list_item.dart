import 'package:flutter/material.dart';

class RequestListItem extends StatelessWidget {
  final String bloodType;
  final String hospital;
  final bool isUrgent;
  final VoidCallback onTap;
  final String contactNumber;
  final String city;

  const RequestListItem({
    Key? key,
    required this.bloodType,
    required this.hospital,
    required this.isUrgent,
    required this.onTap,
    this.contactNumber = '',
    this.city = '',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.red.shade100,
              child: Icon(
                Icons.bloodtype,
                color: Colors.red,
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bloodType,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  hospital,
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isUrgent ? Colors.red.shade100 : Colors.green.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isUrgent ? 'Urgent' : 'Normal',
                style: TextStyle(
                  color: isUrgent ? Colors.red : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}