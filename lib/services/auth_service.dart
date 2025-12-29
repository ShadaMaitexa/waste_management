import 'package:flutter/material.dart';

enum UserType { resident, worker, admin, recycler }

class AuthService extends ChangeNotifier {
  UserType? _currentUserType;
  String? _currentUserName;
  String? _currentUserEmail;
  bool _isAuthenticated = false;

  UserType? get currentUserType => _currentUserType;
  String? get currentUserName => _currentUserName;
  String? get currentUserEmail => _currentUserEmail;
  bool get isAuthenticated => _isAuthenticated;

  // Mock login method - will be replaced with actual API integration
  Future<bool> login(String email, String password, UserType userType) async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock authentication logic
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
