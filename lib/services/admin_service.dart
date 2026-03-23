import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/pickup.dart';
import '../models/complaint.dart';
import '../utils/api_constants.dart';
import 'auth_service.dart';

class AdminService extends ChangeNotifier {
  final AuthService _authService;
  List<User> _users = [];
  List<User> _availableWorkers = [];
  List<Pickup> _pickups = [];
  List<Complaint> _complaints = [];
  List<User> _nearbyDrivers = [];
  final Map<String, dynamic> _systemStats = {};
  bool _isLoading = false;

  List<User> get allUsers => List.unmodifiable(_users);
  List<User> get availableWorkers => List.unmodifiable(_availableWorkers);
  List<Pickup> get allPickups => List.unmodifiable(_pickups);
  List<Pickup> get pickups => List.unmodifiable(_pickups);
  List<Complaint> get allComplaints => List.unmodifiable(_complaints);
  List<Complaint> get complaints => List.unmodifiable(_complaints);
  List<User> get nearbyDrivers => List.unmodifiable(_nearbyDrivers);
  Map<String, dynamic> get systemStats => Map.unmodifiable(_systemStats);
  bool get isLoading => _isLoading;

  AdminService(this._authService);

  Future<void> fetchDashboardStats() async {
    if (!_authService.isAuthenticated) return;
    _isLoading = true;
    notifyListeners();

    try {
      final headers = {
        'Authorization': 'Bearer ${_authService.token}',
        'Content-Type': 'application/json',
      };
      
      // Fetch all dashboard info in parallel
      final Map<String, String> endpoints = {
        'main': ApiConstants.dashboard,
        'complaints_stats': ApiConstants.complaintsStats,
        'fees': ApiConstants.feesStats,
        'live_map': ApiConstants.liveMap,
        'ward': ApiConstants.wardMonitoring,
        'waste_reports': ApiConstants.wasteReports,
      };

      final results = await Future.wait(
        endpoints.entries.map((e) => http.get(Uri.parse(e.value), headers: headers))
      );

      int idx = 0;
      for (final key in endpoints.keys) {
        final resp = results[idx++];
        if (resp.statusCode == 200) {
          final data = jsonDecode(resp.body);
          _systemStats[key] = data;
          
          // Map "main" stats to top-level keys for easier UI access
          if (key == 'main' && data is Map) {
            _systemStats['total_pickups'] = data['total_pickups'] ?? data['pickups_count'] ?? 0;
            _systemStats['total_users'] = data['total_users'] ?? 0;
            _systemStats['active_routes'] = data['active_routes'] ?? '0';
          }
          
          if (key == 'fees' && data is Map) {
            _systemStats['total_revenue'] = data['total_collected'] ?? data['collected'] ?? '0';
          }
          
          if (key == 'complaints_stats' && data is Map) {
             _systemStats['complaints_count'] = data['total'] ?? data['count'] ?? 0;
          }
        }
      }
      
    } catch (e) {
      debugPrint('Error fetching dashboard stats: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchUsers({String? role}) async {
    if (!_authService.isAuthenticated) return;
    _isLoading = true;
    notifyListeners();

    try {
      String url = ApiConstants.users;
      if (role != null) {
        url = '$url?role=$role';
      }
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer ${_authService.token}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _users = data.map((json) => User.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Error fetching users: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createHksWorker(Map<String, dynamic> workerData) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.createHksWorker),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_authService.token}',
        },
        body: jsonEncode(workerData),
      );

      if (response.statusCode == 201) {
        await fetchUsers();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteUser(String userId) async {
    try {
      final response = await http.delete(
        Uri.parse(ApiConstants.users),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_authService.token}',
        },
        body: jsonEncode({'user_id': userId}),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        _users.removeWhere((u) => u.id == userId);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> fetchComplaints() async {
    if (!_authService.isAuthenticated) return;
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse(ApiConstants.complaints),
        headers: {'Authorization': 'Bearer ${_authService.token}'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _complaints = data.map((json) => Complaint.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Error fetching complaints: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateComplaintStatus(String id, String status, {String? responseText, String? workerId}) async {
    try {
      final response = await http.patch(
        Uri.parse('${ApiConstants.complaints}$id/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_authService.token}',
        },
        body: jsonEncode({
          'status': status,
          if (workerId != null) 'assigned_worker': workerId,
          if (responseText != null) 'response': responseText,
        }),
      );

      if (response.statusCode == 200) {
        await fetchComplaints();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteComplaint(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConstants.complaints}$id/'),
        headers: {'Authorization': 'Bearer ${_authService.token}'},
      );

      if (response.statusCode == 204) {
        _complaints.removeWhere((c) => c.id == id);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> fetchRevenueStats() async {
    await fetchDashboardStats();
    return _systemStats['fees'] ?? {};
  }

  Future<void> fetchAllBookings() async {
    if (!_authService.isAuthenticated) return;
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse(ApiConstants.pickups),
        headers: {'Authorization': 'Bearer ${_authService.token}'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _pickups = data.map((json) => Pickup.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Error fetching bookings: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAvailableWorkers() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.availableWorkers),
        headers: {'Authorization': 'Bearer ${_authService.token}'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _availableWorkers = data.map((json) => User.fromJson(json)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching available workers: $e');
    }
  }

  Future<bool> assignWorkerToBooking(String pickupId, String workerId) async {
    try {
      final response = await http.patch(
        Uri.parse('${ApiConstants.pickups}$pickupId/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_authService.token}',
        },
        body: jsonEncode({'assigned_worker': workerId, 'status': 'assigned'}),
      );

      if (response.statusCode == 200) {
        await fetchAllBookings();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> fetchNearbyDrivers(String lat, String lng) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.users}?role=driver&lat=$lat&lng=$lng&radius=5'), // Assuming 5km radius
        headers: {'Authorization': 'Bearer ${_authService.token}'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _nearbyDrivers = data.map((json) => User.fromJson(json)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching nearby drivers: $e');
    }
  }

  // Alerts for UI
  List<Map<String, dynamic>> getSystemAlerts() {
    // Derived from dashboard data if needed, or static for now
    return [
      {'message': 'System backup completed', 'time': '2m ago', 'type': 'info'},
      {'message': 'High complaint volume in Ward 15', 'time': '15m ago', 'type': 'warning'},
    ];
  }
}
