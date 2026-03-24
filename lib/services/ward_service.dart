import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/ward.dart';
import '../utils/api_constants.dart';
import 'auth_service.dart';

class WardService extends ChangeNotifier {
  final AuthService _authService;
  List<Ward> _wards = [];
  bool _isLoading = false;

  WardService(this._authService);

  List<Ward> get wards => List.unmodifiable(_wards);
  bool get isLoading => _isLoading;

  Future<void> fetchWards() async {
    if (_wards.isNotEmpty) return; // Cache for session
    
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse(ApiConstants.wards),
        headers: {
          if (_authService.isAuthenticated) 'Authorization': 'Bearer ${_authService.token}',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _wards = data.map((json) => Ward.fromJson(json)).toList();
      } else {
        // Mock data for Kozhikode wards if API is unavailable
        _wards = [
          Ward(id: 1, nameEn: 'Koyilandy', nameMl: 'കൊയിലാണ്ടി', wardNumber: '15'),
          Ward(id: 2, nameEn: 'Beypore', nameMl: 'ബേപ്പൂർ', wardNumber: '42'),
          Ward(id: 3, nameEn: 'Vatakara', nameMl: 'വടകര', wardNumber: '18'),
          Ward(id: 4, nameEn: 'Kozhikode South', nameMl: 'കോഴിക്കോട് സൗത്ത്', wardNumber: '05'),
          Ward(id: 5, nameEn: 'Kozhikode North', nameMl: 'കോഴിക്കോട് നോർത്ത്', wardNumber: '10'),
          Ward(id: 6, nameEn: 'Feroke', nameMl: 'ഫറോക്ക്', wardNumber: '33'),
        ];
      }
    } catch (e) {
      debugPrint('Error fetching wards: $e');
      // Final fallback to avoid empty dropdown
       _wards = [
          Ward(id: 1, nameEn: 'Koyilandy', nameMl: 'കൊയിലാണ്ടി', wardNumber: '15'),
          Ward(id: 2, nameEn: 'Beypore', nameMl: 'ബേപ്പൂർ', wardNumber: '42'),
        ];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Ward? getWardById(int id) {
    try {
      return _wards.firstWhere((w) => w.id == id);
    } catch (_) {
      return null;
    }
  }
}
