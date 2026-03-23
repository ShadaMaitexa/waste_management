/// Matches the backend API response for /api/auth/profile/ and /api/auth/login/
/// API fields: id, username, email, phone, ward, role, latitude, longitude

class User {
  final String id;
  final String email;
  final String username; // The display name (may equal email if not set)
  final UserType userType;
  final String phone;
  final String ward;
  final String address;  // Registered address
  final String? latitude;
  final String? longitude;
  final bool isActive;

  User({
    required this.id,
    required this.email,
    required this.username,
    required this.userType,
    required this.phone,
    required this.ward,
    required this.address,
    this.latitude,
    this.longitude,
    this.isActive = true,
  });

  /// Display name: prefer username if it doesn't look like an email/token
  String get name {
    if (username.isEmpty) return email.split('@').first;
    // If username is email or a random token (contains @), use email prefix
    if (username.contains('@')) return email.split('@').first;
    return username;
  }

  /// Convenience getters for compatibility
  String get phoneNumber => phone;
  String get wardNumber => ward;

  factory User.fromJson(Map<String, dynamic> json) {
    String userTypeStr = (json['role'] ?? 'resident').toString().toLowerCase();
    
    // Robust mapping for worker variations
    if (userTypeStr == 'hks' || userTypeStr == 'staff' || userTypeStr == 'hks_worker') {
      userTypeStr = 'worker';
    }

    return User(
      id: (json['id'] ?? '').toString(),
      email: json['email'] ?? '',
      username: json['username'] ?? json['email'] ?? '',
      userType: UserType.values.firstWhere(
        (e) => e.name == userTypeStr,
        orElse: () => UserType.resident,
      ),
      phone: json['phone']?.toString() ?? '',
      ward: json['ward']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      latitude: json['latitude']?.toString(),
      longitude: json['longitude']?.toString(),
      isActive: json['is_active'] ?? json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'role': userType.name,
      'phone': phone,
      'ward': ward,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'is_active': isActive,
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? username,
    UserType? userType,
    String? phone,
    String? ward,
    String? address,
    String? latitude,
    String? longitude,
    bool? isActive,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      userType: userType ?? this.userType,
      phone: phone ?? this.phone,
      ward: ward ?? this.ward,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isActive: isActive ?? this.isActive,
    );
  }
}

enum UserType { resident, worker, driver, admin, recycler }
