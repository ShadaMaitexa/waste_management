import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/notification.dart';
import '../utils/api_constants.dart';
import 'auth_service.dart';

class NotificationService extends ChangeNotifier {
  final AuthService _authService;
  List<AppNotification> _notifications = [];
  bool _isLoading = false;

  NotificationService(this._authService);

  List<AppNotification> get notifications => List.unmodifiable(_notifications);
  bool get isLoading => _isLoading;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> fetchNotifications() async {
    if (!_authService.isAuthenticated) return;

    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse(ApiConstants.notifications),
        headers: {'Authorization': 'Bearer ${_authService.token}'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _notifications = data.map((json) => AppNotification.fromJson(json)).toList();
        // Sort by date descending
        _notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> markAsRead(String notificationId) async {
    try {
      final response = await http.patch(
        Uri.parse('${ApiConstants.notifications}$notificationId/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_authService.token}',
        },
        body: jsonEncode({'is_read': true}),
      );

      if (response.statusCode == 200) {
        final index = _notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          final old = _notifications[index];
          _notifications[index] = AppNotification(
            id: old.id,
            title: old.title,
            message: old.message,
            createdAt: old.createdAt,
            isRead: true,
          );
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> markAllAsRead() async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.notifications}mark-all-read/'),
        headers: {'Authorization': 'Bearer ${_authService.token}'},
      );

      if (response.statusCode == 200) {
        _notifications = _notifications.map((n) => AppNotification(
          id: n.id,
          title: n.title,
          message: n.message,
          createdAt: n.createdAt,
          isRead: true,
        )).toList();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
