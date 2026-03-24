// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pickup_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PickupModel _$PickupModelFromJson(Map<String, dynamic> json) => _PickupModel(
  id: json['id'] as String,
  resident: AppUser.fromJson(json['resident'] as Map<String, dynamic>),
  wasteType: json['waste_type'] as String,
  scheduledDate: DateTime.parse(json['scheduled_date'] as String),
  status: json['status'] as String,
  wardNumber: json['ward'] as String,
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
);

Map<String, dynamic> _$PickupModelToJson(_PickupModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'resident': instance.resident,
      'waste_type': instance.wasteType,
      'scheduled_date': instance.scheduledDate.toIso8601String(),
      'status': instance.status,
      'ward': instance.wardNumber,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };
