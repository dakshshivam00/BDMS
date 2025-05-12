import 'package:flutter/material.dart';

class RequestListItem extends StatelessWidget {
  final String bloodType;
  final String hospital;
  final bool isUrgent;
  final String contactNumber;
  final String city;
  final VoidCallback onTap;

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
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    bloodType,
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hospital,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (city.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        city,
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                    if (contactNumber.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.phone, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            contactNumber,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (isUrgent)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Urgent',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
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
