import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/pickup.dart';

class PickupService extends ChangeNotifier {
  final List<Pickup> _pickups = [];
  List<Pickup> get pickups => List.unmodifiable(_pickups);

  // Mock data for demonstration
  void _initializeMockData() {
    if (_pickups.isNotEmpty) return;

    final now = DateTime.now();
    final mockPickups = [
      Pickup(
        id: '1',
        userId: 'user1',
        userName: 'John Doe',
        userPhone: '+91 9876543210',
        address: '123 Green Street, Ward 15',
        wardNumber: '15',
        type: PickupType.regular,
        status: PickupStatus.scheduled,
        scheduledDate: now.add(const Duration(days: 1)),
        scheduledTime: const TimeOfDay(hour: 8, minute: 0),
        notes: 'Please ring the doorbell',
        createdAt: now.subtract(const Duration(days: 2)),
        wasteTypes: [WasteType.dry, WasteType.wet],
        estimatedDuration: 30,
      ),
      Pickup(
        id: '2',
        userId: 'user1',
        userName: 'John Doe',
        userPhone: '+91 9876543210',
        address: '123 Green Street, Ward 15',
        wardNumber: '15',
        type: PickupType.emergency,
        status: PickupStatus.completed,
        scheduledDate: now.subtract(const Duration(days: 3)),
        scheduledTime: const TimeOfDay(hour: 10, minute: 0),
        assignedWorkerId: 'worker1',
        assignedWorkerName: 'HKS Worker',
        completedAt: now.subtract(const Duration(days: 3, hours: 1)),
        createdAt: now.subtract(const Duration(days: 5)),
        weight: 5.2,
        wasteTypes: [WasteType.dry, WasteType.organic],
        estimatedDuration: 25,
      ),
      Pickup(
        id: '3',
        userId: 'user2',
        userName: 'Jane Smith',
        userPhone: '+91 8765432109',
        address: '456 Eco Avenue, Ward 15',
        wardNumber: '15',
        type: PickupType.bulk,
        status: PickupStatus.inProgress,
        scheduledDate: now,
        scheduledTime: const TimeOfDay(hour: 14, minute: 0),
        assignedWorkerId: 'worker2',
        assignedWorkerName: 'HKS Worker 2',
        createdAt: now.subtract(const Duration(days: 1)),
        wasteTypes: [WasteType.electronic, WasteType.dry],
        estimatedDuration: 60,
      ),
    ];

    _pickups.addAll(mockPickups);
  }

  PickupService() {
    _initializeMockData();
  }

  // Get pickups for a specific user
  List<Pickup> getPickupsForUser(String userId) {
    return _pickups.where((pickup) => pickup.userId == userId).toList();
  }

  // Get upcoming pickups for a user
  List<Pickup> getUpcomingPickupsForUser(String userId) {
    final now = DateTime.now();
    return _pickups
        .where((pickup) => 
            pickup.userId == userId && 
            pickup.scheduledDate.isAfter(now) &&
            pickup.status == PickupStatus.scheduled)
        .toList()
      ..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
  }

  // Get pickups assigned to a worker
  List<Pickup> getPickupsForWorker(String workerId) {
    return _pickups.where((pickup) => pickup.assignedWorkerId == workerId).toList();
  }

  // Get today's pickups for a worker
  List<Pickup> getTodaysPickupsForWorker(String workerId) {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _pickups
        .where((pickup) => 
            pickup.assignedWorkerId == workerId &&
            pickup.scheduledDate.isAfter(startOfDay) &&
            pickup.scheduledDate.isBefore(endOfDay))
        .toList()
      ..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
  }

  // Get all pickups for admin dashboard
  List<Pickup> getAllPickups() {
    return List.from(_pickups);
  }

  // Create a new pickup
  Future<bool> createPickup(Pickup pickup) async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 500));
    
    _pickups.add(pickup);
    notifyListeners();
    return true;
  }

  // Update pickup status
  Future<bool> updatePickupStatus(String pickupId, PickupStatus status, {String? workerId, String? workerName}) async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _pickups.indexWhere((pickup) => pickup.id == pickupId);
    if (index != -1) {
      final updatedPickup = _pickups[index].copyWith(
        status: status,
        updatedAt: DateTime.now(),
        assignedWorkerId: workerId,
        assignedWorkerName: workerName,
        completedAt: status == PickupStatus.completed ? DateTime.now() : null,
      );
      
      _pickups[index] = updatedPickup;
      notifyListeners();
      return true;
    }
    return false;
  }

  // Assign worker to pickup
  Future<bool> assignWorker(String pickupId, String workerId, String workerName) async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _pickups.indexWhere((pickup) => pickup.id == pickupId);
    if (index != -1) {
      _pickups[index] = _pickups[index].copyWith(
        assignedWorkerId: workerId,
        assignedWorkerName: workerName,
        updatedAt: DateTime.now(),
      );
      notifyListeners();
      return true;
    }
    return false;
  }

  // Cancel pickup
  Future<bool> cancelPickup(String pickupId) async {
    return updatePickupStatus(pickupId, PickupStatus.cancelled);
  }

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
      'monthly': monthlyPickups.length,
    };
  }

  // Get waste type statistics
  Map<WasteType, int> getWasteTypeStatistics() {
    final stats = <WasteType, int>{};
    
    for (final pickup in _pickups) {
      for (final wasteType in pickup.wasteTypes) {
        stats[wasteType] = (stats[wasteType] ?? 0) + 1;
      }
    }
    
    return stats;
  }

  // Generate pickup ID
  String generatePickupId() {
    return 'pickup_${DateTime.now().millisecondsSinceEpoch}';
  }
}
