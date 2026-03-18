import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/pickup.dart';
import '../models/pickup_slot.dart';
import '../utils/api_constants.dart';
import 'auth_service.dart';

class PickupService extends ChangeNotifier {
  final AuthService _authService;
  List<Pickup> _pickups = [];
  List<PickupSlot> _availableSlots = [];
  bool _isLoading = false;

  PickupService(this._authService);

  List<Pickup> get pickups => List.unmodifiable(_pickups);
  List<PickupSlot> get availableSlots => List.unmodifiable(_availableSlots);
  bool get isLoading => _isLoading;

  // ==================== PICKUPS ====================

  Future<void> fetchPickups() async {
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
      debugPrint('Error fetching pickups: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Pickup> getPickupsForUser(String userId) =>
      _pickups.where((p) => p.userId == userId).toList();

  List<Pickup> getUpcomingPickupsForUser(String userId) {
    final now = DateTime.now();
    return _pickups
        .where((p) =>
            p.userId == userId &&
            p.scheduledDate.isAfter(now) &&
            p.status == PickupStatus.scheduled)
        .toList()
      ..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
  }

  List<Pickup> getPickupsForWorker(String workerId) =>
      _pickups.where((p) => p.assignedWorkerId == workerId).toList();

  List<Pickup> getTodaysPickupsForWorker(String workerId) {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return _pickups
        .where((p) =>
            p.assignedWorkerId == workerId &&
            p.scheduledDate.isAfter(startOfDay) &&
            p.scheduledDate.isBefore(endOfDay))
        .toList();
  }

  List<Pickup> getAllPickups() => List.from(_pickups);

  Future<bool> createPickup({
    required String item,
    required String address,
    required DateTime date,
    required int slotId,
    required String wasteType,
  }) async {
    try {
      final dateStr =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      final response = await http.post(
        Uri.parse(ApiConstants.pickups),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_authService.token}',
        },
        body: jsonEncode({
          'item': item,
          'address': address,
          'date': dateStr,
          'slot': slotId,
          'waste_type': wasteType,
          'status': 'pending',
          'fee_paid': false,
        }),
      );

      if (response.statusCode == 201) {
        await fetchPickups();
        return true;
      }
      debugPrint('createPickup failed: ${response.statusCode} ${response.body}');
      return false;
    } catch (e) {
      debugPrint('createPickup error: $e');
      return false;
    }
  }

  Future<bool> updatePickupStatus(String pickupId, PickupStatus status,
      {int? workerId}) async {
    try {
      String statusStr;
      switch (status) {
        case PickupStatus.scheduled:
          statusStr = 'pending';
          break;
        case PickupStatus.assigned:
          statusStr = 'assigned';
          break;
        case PickupStatus.inProgress:
          statusStr = 'in_progress';
          break;
        case PickupStatus.completed:
          statusStr = 'completed';
          break;
        case PickupStatus.cancelled:
          statusStr = 'cancelled';
          break;
        case PickupStatus.failed:
          statusStr = 'failed';
          break;
      }

      final response = await http.patch(
        Uri.parse('${ApiConstants.pickups}$pickupId/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_authService.token}',
        },
        body: jsonEncode({
          'status': statusStr,
          if (workerId != null) 'assigned_worker': workerId,
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

  Future<bool> cancelPickup(String pickupId) async =>
      updatePickupStatus(pickupId, PickupStatus.cancelled);

  Future<bool> deletePickup(String pickupId) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConstants.pickups}$pickupId/'),
        headers: {'Authorization': 'Bearer ${_authService.token}'},
      );
      if (response.statusCode == 204) {
        _pickups.removeWhere((p) => p.id == pickupId);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Map<String, int> getPickupStatistics() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 1);
    final monthly = _pickups
        .where((p) =>
            p.scheduledDate.isAfter(startOfMonth) &&
            p.scheduledDate.isBefore(endOfMonth))
        .length;

    return {
      'total': _pickups.length,
      'scheduled': _pickups.where((p) => p.status == PickupStatus.scheduled).length,
      'assigned': _pickups.where((p) => p.status == PickupStatus.assigned).length,
      'inProgress': _pickups.where((p) => p.status == PickupStatus.inProgress).length,
      'completed': _pickups.where((p) => p.status == PickupStatus.completed).length,
      'cancelled': _pickups.where((p) => p.status == PickupStatus.cancelled).length,
      'failed': _pickups.where((p) => p.status == PickupStatus.failed).length,
      'monthly': monthly,
    };
  }

  double getTotalWasteCollectedForUser(String userId) {
    return _pickups
        .where((p) => p.userId == userId && p.status == PickupStatus.completed)
        .fold(0.0, (sum, p) => sum + (p.weightKg ?? 5.0));
  }

  // ==================== PICKUP SLOTS ====================

  Future<void> fetchAvailableSlots() async {
    if (!_authService.isAuthenticated) return;

    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse(ApiConstants.pickupSlots),
        headers: {'Authorization': 'Bearer ${_authService.token}'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _availableSlots = data.map((json) => PickupSlot.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Error fetching slots: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createPickupSlot(PickupSlot slot) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.pickupSlots),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_authService.token}',
        },
        body: jsonEncode(slot.toJson()),
      );
      if (response.statusCode == 201) {
        await fetchAvailableSlots();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deletePickupSlot(String slotId) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConstants.pickupSlots}$slotId/'),
        headers: {'Authorization': 'Bearer ${_authService.token}'},
      );
      if (response.statusCode == 204) {
        _availableSlots.removeWhere((s) => s.id == slotId);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
