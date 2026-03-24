// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pickup_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PickupModel {

 String get id;@JsonKey(name: 'resident') AppUser get resident;@JsonKey(name: 'waste_type') String get wasteType;@JsonKey(name: 'scheduled_date') DateTime get scheduledDate; String get status;@JsonKey(name: 'ward') String get wardNumber; double get latitude; double get longitude;
/// Create a copy of PickupModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PickupModelCopyWith<PickupModel> get copyWith => _$PickupModelCopyWithImpl<PickupModel>(this as PickupModel, _$identity);

  /// Serializes this PickupModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PickupModel&&(identical(other.id, id) || other.id == id)&&(identical(other.resident, resident) || other.resident == resident)&&(identical(other.wasteType, wasteType) || other.wasteType == wasteType)&&(identical(other.scheduledDate, scheduledDate) || other.scheduledDate == scheduledDate)&&(identical(other.status, status) || other.status == status)&&(identical(other.wardNumber, wardNumber) || other.wardNumber == wardNumber)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,resident,wasteType,scheduledDate,status,wardNumber,latitude,longitude);

@override
String toString() {
  return 'PickupModel(id: $id, resident: $resident, wasteType: $wasteType, scheduledDate: $scheduledDate, status: $status, wardNumber: $wardNumber, latitude: $latitude, longitude: $longitude)';
}


}

/// @nodoc
abstract mixin class $PickupModelCopyWith<$Res>  {
  factory $PickupModelCopyWith(PickupModel value, $Res Function(PickupModel) _then) = _$PickupModelCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'resident') AppUser resident,@JsonKey(name: 'waste_type') String wasteType,@JsonKey(name: 'scheduled_date') DateTime scheduledDate, String status,@JsonKey(name: 'ward') String wardNumber, double latitude, double longitude
});


$AppUserCopyWith<$Res> get resident;

}
/// @nodoc
class _$PickupModelCopyWithImpl<$Res>
    implements $PickupModelCopyWith<$Res> {
  _$PickupModelCopyWithImpl(this._self, this._then);

  final PickupModel _self;
  final $Res Function(PickupModel) _then;

/// Create a copy of PickupModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? resident = null,Object? wasteType = null,Object? scheduledDate = null,Object? status = null,Object? wardNumber = null,Object? latitude = null,Object? longitude = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,resident: null == resident ? _self.resident : resident // ignore: cast_nullable_to_non_nullable
as AppUser,wasteType: null == wasteType ? _self.wasteType : wasteType // ignore: cast_nullable_to_non_nullable
as String,scheduledDate: null == scheduledDate ? _self.scheduledDate : scheduledDate // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,wardNumber: null == wardNumber ? _self.wardNumber : wardNumber // ignore: cast_nullable_to_non_nullable
as String,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,
  ));
}
/// Create a copy of PickupModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AppUserCopyWith<$Res> get resident {
  
  return $AppUserCopyWith<$Res>(_self.resident, (value) {
    return _then(_self.copyWith(resident: value));
  });
}
}


