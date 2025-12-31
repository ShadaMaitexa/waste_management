import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/pickup.dart';

class AdminService extends ChangeNotifier {
  // Mock data storage
  final List<User> _users = [];
  final List<Pickup> _pickups = [];
  final Map<String, dynamic> _systemStats = {};
  
  // Getters
  List<User> get allUsers => List.unmodifiable(_users);
  List<Pickup> get allPickups => List.unmodifiable(_pickups);
  Map<String, dynamic> get systemStats => Map.unmodifiable(_systemStats);

  // Initialize mock data
  void _initializeMockData() {
    if (_users.isNotEmpty) return;

    // Mock users
    _users.addAll([
      User(
        id: 'user1',
        email: 'john.doe@email.com',
        name: 'John Doe',
        userType: UserType.resident,
        phoneNumber: '+91 9876543210',
        address: '123 Green Street, Ward 15',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        wardNumber: '15',
      ),
      User(
        id: 'admin1',
        email: 'admin@kozhikode.gov',
        name: 'ULB Admin',
        userType: UserType.admin,
        phoneNumber: '+91 9876543211',
        address: 'Kozhikode Municipal Corporation',
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
        department: 'Waste Management',
      ),
    ]);

    // Mock system stats
    _systemStats.addAll({
      'totalUsers': 1247,
      'activeUsers': 1156,
      'totalPickups': 2456,
      'collectionRate': 94.5,
      'complaintsCount': 12,
      'revenue': 125000,
    });
  }

  AdminService() {
    _initializeMockData();
  }

  // ==================== USER MANAGEMENT ====================

  // Get all users with optional filters
  List<User> getUsers({UserType? userType, bool? isActive, String? search}) {
    var filteredUsers = List<User>.from(_users);

    if (userType != null) {
      filteredUsers = filteredUsers.where((user) => user.userType == userType).toList();
    }

    if (isActive != null) {
      filteredUsers = filteredUsers.where((user) => user.isActive == isActive).toList();
    }

    if (search != null && search.isNotEmpty) {
      final searchLower = search.toLowerCase();
      filteredUsers = filteredUsers.where((user) =>
          user.name.toLowerCase().contains(searchLower) ||
          user.email.toLowerCase().contains(searchLower)).toList();
    }

    return filteredUsers;
  }

  // Get user statistics
  Map<String, int> getUserStatistics() {
    return {
      'total': _users.length,
      'residents': _users.where((u) => u.userType == UserType.resident).length,
      'workers': _users.where((u) => u.userType == UserType.worker).length,
      'recyclers': _users.where((u) => u.userType == UserType.recycler).length,
      'admins': _users.where((u) => u.userType == UserType.admin).length,
      'active': _users.where((u) => u.isActive).length,
      'inactive': _users.where((u) => !u.isActive).length,
    };
  }

