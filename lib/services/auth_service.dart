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

  Future<bool> login(String email, String password, UserType userType) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse(ApiConstants.login),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      _isLoading = false;
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _saveToken(data['access'] ?? data['token']);
        await getProfile();
        return true;
      }
      notifyListeners();
      return false;
    } catch (e) {
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
    required UserType userType,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse(ApiConstants.register),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'phoneNumber': phoneNumber,
          'address': address,
          'userType': userType.toString().split('.').last,
        }),
      );

      _isLoading = false;
      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _saveToken(data['access'] ?? data['token']);
        await getProfile();
        return true;
      }
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
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
      debugPrint('Error fetching profile: $e');
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

  Future<void> logout() async {
    await _clearToken();
  }
}

