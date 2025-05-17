class BloodRequest {
  final String id;
  final String patientName;
  final String bloodType;
  final String hospital;
  final String reason;
  final String contactNumber;
  final String urgency;
  final String status;
  final DateTime requestDate;
  final DateTime? completedAt;
  final String city;
  final String createdBy;

  BloodRequest({
    required this.id,
    required this.patientName,
    required this.bloodType,
    required this.hospital,
    required this.reason,
    required this.contactNumber,
    required this.urgency,
    required this.status,
    required this.requestDate,
    this.completedAt,
    required this.city,
    this.createdBy = '',
  });
}
