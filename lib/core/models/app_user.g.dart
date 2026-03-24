// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppUser _$AppUserFromJson(Map<String, dynamic> json) => _AppUser(
  id: json['id'] as String,
  email: json['email'] as String,
  username: json['username'] as String,
  role: $enumDecode(_$UserRoleEnumMap, json['role']),
  phone: json['phone'] as String,
  wardNumber: json['ward'] as String,
  address: json['address'] as String,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  isActive: json['is_active'] as bool? ?? true,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$AppUserToJson(_AppUser instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'username': instance.username,
  'role': _$UserRoleEnumMap[instance.role]!,
  'phone': instance.phone,
  'ward': instance.wardNumber,
  'address': instance.address,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'is_active': instance.isActive,
  'created_at': instance.createdAt?.toIso8601String(),
};

const _$UserRoleEnumMap = {
  UserRole.resident: 'resident',
  UserRole.hksWorker: 'hks_worker',
  UserRole.driver: 'driver',
  UserRole.admin: 'admin',
  UserRole.recycler: 'recycler',
};
