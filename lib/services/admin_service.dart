import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/pickup.dart';
import '../models/complaint.dart';
import '../utils/api_constants.dart';
import 'auth_service.dart';

class AdminService extends ChangeNotifier {
  final AuthService _authService;
  List<User> _users = [];
  List<Pickup> _pickups = [];
  List<Complaint> _complaints = [];
  Map<String, dynamic> _systemStats = {};
  bool _isLoading = false;

  List<User> get allUsers => List.unmodifiable(_users);
  List<Pickup> get allPickups => List.unmodifiable(_pickups);
  List<Complaint> get allComplaints => List.unmodifiable(_complaints);
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
        }
      }

      // Fetch additional dashboard info
      final responses = await Future.wait([
        http.get(Uri.parse(ApiConstants.wardMonitoring), headers: headers),
        http.get(Uri.parse(ApiConstants.complaintsStats), headers: headers),
        http.get(Uri.parse(ApiConstants.feesStats), headers: headers),
      ]);

      if (responses[0].statusCode == 200) _systemStats['ward'] = jsonDecode(responses[0].body);
      if (responses[1].statusCode == 200) _systemStats['complaints_stats'] = jsonDecode(responses[1].body);
      if (responses[2].statusCode == 200) _systemStats['fees'] = jsonDecode(responses[2].body);
      
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

  // ==================== REVENUE & ANALYTICS ====================

  Future<Map<String, dynamic>> fetchRevenueStats() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.feesStats),
        headers: {'Authorization': 'Bearer ${_authService.token}'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('Error fetching revenue stats: $e');
    }
    return {};
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