/// Adds pattern-matching-related methods to [PickupModel].
extension PickupModelPatterns on PickupModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PickupModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PickupModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PickupModel value)  $default,){
final _that = this;
switch (_that) {
case _PickupModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PickupModel value)?  $default,){
final _that = this;
switch (_that) {
case _PickupModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'resident')  AppUser resident, @JsonKey(name: 'waste_type')  String wasteType, @JsonKey(name: 'scheduled_date')  DateTime scheduledDate,  String status, @JsonKey(name: 'ward')  String wardNumber,  double latitude,  double longitude)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PickupModel() when $default != null:
return $default(_that.id,_that.resident,_that.wasteType,_that.scheduledDate,_that.status,_that.wardNumber,_that.latitude,_that.longitude);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'resident')  AppUser resident, @JsonKey(name: 'waste_type')  String wasteType, @JsonKey(name: 'scheduled_date')  DateTime scheduledDate,  String status, @JsonKey(name: 'ward')  String wardNumber,  double latitude,  double longitude)  $default,) {final _that = this;
switch (_that) {
case _PickupModel():
return $default(_that.id,_that.resident,_that.wasteType,_that.scheduledDate,_that.status,_that.wardNumber,_that.latitude,_that.longitude);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'resident')  AppUser resident, @JsonKey(name: 'waste_type')  String wasteType, @JsonKey(name: 'scheduled_date')  DateTime scheduledDate,  String status, @JsonKey(name: 'ward')  String wardNumber,  double latitude,  double longitude)?  $default,) {final _that = this;
switch (_that) {
case _PickupModel() when $default != null:
return $default(_that.id,_that.resident,_that.wasteType,_that.scheduledDate,_that.status,_that.wardNumber,_that.latitude,_that.longitude);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PickupModel implements PickupModel {
  const _PickupModel({required this.id, @JsonKey(name: 'resident') required this.resident, @JsonKey(name: 'waste_type') required this.wasteType, @JsonKey(name: 'scheduled_date') required this.scheduledDate, required this.status, @JsonKey(name: 'ward') required this.wardNumber, required this.latitude, required this.longitude});
  factory _PickupModel.fromJson(Map<String, dynamic> json) => _$PickupModelFromJson(json);

@override final  String id;
@override@JsonKey(name: 'resident') final  AppUser resident;
@override@JsonKey(name: 'waste_type') final  String wasteType;
@override@JsonKey(name: 'scheduled_date') final  DateTime scheduledDate;
@override final  String status;
@override@JsonKey(name: 'ward') final  String wardNumber;
@override final  double latitude;
@override final  double longitude;

/// Create a copy of PickupModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PickupModelCopyWith<_PickupModel> get copyWith => __$PickupModelCopyWithImpl<_PickupModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PickupModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PickupModel&&(identical(other.id, id) || other.id == id)&&(identical(other.resident, resident) || other.resident == resident)&&(identical(other.wasteType, wasteType) || other.wasteType == wasteType)&&(identical(other.scheduledDate, scheduledDate) || other.scheduledDate == scheduledDate)&&(identical(other.status, status) || other.status == status)&&(identical(other.wardNumber, wardNumber) || other.wardNumber == wardNumber)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,resident,wasteType,scheduledDate,status,wardNumber,latitude,longitude);

@override
String toString() {
  return 'PickupModel(id: $id, resident: $resident, wasteType: $wasteType, scheduledDate: $scheduledDate, status: $status, wardNumber: $wardNumber, latitude: $latitude, longitude: $longitude)';
}


}

/// @nodoc
abstract mixin class _$PickupModelCopyWith<$Res> implements $PickupModelCopyWith<$Res> {
  factory _$PickupModelCopyWith(_PickupModel value, $Res Function(_PickupModel) _then) = __$PickupModelCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'resident') AppUser resident,@JsonKey(name: 'waste_type') String wasteType,@JsonKey(name: 'scheduled_date') DateTime scheduledDate, String status,@JsonKey(name: 'ward') String wardNumber, double latitude, double longitude
});


@override $AppUserCopyWith<$Res> get resident;

}
/// @nodoc
class __$PickupModelCopyWithImpl<$Res>
    implements _$PickupModelCopyWith<$Res> {
  __$PickupModelCopyWithImpl(this._self, this._then);

  final _PickupModel _self;
  final $Res Function(_PickupModel) _then;

/// Create a copy of PickupModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? resident = null,Object? wasteType = null,Object? scheduledDate = null,Object? status = null,Object? wardNumber = null,Object? latitude = null,Object? longitude = null,}) {
  return _then(_PickupModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,resident: null == resident ? _self.resident : resident // ignore: cast_nullable_to_non_nullable
as AppUser,wasteType: null == wasteType ? _self.wasteType : wasteType // ignore: cast_nullable_to_non_nullable
as String,scheduledDate: null == scheduledDate ? _self.scheduledDate : scheduledDate // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,wardNumber: null == wardNumber ? _self.wardNumber : wardNumber // ignore: cast_nullable_to_non_nullable
as String,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

/// Create a copy of PickupModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AppUserCopyWith<$Res> get resident {
  
  return $AppUserCopyWith<$Res>(_self.resident, (value) {
    return _then(_self.copyWith(resident: value));
  });
}
}

// dart format on
