import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../utils/api_constants.dart';
import 'auth_service.dart';

class ReferralService extends ChangeNotifier {
  final AuthService _authService;
  String _referralCode = "";
  int _referralCount = 0;
  double _totalEarned = 0.0;
  List<ReferralHistory> _history = [];
  bool _isLoading = false;

  ReferralService(this._authService);

  String get referralCode => _referralCode;
  int get referralCount => _referralCount;
  double get totalEarned => _totalEarned;
  bool get isLoading => _isLoading;

  List<ReferralHistory> getReferralHistory() {
    return _history;
  }

  Future<void> fetchReferrals() async {
    if (!_authService.isAuthenticated) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse(ApiConstants.referrals),
        headers: {'Authorization': 'Bearer ${_authService.token}'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _referralCode = data['code'] ?? "";
        _referralCount = data['count'] ?? 0;
        _totalEarned = (data['total_earned'] as num?)?.toDouble() ?? 0.0;

        if (data['history'] != null) {
          _history = (data['history'] as List).map((r) => ReferralHistory(
                name: r['name'] ?? '',
                date: r['date'] ?? '',
                amount: (r['amount'] as num?)?.toDouble() ?? 0.0,
                status: r['status'] ?? 'Pending',
              )).toList();
        }
      }
    } catch (e) {
      debugPrint('Error fetching referrals: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> shareReferral() async {
    // In a real app, this would use the share_plus package to share _referralCode
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> applyReferralCode(String code) async {
    if (!_authService.isAuthenticated) return false;

    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.referrals}apply/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_authService.token}'
        },
        body: jsonEncode({'code': code}),
      );
      if (response.statusCode == 200) {
        await fetchReferrals();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error applying referral: $e');
      return false;
    }
  }
}

class ReferralHistory {
  final String name;
  final String date;
  final double amount;
  final String status;

  ReferralHistory({
    required this.name,
    required this.date,
    required this.amount,
    required this.status,
  });
}
