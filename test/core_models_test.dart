import 'package:flutter_test/flutter_test.dart';
import 'package:waste_management/core/models/app_user.dart';
import 'package:waste_management/core/models/user_role.dart';

void main() {
  group('AppUser Serialization Tests', () {
    test('UserRole.hksWorker serializes to hks_worker', () {
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
      expect(json['role'], 'hks_worker'); // Matches TextChoices
    });

    test('Parses Django API JSON response successfully', () {
      final json = {
        'id': '101',
        'email': 'res@loop.com',
        'username': 'Resident',
        'role': 'resident',
        'phone': '9876543210',
        'ward': '12',
        'address': 'Kozhikode',
        'latitude': 11.2588,
        'longitude': 75.7804,
        'is_active': true,
      };

      final user = AppUser.fromJson(json);
      
      expect(user.id, '101');
      expect(user.role, UserRole.resident);
      expect(user.latitude, 11.2588);
      expect(user.longitude, 75.7804);
    });
  });
}
