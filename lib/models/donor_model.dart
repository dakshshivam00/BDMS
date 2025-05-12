class DonorModel {
  final String id;
  final String userId;
  final String name;
  final String bloodGroup;
  final int age;
  final String contactNumber;
  final String alternateContactNumber;
  final String address;
  final String city;
  final String state;
  final bool isAvailable;
  final DateTime? lastDonation;

  DonorModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.bloodGroup,
    required this.age,
    required this.contactNumber,
    required this.alternateContactNumber,
    required this.address,
    required this.city,
    required this.state,
    this.isAvailable = true,
    this.lastDonation,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'bloodGroup': bloodGroup,
      'age': age,
      'contactNumber': contactNumber,
      'alternateContactNumber': alternateContactNumber,
      'address': address,
      'city': city,
      'state': state,
      'isAvailable': isAvailable,
      'lastDonation': lastDonation?.toIso8601String(),
    };
  }

  factory DonorModel.fromJson(Map<String, dynamic> json) {
    return DonorModel(
      id: json['id'],
      userId: json['userId'],
      name: json['name'],
      bloodGroup: json['bloodGroup'],
      age: json['age'],
      contactNumber: json['contactNumber'],
      alternateContactNumber: json['alternateContactNumber'],
      address: json['address'],
      city: json['city'],
      state: json['state'],
      isAvailable: json['isAvailable'] ?? true,
      lastDonation:
          json['lastDonation'] != null
              ? DateTime.parse(json['lastDonation'])
              : null,
    );
  }
}
