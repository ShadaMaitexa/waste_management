import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/pickup.dart';
import '../utils/api_constants.dart';
import 'auth_service.dart';

class AdminService extends ChangeNotifier {
  final AuthService _authService;
  List<User> _users = [];
  List<Pickup> _pickups = [];
  Map<String, dynamic> _systemStats = {};
  bool _isLoading = false;

  List<User> get allUsers => List.unmodifiable(_users);
  List<Pickup> get allPickups => List.unmodifiable(_pickups);
  Map<String, dynamic> get systemStats => Map.unmodifiable(_systemStats);
  bool get isLoading => _isLoading;

  AdminService(this._authService);

  Future<void> fetchDashboardStats() async {
    if (!_authService.isAuthenticated) return;
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse(ApiConstants.dashboard),
        headers: {'Authorization': 'Bearer ${_authService.token}'},
      );

      if (response.statusCode == 200) {
        _systemStats = jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('Error fetching dashboard stats: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchUsers() async {
    if (!_authService.isAuthenticated) return;
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.users),
        headers: {'Authorization': 'Bearer ${_authService.token}'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _users = data.map((json) => User.fromJson(json)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching users: $e');
    }
  }

  // ==================== USER MANAGEMENT ====================

  // Create new user (Create HKS Worker)
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

  // Delete user
  Future<bool> deleteUser(String userId) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConstants.users}$userId/'),
        headers: {'Authorization': 'Bearer ${_authService.token}'},
      );

      if (response.statusCode == 204) {
        _users.removeWhere((u) => u.id == userId);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
  List<Map<String, dynamic>> getPickupTrends(int days) {
    return [
      {'day': 'Mon', 'value': 45},
      {'day': 'Tue', 'value': 52},
      {'day': 'Wed', 'value': 48},
      {'day': 'Thu', 'value': 61},
      {'day': 'Fri', 'value': 55},
      {'day': 'Sat', 'value': 67},
      {'day': 'Sun', 'value': 42},
    ];
  }
  List<Map<String, dynamic>> getSystemAlerts() {
    return [
      {
        'id': '1',
        'message': 'Waste accumulation high in Ward 15',
        'type': 'warning',
        'time': '15 mins ago',
      },
      {
        'id': '2',
        'message': 'Driver Rahul Kumar reported delay due to traffic',
        'type': 'info',
        'time': '1 hour ago',
      },
      {
        'id': '3',
        'message': 'New recycler partnership request from "GreenRecycle Co."',
        'type': 'success',
        'time': '3 hours ago',
      },
    ];
  }
}
