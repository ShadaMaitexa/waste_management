import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../models/worker_models.dart';
import '../utils/api_constants.dart';
import 'auth_service.dart';

class WorkerService extends ChangeNotifier {
  final AuthService _authService;
  List<WorkerShift> _shifts = [];
  List<WorkerAttendance> _attendance = [];
  Map<String, WorkerStats> _workerStats = {};
  bool _isLoading = false;

  List<WorkerShift> get allShifts => List.unmodifiable(_shifts);
  List<WorkerAttendance> get allAttendance => List.unmodifiable(_attendance);
  Map<String, WorkerStats> get workerStats => Map.unmodifiable(_workerStats);
  bool get isLoading => _isLoading;

  WorkerService(this._authService);

  // ================= INIT =================

  Future<void> fetchDashboardData() async {
    if (!_authService.isAuthenticated) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      await Future.wait([
        fetchShifts(),
        fetchAttendance(),
        fetchStats(),
      ]);
    } catch (e) {
      debugPrint('Error fetching worker data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ================= SHIFTS =================

  Future<void> fetchShifts() async {
    if (!_authService.isAuthenticated) return;
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.workerShifts),
        headers: {'Authorization': 'Bearer ${_authService.token}'},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _shifts = data.map((json) => WorkerShift.fromJson(json)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching shifts: $e');
    }
  }

  WorkerShift? getTodayShift(String workerId) {
    if (_shifts.isEmpty) return null;
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));

    for (final s in _shifts) {
      if (s.workerId == workerId && !s.date.isBefore(start) && s.date.isBefore(end)) {
        return s;
      }
    }
    return null;
  }

  List<WorkerShift> getUpcomingShifts(String workerId, {int limit = 5}) {
    final now = DateTime.now();
    final list = _shifts.where((s) => s.workerId == workerId && s.date.isAfter(now)).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    return list.take(limit).toList();
  }

  Future<bool> updateShiftStatus(String shiftId, ShiftStatus status) async {
    try {
      final response = await http.patch(
        Uri.parse('${ApiConstants.workerShifts}$shiftId/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_authService.token}'
        },
        body: jsonEncode({'status': status.name}),
      );
      if (response.statusCode == 200) {
        final index = _shifts.indexWhere((s) => s.id == shiftId);
        if (index != -1) {
          _shifts[index] = _shifts[index].copyWith(status: status);
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error updating shift: $e');
      return false;
    }
  }

  Future<bool> completeShift(String shiftId, int actualPickups, {String? notes}) async {
    try {
      final response = await http.patch(
        Uri.parse('${ApiConstants.workerShifts}$shiftId/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_authService.token}'
        },
        body: jsonEncode({
          'status': ShiftStatus.completed.name,
          'actual_pickups': actualPickups,
          'notes': notes,
        }),
      );
      if (response.statusCode == 200) {
        final index = _shifts.indexWhere((s) => s.id == shiftId);
        if (index != -1) {
          _shifts[index] = _shifts[index].copyWith(
            status: ShiftStatus.completed,
            actualPickups: actualPickups,
            notes: notes,
            completedAt: DateTime.now(),
          );
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error completing shift: $e');
      return false;
    }
  }

  // ================= ATTENDANCE =================

  Future<void> fetchAttendance() async {
    if (!_authService.isAuthenticated) return;
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.workerAttendance),
        headers: {'Authorization': 'Bearer ${_authService.token}'},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _attendance = data.map((json) => WorkerAttendance.fromJson(json)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching attendance: $e');
    }
  }

  Future<bool> checkIn(String workerId) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.workerAttendance}check-in/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_authService.token}'
        },
        body: jsonEncode({'worker_id': workerId}),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        await fetchAttendance();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error checking in: $e');
      return false;
    }
  }

  Future<bool> checkOut(String workerId) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.workerAttendance}check-out/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_authService.token}'
        },
        body: jsonEncode({'worker_id': workerId}),
      );
      if (response.statusCode == 200) {
        await fetchAttendance();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error checking out: $e');
      return false;
    }
  }

  // ================= STATS =================
  
  Future<void> fetchStats() async {
    if (!_authService.isAuthenticated) return;
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.workerStats),
        headers: {'Authorization': 'Bearer ${_authService.token}'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Assuming the response maps worker IDs to their stats, or just a single stat object depending on the user.
        if (data is Map<String, dynamic>) {
          if (data.containsKey('worker_id')) {
            final stats = WorkerStats.fromJson(data);
            _workerStats[stats.workerId] = stats;
          } else {
             data.forEach((key, value) {
               _workerStats[key] = WorkerStats.fromJson(value);
             });
          }
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching worker stats: $e');
    }
  }


  // ================= UTIL =================

  String getFormattedShiftTime(TimeOfDay start, TimeOfDay end) {
    final now = DateTime.now();
    final s = DateTime(now.year, now.month, now.day, start.hour, start.minute);
    final e = DateTime(now.year, now.month, now.day, end.hour, end.minute);
    return '${DateFormat('h:mm a').format(s)} - ${DateFormat('h:mm a').format(e)}';
  }
}
