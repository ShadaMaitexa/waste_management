import 'package:flutter/material.dart';
import '../models/user.dart';
export '../models/user.dart';

class AuthService extends ChangeNotifier {
  UserType? _currentUserType;
  String? _currentUserName;
  String? _currentUserEmail;
  bool _isAuthenticated = false;

  UserType? get currentUserType => _currentUserType;
  String? get currentUserName => _currentUserName;
  String? get currentUserEmail => _currentUserEmail;
  bool get isAuthenticated => _isAuthenticated;

  // Hardcoded Admin Credentials
  static const String adminEmail = 'admin@greenloop.com';
  static const String adminPassword = 'admin123';

  // Mock login method
  Future<bool> login(String email, String password, UserType userType) async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Admin check
    if (userType == UserType.admin) {
      if (email == adminEmail && password == adminPassword) {
        _currentUserType = userType;
        _currentUserName = 'Super Admin';
        _currentUserEmail = email;
        _isAuthenticated = true;
        notifyListeners();
        return true;
      }
      return false;
    }

    // Mock authentication logic for others
    if (email.isNotEmpty && password.isNotEmpty) {
      _currentUserType = userType;
      _currentUserName = _getMockUserName(userType);
      _currentUserEmail = email;
      _isAuthenticated = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  // Mock Registration method (mainly for residents)
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String phoneNumber,
    required String address,
    required UserType userType,
  }) async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1.5));
    
    // In a real app, you would save this to a database
    _currentUserType = userType;
    _currentUserName = name;
    _currentUserEmail = email;
    _isAuthenticated = true;
    notifyListeners();
    return true;
  }

  // Mock Forgot Password method
  Future<bool> forgotPassword(String email) async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Just return true if email is not empty
    return email.isNotEmpty;
  }

  void logout() {
    _currentUserType = null;
    _currentUserName = null;
    _currentUserEmail = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  String _getMockUserName(UserType userType) {
    switch (userType) {
      case UserType.resident:
        return 'John Doe';
      case UserType.worker:
        return 'HKS Worker';
      case UserType.admin:
        return 'ULB Admin';
      case UserType.recycler:
        return 'Recycling Partner';
    }
  }
}

