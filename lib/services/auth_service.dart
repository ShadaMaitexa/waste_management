import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../utils/api_constants.dart';
export '../models/user.dart';

class AuthService extends ChangeNotifier {
  User? _currentUser;
  String? _token;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  UserType? get currentUserType => _currentUser?.userType;
  String? get currentUserName => _currentUser?.name;
  String? get currentUserEmail => _currentUser?.email;
  bool get isAuthenticated => _token != null;
  bool get isLoading => _isLoading;
  String? get token => _token;

  AuthService() {
    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    if (_token != null) {
      await getProfile();
    }
    notifyListeners();
  }

  Future<void> _saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    notifyListeners();
  }

  Future<void> _clearToken() async {
    _token = null;
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final payload = {
        'username': email.trim(), // Most Django backends use 'username' as the key even for email login
        'password': password,
      };

      debugPrint('[AuthService] Login payload: ${jsonEncode(payload)}');

      final response = await http.post(
        Uri.parse(ApiConstants.login),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      debugPrint('[AuthService] Login status: ${response.statusCode}');
      debugPrint('[AuthService] Login response body: ${response.body}');
      
      _isLoading = false;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        String? token;
        if (data['tokens'] != null) {
          token = data['tokens']['access'];
        }
        token ??= data['access'] ?? data['token'];

        if (token == null) {
          debugPrint('[AuthService] No token found in successful response');
          return false;
        }
        
        await _saveToken(token);

        try {
          // If response has user data, parse it
          _currentUser = User.fromJson(data);
          notifyListeners();
        } catch (e) {
          // Otherwise, fetch profile
          await getProfile();
        }

        return true;
      }
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint('[AuthService] Login exception: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String phoneNumber,
    required String address,
    String? ward,
    required UserType userType,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final finalWard = (ward != null && ward.isNotEmpty) ? ward : '15';
      
      final body = jsonEncode({
        'username': email.trim(),
        'email': email.trim(),
        'password': password,
        'name': name.trim(),
        'full_name': name.trim(),
        'phone': phoneNumber.trim(), // Backend requires exactly 'phone'
        'address': address.trim(),
        'ward': finalWard, // Backend requires exactly 'ward'
        'role': userType.toString().split('.').last,
      });

      debugPrint('[AuthService] Register payload: $body');

      final response = await http.post(
        Uri.parse(ApiConstants.register),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      _isLoading = false;
      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);

        String? token;
        if (data['tokens'] != null) {
          token = data['tokens']['access'];
        }
        token ??= data['access'] ?? data['token'];

        if (token != null) await _saveToken(token);

        try {
          _currentUser = User.fromJson(data);
          notifyListeners();
        } catch (e) {
          if (token != null) await getProfile();
        }

        return true;
      }

      if (response.statusCode >= 400 && response.statusCode < 500) {
        try {
          final errorData = jsonDecode(response.body) as Map<String, dynamic>;
          final errorMessages = <String>[];
          errorData.forEach((key, value) {
            String msg = value is List ? value.join(', ') : value.toString();
            errorMessages.add('$key: $msg');
          });
          if (errorMessages.isNotEmpty) {
            throw Exception(errorMessages.join('\n'));
          }
        } catch (e) {
          if (e is Exception && e.toString().contains('Exception:')) rethrow;
        }
      }

      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      if (e is Exception && e.toString().contains('Exception:')) {
        throw Exception(e.toString().replaceAll('Exception: ', ''));
      }
      return false;
    }
  }

  Future<void> getProfile() async {
    if (_token == null) return;

    try {
      final response = await http.get(
        Uri.parse(ApiConstants.profile),
        headers: {
          'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        _currentUser = User.fromJson(jsonDecode(response.body));
        notifyListeners();
      } else if (response.statusCode == 401) {
        await _clearToken();
      }
    } catch (e) {
      debugPrint('[AuthService] Error fetching profile: $e');
    }
  }

  Future<bool> updateProfile({String? name, String? phone, String? address, String? ward}) async {
    if (_token == null) return false;

    try {
      final response = await http.patch(
        Uri.parse(ApiConstants.profile),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({
          if (name != null) 'username': name,
          if (name != null) 'full_name': name,
          if (phone != null) 'phone_number': phone,
          if (address != null) 'address': address,
          if (ward != null) 'ward_number': ward,
        }),
      );

      if (response.statusCode == 200) {
        _currentUser = User.fromJson(jsonDecode(response.body));
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('[AuthService] Error updating profile: $e');
      return false;
    }
  }

  Future<bool> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.forgotPassword),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> resetPassword(String uid, String token, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.resetPassword}$uid/$token/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'new_password': newPassword}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    await _clearToken();
  }
}
