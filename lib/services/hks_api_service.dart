import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../utils/api_constants.dart';
import 'auth_service.dart';

class HksApiService extends ChangeNotifier {
  final AuthService _authService;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  HksApiService(this._authService);

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ${_authService.token ?? ''}',
  };

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  // --- ATTENDANCE & DAILY TRACKING ---

  Future<bool> checkIn(double latitude, double longitude) async {
    _setLoading(true);
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.hksAttendance),
        headers: _headers,
        body: jsonEncode({
          'action': 'check_in',
          'latitude': latitude,
          'longitude': longitude,
          'ppe_verified': true,
        }),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('CheckIn Error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> checkOut(double latitude, double longitude) async {
    _setLoading(true);
    try {
      final response = await http.patch(
        Uri.parse(ApiConstants.hksAttendance),
        headers: _headers,
        body: jsonEncode({
          'action': 'check_out',
          'latitude': latitude,
          'longitude': longitude,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('CheckOut Error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<List<dynamic>> getAttendanceHistory() async {
    _setLoading(true);
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.hksAttendance),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      debugPrint('GetAttendanceHistory Error: $e');
      return [];
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>?> getActiveRoute() async {
    _setLoading(true);
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.hksActiveRoute),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('GetActiveRoute Error: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // --- WASTE PICKUP & VERIFICATION ---

  Future<List<dynamic>> getPickups() async {
    _setLoading(true);
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.hksPickups),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      debugPrint('GetPickups Error: $e');
      return [];
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> forceCreatePickup(Map<String, dynamic> data) async {
    _setLoading(true);
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.hksPickups),
        headers: _headers,
        body: jsonEncode(data),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('ForceCreatePickup Error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> completePickup(String id, Map<String, dynamic> data) async {
    _setLoading(true);
    try {
      final response = await http.patch(
        Uri.parse(ApiConstants.hksPickupComplete(id)),
        headers: _headers,
        body: jsonEncode(data),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('CompletePickup Error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> cancelPickup(String id, String reason) async {
    _setLoading(true);
    try {
      final response = await http.patch(
        Uri.parse(ApiConstants.hksPickupCancel(id)),
        headers: _headers,
        body: jsonEncode({'reason': reason}),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('CancelPickup Error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> verifyPickupScan(String id, String qrData) async {
    _setLoading(true);
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.hksPickupVerify(id)),
        headers: _headers,
        body: jsonEncode({'qr_code': qrData}),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('VerifyPickupScan Error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // --- COMPLAINTS & ISSUE REPORTING ---

  Future<List<dynamic>> getComplaints() async {
    _setLoading(true);
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.hksComplaints),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      debugPrint('GetComplaints Error: $e');
      return [];
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> selfReportComplaint(Map<String, dynamic> data) async {
    _setLoading(true);
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.hksComplaints),
        headers: _headers,
        body: jsonEncode(data),
      );
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      debugPrint('SelfReport Complaint Error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> resolveComplaint(String id, String status) async {
    _setLoading(true);
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.hksComplaintResolve(id)),
        headers: _headers,
        body: jsonEncode({'status': status}),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Resolve Complaint Error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // --- PAYMENTS & FEE COLLECTION ---

  Future<bool> recordPayment(Map<String, dynamic> data) async {
    _setLoading(true);
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.hksPayments),
        headers: _headers,
        body: jsonEncode(data),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('RecordPayment Error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> correctPaymentEntry(String id, Map<String, dynamic> data) async {
    _setLoading(true);
    try {
      final response = await http.patch(
        Uri.parse(ApiConstants.hksPaymentCorrect(id)),
        headers: _headers,
        body: jsonEncode(data),
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint('CorrectPaymentEntry Error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<List<dynamic>> getPaymentHistory() async {
    _setLoading(true);
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.hksPayments),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      debugPrint('GetPaymentHistory Error: $e');
      return [];
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>?> getPaymentSummary() async {
    _setLoading(true);
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.hksPaymentsSummary),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('GetPaymentSummary Error: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }
}
