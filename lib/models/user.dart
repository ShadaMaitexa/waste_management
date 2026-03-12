
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
    // Support snake_case (Django REST), camelCase, and 'role' field naming
    // API may return: role, user_type, or userType
    final userTypeStr = json['role'] ?? json['user_type'] ?? json['userType'] ?? 'resident';
    final phoneNumber = json['phone_number'] ?? json['phoneNumber'] ?? '';
    final address = json['address'] ?? '';
    final createdAtRaw = json['created_at'] ?? json['createdAt'];
    final isActive = json['is_active'] ?? json['isActive'] ?? true;
    final wardNumber = json['ward_number'] ?? json['wardNumber'];
    final employeeId = json['employee_id'] ?? json['employeeId'];
    final department = json['department'];
    final companyName = json['company_name'] ?? json['companyName'];
    final licenseNumber = json['license_number'] ?? json['licenseNumber'];

    return User(
      id: (json['id'] ?? '').toString(),
      email: json['email'] ?? '',
      name: json['name'] ?? json['username'] ?? '',
      userType: UserType.values.firstWhere(
        (e) => e.toString().split('.').last.toLowerCase() == userTypeStr.toString().toLowerCase(),
        orElse: () => UserType.resident,
      ),
      phoneNumber: phoneNumber,
      address: address,
      createdAt: createdAtRaw != null ? DateTime.tryParse(createdAtRaw.toString()) ?? DateTime.now() : DateTime.now(),
      isActive: isActive is bool ? isActive : (isActive.toString() == 'true'),
      wardNumber: wardNumber?.toString(),
      employeeId: employeeId?.toString(),
      department: department?.toString(),
      companyName: companyName?.toString(),
      licenseNumber: licenseNumber?.toString(),
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
