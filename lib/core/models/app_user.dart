import 'package:freezed_annotation/freezed_annotation.dart';
import 'user_role.dart';

part 'app_user.freezed.dart';
part 'app_user.g.dart';

@freezed
class AppUser with _$AppUser {
  const factory AppUser({
    required String id,
    required String email,
    required String username,
    required UserRole role,
    required String phone,
    @JsonKey(name: 'ward') required String wardNumber,
    required String address,
    double? latitude,
    double? longitude,
    @JsonKey(name: 'is_active', defaultValue: true) required bool isActive,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _AppUser;

  factory AppUser.fromJson(Map<String, dynamic> json) => _$AppUserFromJson(json);
}
