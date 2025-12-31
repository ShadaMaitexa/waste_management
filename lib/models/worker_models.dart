import 'package:flutter/material.dart';

enum ShiftType { morning, evening, night }
enum ShiftStatus { pending, confirmed, inProgress, completed, cancelled }
enum AttendanceStatus { present, absent }

class WorkerShift {
  final String id;
  final String workerId;
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String ward;
  final ShiftType type;
  final ShiftStatus status;
  final int estimatedPickups;
  final int actualPickups;
  final String? notes;
  final DateTime? completedAt;

  WorkerShift({
    required this.id,
    required this.workerId,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.ward,
    required this.type,
    required this.status,
    required this.estimatedPickups,
    required this.actualPickups,
    this.notes,
    this.completedAt,
  });

  WorkerShift copyWith({
    ShiftStatus? status,
    int? actualPickups,
    String? notes,
    DateTime? completedAt,
  }) {
    return WorkerShift(
      id: id,
      workerId: workerId,
      date: date,
      startTime: startTime,
      endTime: endTime,
      ward: ward,
      type: type,
      status: status ?? this.status,
      estimatedPickups: estimatedPickups,
      actualPickups: actualPickups ?? this.actualPickups,
      notes: notes ?? this.notes,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

class WorkerAttendance {
  final String id;
  final String workerId;
  final DateTime date;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final double? totalHours;
  final AttendanceStatus status;

  WorkerAttendance({
    required this.id,
    required this.workerId,
    required this.date,
    this.checkInTime,
    this.checkOutTime,
    this.totalHours,
    required this.status,
  });

  WorkerAttendance copyWith({
    DateTime? checkInTime,
    DateTime? checkOutTime,
    double? totalHours,
    AttendanceStatus? status,
  }) {
    return WorkerAttendance(
      id: id,
      workerId: workerId,
      date: date,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      totalHours: totalHours ?? this.totalHours,
      status: status ?? this.status,
    );
  }
}

class WorkerStats {
  final String workerId;
  final int totalShifts;
  final int completedShifts;
  final int totalPickups;
  final int completedPickups;
  final double attendanceRate;
  final double performanceScore;
  final double averagePickupTime;
  final double totalWorkingHours;

  WorkerStats({
    required this.workerId,
    required this.totalShifts,
    required this.completedShifts,
    required this.totalPickups,
    required this.completedPickups,
    required this.attendanceRate,
    required this.performanceScore,
    required this.averagePickupTime,
    required this.totalWorkingHours,
  });
}
