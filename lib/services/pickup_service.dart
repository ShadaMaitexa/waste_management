import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/pickup.dart';
import '../utils/api_constants.dart';
import 'auth_service.dart';

class PickupService extends ChangeNotifier {
  final AuthService _authService;
  List<Pickup> _pickups = [];
  bool _isLoading = false;

  PickupService(this._authService);

  List<Pickup> get pickups => List.unmodifiable(_pickups);
  bool get isLoading => _isLoading;

  Future<void> fetchPickups() async {
    if (!_authService.isAuthenticated) return;

    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse(ApiConstants.pickups),
        headers: {
          'Authorization': 'Bearer ${_authService.token}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _pickups = data.map((json) => Pickup.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Error fetching pickups: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get pickups for a specific user
  List<Pickup> getPickupsForUser(String userId) {
    return _pickups.where((pickup) => pickup.userId == userId).toList();
  }

  // Get upcoming pickups for a user
  List<Pickup> getUpcomingPickupsForUser(String userId) {
    final now = DateTime.now();
    return _pickups
        .where((pickup) => 
            pickup.userId == userId && 
            pickup.scheduledDate.isAfter(now) &&
            pickup.status == PickupStatus.scheduled)
        .toList()
      ..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
  }

  // Get pickups assigned to a worker
  List<Pickup> getPickupsForWorker(String workerId) {
    return _pickups.where((pickup) => pickup.assignedWorkerId == workerId).toList();
  }

  // Get today's pickups for a worker
  List<Pickup> getTodaysPickupsForWorker(String workerId) {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _pickups
        .where((pickup) => 
            pickup.assignedWorkerId == workerId &&
            pickup.scheduledDate.isAfter(startOfDay) &&
            pickup.scheduledDate.isBefore(endOfDay))
        .toList()
      ..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
  }

  // Get all pickups for admin dashboard
  List<Pickup> getAllPickups() {
    return List.from(_pickups);
  }

  // Create a new pickup
  Future<bool> createPickup(Pickup pickup) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.pickups),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_authService.token}',
        },
        body: jsonEncode(pickup.toJson()),
      );

      if (response.statusCode == 201) {
        await fetchPickups();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Update pickup status
  Future<bool> updatePickupStatus(String pickupId, PickupStatus status, {String? workerId, String? workerName}) async {
    try {
      final response = await http.patch(
        Uri.parse('${ApiConstants.pickups}$pickupId/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_authService.token}',
        },
        body: jsonEncode({
          'status': status.toString().split('.').last,
          if (workerId != null) 'assignedWorkerId': workerId,
          if (workerName != null) 'assignedWorkerName': workerName,
        }),
      );

      if (response.statusCode == 200) {
        await fetchPickups();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Assign worker to pickup
  Future<bool> assignWorker(String pickupId, String workerId, String workerName) async {
    return updatePickupStatus(pickupId, PickupStatus.inProgress, workerId: workerId, workerName: workerName);
  }

  // Cancel pickup
  Future<bool> cancelPickup(String pickupId) async {
    return updatePickupStatus(pickupId, PickupStatus.cancelled);
  }

  // Generate pickup ID
  String generatePickupId() {
    return 'pickup_${DateTime.now().millisecondsSinceEpoch}';
  }

  // Get pickup statistics
  Map<String, int> getPickupStatistics() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 1);

    final monthlyPickups = _pickups.where((pickup) {
      return pickup.scheduledDate.isAfter(startOfMonth) && 
             pickup.scheduledDate.isBefore(endOfMonth);
    }).toList();

    return {
      'total': _pickups.length,
      'scheduled': _pickups.where((p) => p.status == PickupStatus.scheduled).length,
      'completed': _pickups.where((p) => p.status == PickupStatus.completed).length,
      'cancelled': _pickups.where((p) => p.status == PickupStatus.cancelled).length,
      'inProgress': _pickups.where((p) => p.status == PickupStatus.inProgress).length,
      'monthly': monthlyPickups.length,
    };
  }

  // Get waste type statistics
  Map<WasteType, int> getWasteTypeStatistics() {
    final stats = <WasteType, int>{};
    
    for (final pickup in _pickups) {
      for (final wasteType in pickup.wasteTypes) {
        stats[wasteType] = (stats[wasteType] ?? 0) + 1;
      }
    }
    
    return stats;
  }

  // Get total waste collected in kg for a specific user
  double getTotalWasteCollectedForUser(String userId) {
    return _pickups
        .where((p) => p.userId == userId && p.status == PickupStatus.completed)
        .fold(0.0, (sum, p) => sum + (p.weight ?? 5.0)); // Default to 5kg if weight is null
  }
}
