import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final String bloodType;
  final bool isDonor;
  final int donationCount;
  final String address;
  final String city;
  final String state;
  final String? profileImageUrl;
  final DateTime? lastDonationDate;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.bloodType,
    required this.isDonor,
    required this.donationCount,
    required this.address,
    required this.city,
    required this.state,
    this.profileImageUrl,
    this.lastDonationDate,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      bloodType: map['bloodType'] ?? '',
      isDonor: map['isDonor'] ?? false,
      donationCount: map['donationCount'] ?? 0,
      address: map['address'] ?? '',
      city: map['city'] ?? '',
      state: map['state'] ?? '',
      profileImageUrl: map['profileImageUrl'],
      lastDonationDate:
          map['lastDonationDate'] != null
              ? (map['lastDonationDate'] as Timestamp).toDate()
              : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'bloodType': bloodType,
      'isDonor': isDonor,
      'donationCount': donationCount,
      'address': address,
      'city': city,
      'state': state,
      'profileImageUrl': profileImageUrl,
      'lastDonationDate':
          lastDonationDate != null
              ? Timestamp.fromDate(lastDonationDate!)
              : null,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
    String? bloodType,
    bool? isDonor,
    int? donationCount,
    String? address,
    String? city,
    String? state,
    String? profileImageUrl,
    DateTime? lastDonationDate,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      bloodType: bloodType ?? this.bloodType,
      isDonor: isDonor ?? this.isDonor,
      donationCount: donationCount ?? this.donationCount,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      lastDonationDate: lastDonationDate ?? this.lastDonationDate,
    );
  }
}
