import 'package:flutter/material.dart';

class PickupSlot {
  final String id;
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final bool isAvailable;
  final int capacity;
  final int bookedCount;

  PickupSlot({
    required this.id,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.isAvailable = true,
    this.capacity = 10,
    this.bookedCount = 0,
  });

  factory PickupSlot.fromJson(Map<String, dynamic> json) {
    return PickupSlot(
      id: json['id']?.toString() ?? '',
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      startTime: (json['start_time'] != null || json['startTime'] != null)
          ? _parseTime(json['start_time'] ?? json['startTime'])
          : const TimeOfDay(hour: 8, minute: 0),
      endTime: (json['end_time'] != null || json['endTime'] != null)
          ? _parseTime(json['end_time'] ?? json['endTime'])
          : const TimeOfDay(hour: 10, minute: 0),
      isAvailable: json['is_available'] ?? json['isAvailable'] ?? true,
      capacity: json['capacity'] ?? 10,
      bookedCount: json['booked_count'] ?? json['bookedCount'] ?? 0,
    );
  }

  static TimeOfDay _parseTime(String timeStr) {
    final parts = timeStr.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String().split('T')[0],
    'start_time': '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}',
    'end_time': '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}',
    'is_available': isAvailable,
    'capacity': capacity,
    'booked_count': bookedCount,
  };

  String formatTime(BuildContext context) {
    return '${startTime.format(context)} - ${endTime.format(context)}';
  }
}
