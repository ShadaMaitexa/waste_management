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
      startTime: json['startTime'] != null 
          ? _parseTime(json['startTime'])
          : const TimeOfDay(hour: 8, minute: 0),
      endTime: json['endTime'] != null 
          ? _parseTime(json['endTime'])
          : const TimeOfDay(hour: 10, minute: 0),
      isAvailable: json['isAvailable'] ?? true,
      capacity: json['capacity'] ?? 10,
      bookedCount: json['bookedCount'] ?? 0,
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
    'startTime': '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}',
    'endTime': '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}',
    'isAvailable': isAvailable,
    'capacity': capacity,
    'bookedCount': bookedCount,
  };

  String formatTime(BuildContext context) {
    return '${startTime.format(context)} - ${endTime.format(context)}';
  }
}
