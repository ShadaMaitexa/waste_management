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

  factory WorkerShift.fromJson(Map<String, dynamic> json) {
    return WorkerShift(
      id: json['id']?.toString() ?? '',
      workerId: json['worker_id']?.toString() ?? '',
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      startTime: TimeOfDay(
        hour: int.tryParse(json['start_time']?.toString().split(':')[0] ?? '8') ?? 8,
        minute: int.tryParse(json['start_time']?.toString().split(':')[1] ?? '0') ?? 0,
      ),
      endTime: TimeOfDay(
        hour: int.tryParse(json['end_time']?.toString().split(':')[0] ?? '17') ?? 17,
        minute: int.tryParse(json['end_time']?.toString().split(':')[1] ?? '30') ?? 30,
      ),
      ward: json['ward']?.toString() ?? '',
      type: ShiftType.values.firstWhere(
            (e) => e.name.toLowerCase() == json['type'],
        orElse: () => ShiftType.morning,
      ),
      status: ShiftStatus.values.firstWhere(
            (e) => e.name.toLowerCase() == json['status'],
        orElse: () => ShiftStatus.pending,
      ),
      estimatedPickups: json['estimated_pickups'] ?? 0,
      actualPickups: json['actual_pickups'] ?? 0,
      notes: json['notes'],
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at']) : null,
    );
  }

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

  factory WorkerAttendance.fromJson(Map<String, dynamic> json) {
    return WorkerAttendance(
      id: json['id']?.toString() ?? '',
      workerId: json['worker_id']?.toString() ?? '',
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      checkInTime: json['check_in_time'] != null ? DateTime.parse(json['check_in_time']) : null,
      checkOutTime: json['check_out_time'] != null ? DateTime.parse(json['check_out_time']) : null,
      totalHours: (json['total_hours'] as num?)?.toDouble(),
      status: AttendanceStatus.values.firstWhere(
            (e) => e.name.toLowerCase() == json['status'],
        orElse: () => AttendanceStatus.present,
      ),
    );
  }

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

  factory WorkerStats.fromJson(Map<String, dynamic> json) {
    return WorkerStats(
      workerId: json['worker_id']?.toString() ?? '',
      totalShifts: json['total_shifts'] ?? 0,
      completedShifts: json['completed_shifts'] ?? 0,
      totalPickups: json['total_pickups'] ?? 0,
      completedPickups: json['completed_pickups'] ?? 0,
      attendanceRate: (json['attendance_rate'] as num?)?.toDouble() ?? 0.0,
      performanceScore: (json['performance_score'] as num?)?.toDouble() ?? 0.0,
      averagePickupTime: (json['average_pickup_time'] as num?)?.toDouble() ?? 0.0,
      totalWorkingHours: (json['total_working_hours'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
