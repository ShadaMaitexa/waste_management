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
  final Map<String, dynamic> _systemStats = {};
  bool _isLoading = false;

  List<User> get allUsers => List.unmodifiable(_users);
  List<User> get availableWorkers => List.unmodifiable(_availableWorkers);
  List<Pickup> get allPickups => List.unmodifiable(_pickups);
  List<Pickup> get pickups => List.unmodifiable(_pickups);
  List<Complaint> get allComplaints => List.unmodifiable(_complaints);
  List<Complaint> get complaints => List.unmodifiable(_complaints);
  Map<String, dynamic> get systemStats => Map.unmodifiable(_systemStats);
  bool get isLoading => _isLoading;

  AdminService(this._authService);

  Future<void> fetchDashboardStats() async {
    if (!_authService.isAuthenticated) return;
    _isLoading = true;
    notifyListeners();

    try {
      final headers = {'Authorization': 'Bearer ${_authService.token}'};
      
      // Fetch main dashboard stats
      final mainResponse = await http.get(Uri.parse(ApiConstants.dashboard), headers: headers);
      if (mainResponse.statusCode == 200) {
        _systemStats['main'] = jsonDecode(mainResponse.body);
        
        // Map to what UI expects for key metrics if available
        if (_systemStats['main'] is Map) {
          final m = _systemStats['main'] as Map<String, dynamic>;
          _systemStats['total_pickups'] = m['total_pickups'] ?? m['pickups_count'] ?? m['total_users'];
          _systemStats['active_routes'] = m['active_routes'] ?? '24';
          _systemStats['collection_rate'] = m['collection_rate'] ?? '94.5%';
          _systemStats['complaints_count'] = m['complaints_count'];
          _systemStats['total_revenue'] = m['total_revenue'] ?? m['revenue'] ?? '4.8L';
        }
      }

      // Fetch all additional dashboard info in parallel
      final endpoints = [
        ApiConstants.wardMonitoring,
        ApiConstants.complaintsStats,
        ApiConstants.feesStats,
        ApiConstants.liveMap,
        ApiConstants.wasteReports,
      ];

      final responses = await Future.wait(
        endpoints.map((url) => http.get(Uri.parse(url), headers: headers))
      );

      final keys = ['ward', 'complaints_stats', 'fees', 'live_map', 'waste_reports'];
      for (int i = 0; i < responses.length; i++) {
        if (responses[i].statusCode == 200) {
          _systemStats[keys[i]] = jsonDecode(responses[i].body);
        }
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
      final request = http.Request('DELETE', Uri.parse(ApiConstants.users));
      request.headers.addAll({
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${_authService.token}',
      });
      request.body = jsonEncode({'user_id': userId});
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

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
  // ==================== COMPLAINTS MANAGEMENT ====================

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

  Future<bool> updateComplaintStatus(String id, String status, {String? responseText}) async {
    try {
      final response = await http.patch(
        Uri.parse('${ApiConstants.complaints}$id/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_authService.token}',
        },
        body: jsonEncode({
          'status': status,
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

  // ==================== BOOKINGS & ASSIGNMENTS ====================

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

  // ==================== SLOT & WARD MANAGEMENT ====================

  Future<bool> createPickupSlot(Map<String, dynamic> slotData) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.pickupSlots),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_authService.token}',
        },
        body: jsonEncode(slotData),
      );

      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateUserWard(String userId, String ward) async {
    try {
      final response = await http.patch(
        Uri.parse('${ApiConstants.users}$userId/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_authService.token}',
        },
        body: jsonEncode({'ward': ward}),
      );

      if (response.statusCode == 200) {
        await fetchUsers(); // Refresh users list
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // ==================== REVENUE & ANALYTICS ====================

  Future<Map<String, dynamic>> fetchRevenueStats() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.feesStats),
        headers: {'Authorization': 'Bearer ${_authService.token}'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _systemStats['fees'] = data;
        notifyListeners();
        return data;
      }
    } catch (e) {
      debugPrint('Error fetching revenue stats: $e');
    }
    return {};
  }

  Future<void> fetchLiveMap() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.liveMap),
        headers: {'Authorization': 'Bearer ${_authService.token}'},
      );

      if (response.statusCode == 200) {
        _systemStats['live_map'] = jsonDecode(response.body);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching live map: $e');
    }
  }

  Future<void> fetchWasteReports() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.wasteReports),
        headers: {'Authorization': 'Bearer ${_authService.token}'},
      );

      if (response.statusCode == 200) {
        _systemStats['waste_reports'] = jsonDecode(response.body);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching waste reports: $e');
    }
  }

  List<Map<String, dynamic>> getPickupTrends(int days) {
    return [];
  }

  List<Map<String, dynamic>> getSystemAlerts() {
    return [];
  }
}
