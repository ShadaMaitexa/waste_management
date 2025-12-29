import 'package:flutter/foundation.dart';

class User {
  final String id;
  final String email;
  final String name;
  final UserType userType;
  final String phoneNumber;
  final String address;
  final DateTime createdAt;
  final bool isActive;
  
  // Additional fields for specific user types
  final String? wardNumber; // For residents
  final String? employeeId; // For workers
  final String? department; // For admin
  final String? companyName; // For recyclers
  final String? licenseNumber; // For recyclers

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.userType,
    required this.phoneNumber,
    required this.address,
    required this.createdAt,
    this.isActive = true,
    this.wardNumber,
    this.employeeId,
    this.department,
    this.companyName,
    this.licenseNumber,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      userType: UserType.values.firstWhere(
        (e) => e.toString().split('.').last == json['userType'],
        orElse: () => UserType.resident,
      ),
      phoneNumber: json['phoneNumber'] ?? '',
      address: json['address'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      isActive: json['isActive'] ?? true,
      wardNumber: json['wardNumber'],
      employeeId: json['employeeId'],
      department: json['department'],
      companyName: json['companyName'],
      licenseNumber: json['licenseNumber'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'userType': userType.toString().split('.').last,
      'phoneNumber': phoneNumber,
      'address': address,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
      'wardNumber': wardNumber,
      'employeeId': employeeId,
      'department': department,
      'companyName': companyName,
      'licenseNumber': licenseNumber,
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? name,
    UserType? userType,
    String? phoneNumber,
    String? address,
    DateTime? createdAt,
    bool? isActive,
    String? wardNumber,
    String? employeeId,
    String? department,
    String? companyName,
    String? licenseNumber,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      userType: userType ?? this.userType,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      wardNumber: wardNumber ?? this.wardNumber,
      employeeId: employeeId ?? this.employeeId,
      department: department ?? this.department,
      companyName: companyName ?? this.companyName,
      licenseNumber: licenseNumber ?? this.licenseNumber,
    );
  }
}

enum UserType { resident, worker, admin, recycler }
