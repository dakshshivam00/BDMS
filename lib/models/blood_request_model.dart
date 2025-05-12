class BloodRequestModel {
  final String id;
  final String userId;
  final String patientName;
  final String bloodGroup;
  final int units;
  final String hospital;
  final String contactNumber;
  final String alternateContactNumber;
  final String city;
  final String status;
  final DateTime createdAt;
  final String? donorId;

  BloodRequestModel({
    required this.id,
    required this.userId,
    required this.patientName,
    required this.bloodGroup,
    required this.units,
    required this.hospital,
    required this.contactNumber,
    required this.alternateContactNumber,
    required this.city,
    this.status = 'active',
    required this.createdAt,
    this.donorId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'patientName': patientName,
      'bloodGroup': bloodGroup,
      'units': units,
      'hospital': hospital,
      'contactNumber': contactNumber,
      'alternateContactNumber': alternateContactNumber,
      'city': city,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'donorId': donorId,
    };
  }

  factory BloodRequestModel.fromJson(Map<String, dynamic> json) {
    return BloodRequestModel(
      id: json['id'],
      userId: json['userId'],
      patientName: json['patientName'],
      bloodGroup: json['bloodGroup'],
      units: json['units'],
      hospital: json['hospital'],
      contactNumber: json['contactNumber'],
      alternateContactNumber: json['alternateContactNumber'],
      city: json['city'],
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
      donorId: json['donorId'],
    );
  }
}
