import 'package:json_annotation/json_annotation.dart';

enum UserRole {
  @JsonValue('resident')
  resident,
  
  @JsonValue('hks_worker')
  hksWorker,
  
  @JsonValue('driver')
  driver,
  
  @JsonValue('admin')
  admin,
  
  @JsonValue('recycler')
  recycler;
}