  // Create new user
  Future<bool> createUser(User user) async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 500));

    // Check if user already exists
    if (_users.any((u) => u.email == user.email)) {
      return false;
    }

    _users.add(user);
    notifyListeners();
    return true;
  }

  // Update user
  Future<bool> updateUser(String userId, User updatedUser) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _users.indexWhere((user) => user.id == userId);
    if (index == -1) return false;

    _users[index] = updatedUser;
    notifyListeners();
    return true;
  }

  // Deactivate user
  Future<bool> deactivateUser(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _users.indexWhere((user) => user.id == userId);
    if (index == -1) return false;

    _users[index] = _users[index].copyWith(isActive: false);
    notifyListeners();
    return true;
  }

  // Activate user
  Future<bool> activateUser(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _users.indexWhere((user) => user.id == userId);
    if (index == -1) return false;

    _users[index] = _users[index].copyWith(isActive: true);
    notifyListeners();
    return true;
  }

  // Delete user
  Future<bool> deleteUser(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _users.indexWhere((user) => user.id == userId);
    if (index == -1) return false;

    _users.removeAt(index);
    notifyListeners();
    return true;
  }

  // ==================== PICKUP MANAGEMENT ====================

  // Get pickup statistics
  Map<String, int> getPickupStatistics() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 1);

    final monthlyPickups = _pickups.where((pickup) {
      return pickup.scheduledDate.isAfter(startOfMonth) && 
             pickup.scheduledDate.isBefore(endOfMonth);
    }).toList();

    return {
      'total': _pickups.length,
      'scheduled': _pickups.where((p) => p.status == PickupStatus.scheduled).length,
      'completed': _pickups.where((p) => p.status == PickupStatus.completed).length,
      'cancelled': _pickups.where((p) => p.status == PickupStatus.cancelled).length,
      'inProgress': _pickups.where((p) => p.status == PickupStatus.inProgress).length,
      'thisMonth': monthlyPickups.length,
    };
  }

  // Get pickup trends (mock data for charts)
  List<Map<String, dynamic>> getPickupTrends(int days) {
    final trends = <Map<String, dynamic>>[];
    final now = DateTime.now();

    for (int i = days - 1; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final count = (date.weekday == 6 || date.weekday == 7) ? 
          (15 + (i % 5)) : (25 + (i % 10)); // Weekend vs weekday pattern
      
      trends.add({
        'date': date,
        'pickups': count,
        'completed': (count * 0.95).round(),
        'cancelled': (count * 0.05).round(),
      });
    }

    return trends;
  }

  // Assign worker to pickup
  Future<bool> assignWorker(String pickupId, String workerId, String workerName) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _pickups.indexWhere((pickup) => pickup.id == pickupId);
    if (index == -1) return false;

    _pickups[index] = _pickups[index].copyWith(
      assignedWorkerId: workerId,
      assignedWorkerName: workerName,
      updatedAt: DateTime.now(),
    );
    notifyListeners();
    return true;
  }

  // Cancel pickup
  Future<bool> cancelPickup(String pickupId, {String? reason}) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _pickups.indexWhere((pickup) => pickup.id == pickupId);
    if (index == -1) return false;

    _pickups[index] = _pickups[index].copyWith(
      status: PickupStatus.cancelled,
      updatedAt: DateTime.now(),
    );
    notifyListeners();
    return true;
  }

  // ==================== SYSTEM ANALYTICS ====================

  // Get ward-wise performance
  List<Map<String, dynamic>> getWardPerformance() {
    return [
      {
        'ward': '15',
        'collectionRate': 98.0,
        'totalPickups': 450,
        'complaints': 2,
        'performance': 'Excellent',
      },
      {
        'ward': '12',
        'collectionRate': 94.0,
        'totalPickups': 380,
        'complaints': 3,
        'performance': 'Good',
      },
      {
        'ward': '8',
        'collectionRate': 89.0,
        'totalPickups': 320,
        'complaints': 4,
        'performance': 'Average',
      },
      {
        'ward': '5',
        'collectionRate': 85.0,
        'totalPickups': 290,
        'complaints': 6,
        'performance': 'Needs Improvement',
      },
    ];
  }

  // Get waste type distribution
  Map<WasteType, int> getWasteTypeDistribution() {
    final stats = <WasteType, int>{};
    
    for (final pickup in _pickups) {
      for (final wasteType in pickup.wasteTypes) {
        stats[wasteType] = (stats[wasteType] ?? 0) + 1;
      }
    }
    
    return stats;
  }

  // Get revenue analytics
  Map<String, dynamic> getRevenueAnalytics() {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    final lastMonth = DateTime(now.year, now.month - 1);

    // Mock revenue data
    return {
      'currentMonth': 125000.0,
      'lastMonth': 118000.0,
      'growth': 5.9,
      'projected': 132000.0,
      'byServiceType': {
        'regular': 85000.0,
        'emergency': 25000.0,
        'bulk': 15000.0,
      },
    };
  }

  // Get alerts and notifications
  List<Map<String, dynamic>> getSystemAlerts() {
    return [
      {
        'id': 'alert1',
        'type': 'info',
        'title': 'High collection volume in Ward 12',
        'message': 'Collection volume 25% above normal',
        'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
        'severity': 'medium',
        'ward': '12',
      },
      {
        'id': 'alert2',
        'type': 'warning',
        'title': 'Worker attendance low in Ward 5',
        'message': 'Only 60% attendance rate today',
        'timestamp': DateTime.now().subtract(const Duration(hours: 4)),
        'severity': 'high',
        'ward': '5',
      },
      {
        'id': 'alert3',
        'type': 'success',
        'title': 'New recycler partnership approved',
        'message': 'GreenTech Recycling partnered for e-waste',
        'timestamp': DateTime.now().subtract(const Duration(days: 1)),
        'severity': 'low',
        'ward': null,
      },
    ];
  }

  // ==================== SYSTEM OPERATIONS ====================

  // Generate system report
  Future<Map<String, dynamic>> generateSystemReport({String? period}) async {
    await Future.delayed(const Duration(seconds: 2)); // Simulate report generation

    return {
      'generatedAt': DateTime.now(),
      'period': period ?? 'current',
      'userStats': getUserStatistics(),
      'pickupStats': getPickupStatistics(),
      'wardPerformance': getWardPerformance(),
      'revenueAnalytics': getRevenueAnalytics(),
      'wasteDistribution': getWasteTypeDistribution(),
      'alertsCount': getSystemAlerts().length,
    };
  }

  // Send notification to users
  Future<bool> sendNotification(List<String> userIds, String title, String message) async {
    await Future.delayed(const Duration(milliseconds: 500));

    // Mock notification sending
    print('Sending notification to ${userIds.length} users: $title - $message');
    notifyListeners();
    return true;
  }

  // Update system configuration
  Future<bool> updateSystemConfig(String key, dynamic value) async {
    await Future.delayed(const Duration(milliseconds: 300));

    _systemStats[key] = value;
    notifyListeners();
    return true;
  }

  // ==================== SEARCH AND FILTER ====================

  // Search users
  List<User> searchUsers(String query) {
    if (query.isEmpty) return _users;

    final searchLower = query.toLowerCase();
    return _users.where((user) =>
        user.name.toLowerCase().contains(searchLower) ||
        user.email.toLowerCase().contains(searchLower) ||
        (user.phoneNumber?.contains(query) ?? false)).toList();
  }

  // Filter pickups by date range
  List<Pickup> filterPickupsByDateRange(DateTime start, DateTime end) {
    return _pickups.where((pickup) =>
        pickup.scheduledDate.isAfter(start) &&
        pickup.scheduledDate.isBefore(end)).toList();
  }

  // ==================== DATA EXPORT ====================

  // Export data (mock implementation)
  Future<String> exportData(String type, {DateTime? startDate, DateTime? endDate}) async {
    await Future.delayed(const Duration(seconds: 3)); // Simulate export

    switch (type.toLowerCase()) {
      case 'users':
        return 'users_${DateTime.now().millisecondsSinceEpoch}.csv';
      case 'pickups':
        return 'pickups_${DateTime.now().millisecondsSinceEpoch}.csv';
      case 'reports':
        return 'system_report_${DateTime.now().millisecondsSinceEpoch}.pdf';
      default:
        throw Exception('Invalid export type');
    }
  }
}
