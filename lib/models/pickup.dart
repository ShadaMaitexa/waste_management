import 'package:flutter/material.dart';

/// Matches the backend API for /api/pickups/
/// Fields: id, resident, resident_name, item, item_display, address, date,
///         slot, slot_display, status, assigned_worker, assigned_worker_name,
///         fee_amount, fee_paid, waste_type, weight_kg, created_at

class Pickup {
  final String id;
  final String userId;       // resident (int from backend, stored as String)
  final String userName;     // resident_name
  final String address;
  final String item;         // e.g. "ampoules", "dry", "wet" — the item enum key
  final String itemDisplay;  // human-readable label from backend
  final String wasteType;    // "dry", "wet", "e-waste", etc.
  final String? ward;        // ward
  final PickupStatus status;
  final DateTime scheduledDate;    // date
  final int? slotId;               // slot (int FK)
  final String slotDisplay;        // slot_display e.g. "8:00 AM - 9:00 AM"
  final String? assignedWorkerId;  // assigned_worker
  final String? assignedWorkerName;
  final String feeAmount;          // fee_amount (string decimal from API)
  final bool feePaid;              // fee_paid
  final double? weightKg;          // weight_kg
  final String? specialInstructions; // special_instructions
  final DateTime createdAt;

  Pickup({
    required this.id,
    required this.userId,
    required this.userName,
    required this.address,
    required this.item,
    required this.itemDisplay,
    required this.wasteType,
    this.ward,
    required this.status,
    required this.scheduledDate,
    this.slotId,
    required this.slotDisplay,
    this.assignedWorkerId,
    this.assignedWorkerName,
    required this.feeAmount,
    required this.feePaid,
    this.weightKg,
    this.specialInstructions,
    required this.createdAt,
  });

  factory Pickup.fromJson(Map<String, dynamic> json) {
    final rawStatus = (json['status'] ?? 'pending').toString().toLowerCase();
    PickupStatus parsedStatus;
    switch (rawStatus) {
      case 'in_progress':
        parsedStatus = PickupStatus.inProgress;
        break;
      case 'assigned':
        parsedStatus = PickupStatus.assigned;
        break;
      case 'completed':
        parsedStatus = PickupStatus.completed;
        break;
      case 'cancelled':
        parsedStatus = PickupStatus.cancelled;
        break;
      case 'failed':
        parsedStatus = PickupStatus.failed;
        break;
      default:
        parsedStatus = PickupStatus.scheduled;
    }

    return Pickup(
      id: (json['id'] ?? '').toString(),
      userId: (json['resident'] ?? '').toString(),
      userName: json['resident_name'] ?? '',
      address: json['address'] ?? '',
      item: json['item'] ?? '',
      itemDisplay: json['item_display'] ?? json['item'] ?? '',
      wasteType: json['waste_type'] ?? 'dry',
      ward: (json['ward'] ?? '').toString(),
      status: parsedStatus,
      scheduledDate: json['date'] != null
          ? DateTime.tryParse(json['date']) ?? DateTime.now()
          : DateTime.now(),
      slotId: json['slot'] is int ? json['slot'] : int.tryParse(json['slot']?.toString() ?? ''),
      slotDisplay: json['slot_display'] ?? '',
      assignedWorkerId: json['assigned_worker']?.toString(),
      assignedWorkerName: json['assigned_worker_name'],
      feeAmount: (json['fee_amount'] ?? '0').toString(),
      feePaid: json['fee_paid'] ?? false,
      weightKg: double.tryParse((json['weight_kg'] ?? '').toString()),
      specialInstructions: json['special_instructions'] ?? json['notes'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    final dateStr =
        '${scheduledDate.year}-${scheduledDate.month.toString().padLeft(2, '0')}-${scheduledDate.day.toString().padLeft(2, '0')}';
    return {
      'item': item,
      'address': address,
      'date': dateStr,
      if (slotId != null) 'slot': slotId,
      'status': status == PickupStatus.scheduled ? 'pending' : status.name,
      'waste_type': wasteType,
      'fee_amount': feeAmount,
      'fee_paid': feePaid,
    };
  }

  Pickup copyWith({
    String? id,
    String? userId,
    String? userName,
    String? address,
    String? item,
    String? itemDisplay,
    String? wasteType,
    PickupStatus? status,
    DateTime? scheduledDate,
    int? slotId,
    String? slotDisplay,
    String? assignedWorkerId,
    String? assignedWorkerName,
    String? feeAmount,
    bool? feePaid,
    double? weightKg,
    String? specialInstructions,
    DateTime? createdAt,
  }) {
    return Pickup(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      address: address ?? this.address,
      item: item ?? this.item,
      itemDisplay: itemDisplay ?? this.itemDisplay,
      wasteType: wasteType ?? this.wasteType,
      status: status ?? this.status,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      slotId: slotId ?? this.slotId,
      slotDisplay: slotDisplay ?? this.slotDisplay,
      assignedWorkerId: assignedWorkerId ?? this.assignedWorkerId,
      assignedWorkerName: assignedWorkerName ?? this.assignedWorkerName,
      feeAmount: feeAmount ?? this.feeAmount,
      feePaid: feePaid ?? this.feePaid,
      weightKg: weightKg ?? this.weightKg,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get isCompleted => status == PickupStatus.completed;
  bool get isScheduled => status == PickupStatus.scheduled;
  bool get isAssigned => status == PickupStatus.assigned;
  bool get isInProgress => status == PickupStatus.inProgress;
  bool get isCancelled => status == PickupStatus.cancelled;

  // Legacy compatibility
  String get wardNumber => ward ?? '';
  TimeOfDay get scheduledTime => const TimeOfDay(hour: 8, minute: 0);
  String get formattedTime => slotDisplay;
  List<String> get wasteTypes => [wasteType];
}

enum PickupStatus { scheduled, assigned, inProgress, completed, cancelled, failed }
