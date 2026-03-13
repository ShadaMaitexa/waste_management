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
    
    // Status parsing
    final rawStatus = json['status']?.toString().toLowerCase() ?? 'pending';
    PickupStatus parsedStatus;
    if (rawStatus == 'pending') {
      parsedStatus = PickupStatus.scheduled;
    } else {
      parsedStatus = PickupStatus.values.firstWhere(
        (e) => e.toString().split('.').last == rawStatus,
        orElse: () => PickupStatus.scheduled,
      );
    }

    return Pickup(
      id: json['id']?.toString() ?? '',
      userId: json['resident']?.toString() ?? json['userId'] ?? '',
      userName: json['resident_name'] ?? json['userName'] ?? '',
      userPhone: json['userPhone'] ?? '',
      address: json['address'] ?? '',
      wardNumber: json['wardNumber'] ?? '',
      type: PickupType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => PickupType.regular,
      ),
      status: parsedStatus,
      scheduledDate: json['date'] != null 
          ? DateTime.tryParse(json['date']) ?? DateTime.now()
          : (json['scheduledDate'] != null ? DateTime.parse(json['scheduledDate']) : DateTime.now()),
      scheduledTime: json['scheduledTime'] != null 
          ? TimeOfDay.fromDateTime(DateTime.parse(json['scheduledTime'])) 
          : TimeOfDay.now(),
      notes: json['notes'],
      assignedWorkerId: json['assignedWorkerId'],
      assignedWorkerName: json['assignedWorkerName'],
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : (json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now()),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      weight: json['weight']?.toDouble(),
      wasteTypes: [],
      specialInstructions: json['item_display'] ?? json['item'] ?? json['specialInstructions'],
    );
  }

  Map<String, dynamic> toJson() {
    // Determine the status string backend expects
    String targetStatus = status.toString().split('.').last;
    if (targetStatus == 'scheduled') {
      targetStatus = 'pending';
    }

    // Backend expects item, address, date, status for creating
    return {
      'item': 'ampoules', // or a default value, or grab from wasteTypes if it existed
      'address': address,
      'date': "${scheduledDate.year}-${scheduledDate.month.toString().padLeft(2, '0')}-${scheduledDate.day.toString().padLeft(2, '0')}",
      'status': targetStatus,
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
