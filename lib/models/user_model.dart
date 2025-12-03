import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { citizen, admin, rescueWorker }

class UserModel {
  final String id;
  final String email;
  final String name;
  final String? phoneNumber;
  final UserRole role;
  final DateTime createdAt;
  final bool isVerified;
  final String? profileImageUrl;
  final String? address;
  final DateTime? lastLoginAt;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.phoneNumber,
    required this.role,
    required this.createdAt,
    required this.isVerified,
    this.profileImageUrl,
    this.address,
    this.lastLoginAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      phoneNumber: data['phoneNumber'],
      role: UserRole.values[data['role'] ?? 0],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isVerified: data['isVerified'] ?? false,
      profileImageUrl: data['profileImageUrl'],
      address: data['address'],
      lastLoginAt: data['lastLoginAt'] != null ? (data['lastLoginAt'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'phoneNumber': phoneNumber,
      'role': role.index,
      'createdAt': Timestamp.fromDate(createdAt),
      'isVerified': isVerified,
      'profileImageUrl': profileImageUrl,
      'address': address,
      'lastLoginAt': lastLoginAt != null ? Timestamp.fromDate(lastLoginAt!) : null,
    };
  }

  UserModel copyWith({
    String? name,
    String? phoneNumber,
    String? profileImageUrl,
    String? address,
    bool? isVerified,
    DateTime? lastLoginAt,
  }) {
    return UserModel(
      id: id,
      email: email,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role,
      createdAt: createdAt,
      isVerified: isVerified ?? this.isVerified,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      address: address ?? this.address,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
}
