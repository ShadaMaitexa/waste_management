import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/pickup.dart';
import '../../models/user.dart';
import '../../services/admin_service.dart';
import '../../theme/app_theme.dart';

class AdminBookingsScreen extends StatefulWidget {
  const AdminBookingsScreen({super.key});

  @override
  State<AdminBookingsScreen> createState() => _AdminBookingsScreenState();
}

class _AdminBookingsScreenState extends State<AdminBookingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminService>().fetchAllBookings();
      context.read<AdminService>().fetchUsers(); // To get workers for assignment
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.grey50,
      appBar: AppBar(
        title: const Text(
          'Waste Pickups & Assignments',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: -0.5),
        ),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<AdminService>(
        builder: (context, adminService, child) {
          if (adminService.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final pickups = adminService.allPickups;

          if (pickups.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.local_shipping_outlined, size: 64, color: AppTheme.grey300),
                  const SizedBox(height: 16),
                  const Text(
                    'No active bookings',
                    style: TextStyle(color: AppTheme.grey500, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await adminService.fetchAllBookings();
              await adminService.fetchUsers();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: pickups.length,
              itemBuilder: (context, index) {
                final pickup = pickups[index];
                return _buildPickupCard(pickup, adminService);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildPickupCard(Pickup pickup, AdminService adminService) {
    final statusColor = _getStatusColor(pickup.status);
    final workers = adminService.allUsers.where((u) => u.userType == UserType.worker).toList();
    
    // Find assigned worker name if exists
    String? assignedWorkerName = pickup.assignedWorkerName;
    if (assignedWorkerName == null && pickup.assignedWorkerId != null) {
      final worker = workers.firstWhere(
        (w) => w.id == pickup.assignedWorkerId,
        orElse: () => User(id: '', name: 'Unknown Worker', email: '', phoneNumber: '', userType: UserType.worker, createdAt: DateTime.now(), address: 'N/A')
      );
      assignedWorkerName = worker.name;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    pickup.status.name.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  '#${pickup.id.substring(pickup.id.length - 6).toUpperCase()}',
                  style: TextStyle(color: AppTheme.grey400, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.warning.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.delete_sweep_rounded, color: AppTheme.warning),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (pickup.specialInstructions ?? "WASTE COLLECTION").toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                      ),
                      Text(
                        'Scheduled for: ${DateFormat('MMM d, h:mm a').format(pickup.scheduledDate)}',
                        style: TextStyle(color: AppTheme.grey600, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.location_on_rounded, size: 16, color: AppTheme.primaryGreen),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    pickup.address,
                    style: TextStyle(color: AppTheme.grey700, fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (assignedWorkerName != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 12,
                      backgroundColor: AppTheme.primaryGreen,
                      child: Icon(Icons.person, size: 14, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Assigned to: ',
                      style: TextStyle(color: AppTheme.grey600, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      assignedWorkerName,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.grey900),
                    ),
                  ],
                ),
              )
            else
              TextButton.icon(
                onPressed: () => _showAssignWorkerDialog(pickup, workers),
                icon: const Icon(Icons.person_add_rounded, size: 18),
                label: const Text('ASSIGN COLLECTION WORKER'),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.primaryGreen,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  backgroundColor: AppTheme.primaryGreen.withOpacity(0.1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(PickupStatus status) {
    switch (status) {
      case PickupStatus.scheduled:
        return AppTheme.warning;
      case PickupStatus.inProgress:
        return AppTheme.info;
      case PickupStatus.completed:
        return AppTheme.success;
      case PickupStatus.cancelled:
        return AppTheme.error;
      case PickupStatus.failed:
        return AppTheme.error;
    }
  }

  void _showAssignWorkerDialog(Pickup pickup, List<User> workers) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Collection Worker',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: workers.length,
                itemBuilder: (context, index) {
                  final worker = workers[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primaryGreen.withOpacity(0.1),
                      child: Text(worker.name[0], style: const TextStyle(color: AppTheme.primaryGreen)),
                    ),
                    title: Text(worker.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Ward: ${worker.wardNumber ?? "N/A"}'),
                    onTap: () async {
                      Navigator.pop(context);
                      final success = await context.read<AdminService>().assignWorkerToBooking(pickup.id, worker.id);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(success ? 'Worker assigned successfully' : 'Assignment failed'),
                            backgroundColor: success ? AppTheme.success : AppTheme.error,
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
