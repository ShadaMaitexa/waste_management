import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/pickup.dart';
import '../models/worker_models.dart';

class WorkerService extends ChangeNotifier {
  final List<WorkerShift> _shifts = [];
  final List<WorkerAttendance> _attendance = [];
  final Map<String, WorkerStats> _workerStats = {};

  List<WorkerShift> get allShifts => List.unmodifiable(_shifts);
  List<WorkerAttendance> get allAttendance => List.unmodifiable(_attendance);
  Map<String, WorkerStats> get workerStats =>
      Map.unmodifiable(_workerStats);

  WorkerService() {
    _initializeMockData();
  }

  // ================= INIT =================

  void _initializeMockData() {
    if (_shifts.isNotEmpty) return;

    final now = DateTime.now();
    final weekStart = _getWeekStart(now);

    _shifts.addAll([
      WorkerShift(
        id: 'shift1',
        workerId: 'worker1',
        date: weekStart,
        startTime: const TimeOfDay(hour: 8, minute: 0),
        endTime: const TimeOfDay(hour: 17, minute: 30),
        ward: '15',
        type: ShiftType.morning,
        status: ShiftStatus.confirmed,
        estimatedPickups: 12,
        actualPickups: 0,
      ),
      WorkerShift(
        id: 'shift2',
        workerId: 'worker1',
        date: weekStart.add(const Duration(days: 1)),
        startTime: const TimeOfDay(hour: 8, minute: 0),
        endTime: const TimeOfDay(hour: 17, minute: 30),
        ward: '12',
        type: ShiftType.morning,
        status: ShiftStatus.confirmed,
        estimatedPickups: 10,
        actualPickups: 0,
      ),
    ]);

    _workerStats['worker1'] = WorkerStats(
      workerId: 'worker1',
      totalShifts: 22,
      completedShifts: 20,
      totalPickups: 240,
      completedPickups: 228,
      attendanceRate: 95.5,
      performanceScore: 98.2,
      averagePickupTime: 28.5,
      totalWorkingHours: 176,
    );
  }

  // ================= SHIFTS =================

  WorkerShift? getTodayShift(String workerId) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));

    for (final s in _shifts) {
      if (s.workerId == workerId &&
          !s.date.isBefore(start) &&
          s.date.isBefore(end)) {
        return s;
      }
    }
    return null;
  }

  List<WorkerShift> getUpcomingShifts(String workerId, {int limit = 5}) {
    final now = DateTime.now();

    final list = _shifts
        .where((s) => s.workerId == workerId && s.date.isAfter(now))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    return list.take(limit).toList();
  }

  Future<bool> updateShiftStatus(
      String shiftId, ShiftStatus status) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _shifts.indexWhere((s) => s.id == shiftId);
    if (index == -1) return false;

    _shifts[index] = _shifts[index].copyWith(status: status);
    notifyListeners();
    return true;
  }

  Future<bool> completeShift(
      String shiftId, int actualPickups,
      {String? notes}) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final index = _shifts.indexWhere((s) => s.id == shiftId);
    if (index == -1) return false;

    _shifts[index] = _shifts[index].copyWith(
      status: ShiftStatus.completed,
      actualPickups: actualPickups,
      notes: notes,
      completedAt: DateTime.now(),
    );
    notifyListeners();
    return true;
  }

  // ================= ATTENDANCE =================

  Future<bool> checkIn(String workerId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));

    final index = _attendance.indexWhere(
      (a) =>
          a.workerId == workerId &&
          !a.date.isBefore(start) &&
          a.date.isBefore(end),
    );

    if (index == -1) {
      _attendance.add(
        WorkerAttendance(
          id: 'att_${now.millisecondsSinceEpoch}',
          workerId: workerId,
          date: now,
          checkInTime: now,
          status: AttendanceStatus.present,
        ),
      );
    }

    notifyListeners();
    return true;
  }

  Future<bool> checkOut(String workerId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));

    final index = _attendance.indexWhere(
      (a) =>
          a.workerId == workerId &&
          !a.date.isBefore(start) &&
          a.date.isBefore(end) &&
          a.checkOutTime == null,
    );

    if (index == -1) return false;

    final hours =
        now.difference(_attendance[index].checkInTime!).inMinutes /
            60;

    _attendance[index] = _attendance[index].copyWith(
      checkOutTime: now,
      totalHours: hours,
    );

    notifyListeners();
    return true;
  }

  // ================= UTIL =================

  DateTime _getWeekStart(DateTime date) {
    return DateTime(date.year, date.month, date.day)
        .subtract(Duration(days: date.weekday - 1));
  }

  String getFormattedShiftTime(
      TimeOfDay start, TimeOfDay end) {
    final now = DateTime.now();
    final s = DateTime(
        now.year, now.month, now.day, start.hour, start.minute);
    final e = DateTime(
        now.year, now.month, now.day, end.hour, end.minute);
    return '${DateFormat('h:mm a').format(s)} - ${DateFormat('h:mm a').format(e)}';
  }
}
