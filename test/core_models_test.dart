import 'package:flutter_test/flutter_test.dart';
import 'package:waste_management/core/models/app_user.dart';
import 'package:waste_management/core/models/user_role.dart';

void main() {
  group('AppUser Serialization — US-PKG-01 Acceptance Criteria', () {
    test('Given UserRole.hksWorker WHEN serialized to JSON THEN outputs hks_worker', () {
      final user = AppUser(
        id: '123',
        email: 'worker@loop.com',
        username: 'Worker Man',
        role: UserRole.hksWorker,
        phone: '1234567890',
        wardNumber: '15',
        address: '123 Loop St',
        isActive: true,
      );

      final json = user.toJson();
      expect(json['role'], equals('hks_worker'));
    });

    test('Given a Django API JSON response WHEN deserialized THEN all fields including location coords are parsed correctly', () {
      final json = <String, dynamic>{
        'id': '101',
        'email': 'res@loop.com',
        'username': 'Resident',
        'role': 'resident',
        'phone': '9876543210',
        'ward': '12',
        'address': 'Kozhikode, Kerala',
        'latitude': 11.2588,
        'longitude': 75.7804,
        'is_active': true,
      };

      final user = AppUser.fromJson(json);

      expect(user.id, equals('101'));
      expect(user.role, equals(UserRole.resident));
      expect(user.wardNumber, equals('12')); // JsonKey(name: 'ward')
      expect(user.latitude, closeTo(11.2588, 0.0001));
      expect(user.longitude, closeTo(75.7804, 0.0001));
      expect(user.isActive, isTrue);
    });

    test('Given hks_worker role string WHEN deserialized THEN maps to UserRole.hksWorker', () {
      final json = <String, dynamic>{
        'id': '42',
        'email': 'hks@loop.com',
        'username': 'HKS Worker',
        'role': 'hks_worker',
        'phone': '0000000000',
        'ward': '5',
        'address': 'Ward 5',
        'is_active': true,
      };

      final user = AppUser.fromJson(json);
      expect(user.role, equals(UserRole.hksWorker));
    });

    test('Given a full user object WHEN round-tripped through JSON THEN all values are preserved', () {
      final original = AppUser(
        id: '77',
        email: 'admin@loop.com',
        username: 'Admin',
        role: UserRole.admin,
        phone: '1111111111',
        wardNumber: '1',
        address: 'City Hall',
        latitude: 12.0,
        longitude: 76.0,
        isActive: true,
      );

      final json = original.toJson();
      final restored = AppUser.fromJson(json);

      expect(restored.id, equals(original.id));
      expect(restored.role, equals(original.role));
      expect(restored.latitude, equals(original.latitude));
      expect(restored.wardNumber, equals(original.wardNumber));
    });
  });
}
