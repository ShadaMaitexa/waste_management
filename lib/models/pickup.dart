import 'package:flutter/material.dart';

class Pickup {
  final String id;
  final String userId;
  final String userName;
  final String userPhone;
  final String address;
  final String wardNumber;
  final PickupType type;
  final PickupStatus status;
  final DateTime scheduledDate;
  final TimeOfDay scheduledTime;
  final String? notes;
  final String? assignedWorkerId;
  final String? assignedWorkerName;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final double? weight;
  final List<WasteType> wasteTypes;
  final double? estimatedDuration; // in minutes
  final String? specialInstructions;

  Pickup({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.address,
    required this.wardNumber,
    required this.type,
    required this.status,
    required this.scheduledDate,
    required this.scheduledTime,
    this.notes,
    this.assignedWorkerId,
    this.assignedWorkerName,
    this.completedAt,
    required this.createdAt,
    this.updatedAt,
    this.weight,
    required this.wasteTypes,
    this.estimatedDuration,
    this.specialInstructions,
  });

  factory Pickup.fromJson(Map<String, dynamic> json) {
    return Pickup(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      userPhone: json['userPhone'] ?? '',
      address: json['address'] ?? '',
      wardNumber: json['wardNumber'] ?? '',
      type: PickupType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => PickupType.regular,
      ),
      status: PickupStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => PickupStatus.scheduled,
      ),
      scheduledDate: DateTime.parse(json['scheduledDate']),
      scheduledTime: TimeOfDay.fromDateTime(DateTime.parse(json['scheduledTime'])),
      notes: json['notes'],
      assignedWorkerId: json['assignedWorkerId'],
      assignedWorkerName: json['assignedWorkerName'],
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      weight: json['weight']?.toDouble(),
      wasteTypes: (json['wasteTypes'] as List).map((e) => 
        WasteType.values.firstWhere(
          (w) => w.toString().split('.').last == e,
          orElse: () => WasteType.mixed,
        )
      ).toList(),
      estimatedDuration: json['estimatedDuration']?.toDouble(),
      specialInstructions: json['specialInstructions'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userPhone': userPhone,
      'address': address,
      'wardNumber': wardNumber,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'scheduledDate': scheduledDate.toIso8601String(),
      'scheduledTime': DateTime(
        scheduledDate.year,
        scheduledDate.month,
        scheduledDate.day,
        scheduledTime.hour,
        scheduledTime.minute,
      ).toIso8601String(),
      'notes': notes,
      'assignedWorkerId': assignedWorkerId,
      'assignedWorkerName': assignedWorkerName,
      'completedAt': completedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'weight': weight,
      'wasteTypes': wasteTypes.map((e) => e.toString().split('.').last).toList(),
      'estimatedDuration': estimatedDuration,
      'specialInstructions': specialInstructions,
    };
  }

  Pickup copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userPhone,
    String? address,
    String? wardNumber,
    PickupType? type,
    PickupStatus? status,
    DateTime? scheduledDate,
    TimeOfDay? scheduledTime,
    String? notes,
    String? assignedWorkerId,
    String? assignedWorkerName,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? weight,
    List<WasteType>? wasteTypes,
    double? estimatedDuration,
    String? specialInstructions,
  }) {
    return Pickup(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPhone: userPhone ?? this.userPhone,
      address: address ?? this.address,
      wardNumber: wardNumber ?? this.wardNumber,
      type: type ?? this.type,
      status: status ?? this.status,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      notes: notes ?? this.notes,
      assignedWorkerId: assignedWorkerId ?? this.assignedWorkerId,
      assignedWorkerName: assignedWorkerName ?? this.assignedWorkerName,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      weight: weight ?? this.weight,
      wasteTypes: wasteTypes ?? this.wasteTypes,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      specialInstructions: specialInstructions ?? this.specialInstructions,
    );
  }

  String get formattedTime {
    return '${scheduledTime.hourOfPeriod == 0 ? 12 : scheduledTime.hourOfPeriod}:${scheduledTime.minute.toString().padLeft(2, '0')} ${scheduledTime.period == DayPeriod.am ? 'AM' : 'PM'}';
  }

  bool get isCompleted => status == PickupStatus.completed;
  bool get isScheduled => status == PickupStatus.scheduled;
  bool get isInProgress => status == PickupStatus.inProgress;
  bool get isCancelled => status == PickupStatus.cancelled;
}

enum PickupType { regular, emergency, instant }
enum PickupStatus { scheduled, inProgress, completed, cancelled, failed }
enum WasteType { mixed, dry, wet, organic, recyclable, electronic, hazardous }
