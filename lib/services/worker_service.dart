import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../utils/api_constants.dart';
import 'auth_service.dart';
import '../models/pickup.dart';

class WorkerService extends ChangeNotifier {
  final AuthService _authService;
  List<Pickup> _assignedPickups = [];
  bool _isLoading = false;

  List<Pickup> get assignedPickups => List.unmodifiable(_assignedPickups);
  bool get isLoading => _isLoading;

  WorkerService(this._authService);

  Future<void> fetchAssignedPickups() async {
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
        // The backend should filter pickups by the authenticated worker,
        // but for safety we filter it here as well.
        _assignedPickups = data.map((json) => Pickup.fromJson(json))
            .where((p) => p.assignedWorkerId == _authService.currentUser?.id.toString())
            .toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching assigned pickups: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updatePickupStatus(String pickupId, String status, {double? weight, String? wasteType}) async {
    try {
      final response = await http.patch(
        Uri.parse('${ApiConstants.pickups}$pickupId/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_authService.token}'
        },
        body: jsonEncode({
          'status': status,
          if (weight != null) 'weight_kg': weight.toString(),
          if (wasteType != null) 'waste_type': wasteType,
        }),
      );
      if (response.statusCode == 200) {
        await fetchAssignedPickups();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error updating pickup: $e');
      return false;
    }
  }
}
