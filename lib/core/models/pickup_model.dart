import 'package:freezed_annotation/freezed_annotation.dart';
import 'app_user.dart';

part 'pickup_model.freezed.dart';
part 'pickup_model.g.dart';

@freezed
class PickupModel with _$PickupModel {
  const factory PickupModel({
    required String id,
    @JsonKey(name: 'resident') required AppUser resident,
    @JsonKey(name: 'waste_type') required String wasteType,
    @JsonKey(name: 'scheduled_date') required DateTime scheduledDate,
    required String status,
    @JsonKey(name: 'ward') required String wardNumber,
    required double latitude,
    required double longitude,
  }) = _PickupModel;

  factory PickupModel.fromJson(Map<String, dynamic> json) => _$PickupModelFromJson(json);
}
