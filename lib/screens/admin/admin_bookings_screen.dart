import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/admin_service.dart';
import '../../models/pickup.dart';
import '../../models/user.dart';
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
      final adminService = context.read<AdminService>();
      adminService.fetchAllBookings();
      adminService.fetchUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminService>(
      builder: (context, adminService, child) {
        final pickups = adminService.pickups;

        return Scaffold(
          backgroundColor: AppTheme.grey50,
          appBar: AppBar(
            title: const Text('Dispatch Management'),
            actions: [
              IconButton(icon: const Icon(Icons.history_rounded), onPressed: () {}),
              const SizedBox(width: 8),
            ],
          ),
          body: adminService.isLoading
              ? const Center(child: CircularProgressIndicator())
              : pickups.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: pickups.length,
                      itemBuilder: (context, index) => _buildPickupCard(pickups[index], adminService),
                    ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
     return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.local_shipping_rounded, size: 64, color: AppTheme.grey200),
          const SizedBox(height: 16),
          const Text('No pending dispatches found.', 
            style: TextStyle(color: AppTheme.grey500, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildPickupCard(Pickup pickup, AdminService adminService) {
    final statusColor = _getStatusColor(pickup.status);
    final workers = adminService.allUsers.where((u) => u.userType == UserType.worker).toList();
    
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
        border: Border.all(color: AppTheme.grey100),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppTheme.grey50, borderRadius: BorderRadius.circular(16)),
                  child: const Icon(Icons.inventory_2_rounded, color: AppTheme.grey700),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (pickup.specialInstructions ?? "WASTE COLLECTION").toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: AppTheme.grey900, letterSpacing: -0.2),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        pickup.address,
                        style: const TextStyle(fontSize: 13, color: AppTheme.grey500, fontWeight: FontWeight.w500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                AppTheme.statusTag(pickup.status.name, statusColor),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: AppTheme.grey50.withValues(alpha: 0.5),
              border: const Border(top: BorderSide(color: AppTheme.grey100)),
            ),
            child: Row(
              children: [
                _buildInfoBit(Icons.calendar_today_rounded, DateFormat('MMM d, h:mm a').format(pickup.scheduledDate)),
                const Spacer(),
                _buildInfoBit(Icons.person_pin_circle_rounded, 'Ward ${pickup.wardNumber}'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (assignedWorkerName != null)
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(color: AppTheme.primaryEmerald.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, color: AppTheme.primaryEmerald, size: 16),
                          const SizedBox(width: 8),
                          Text(assignedWorkerName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppTheme.primaryEmerald)),
                        ],
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showAssignWorkerDialog(pickup, workers),
                      icon: const Icon(Icons.person_add_rounded, size: 18),
                      label: const Text('Assign Dispatcher'),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBit(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppTheme.grey400),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.grey600)),
      ],
    );
  }

  Color _getStatusColor(PickupStatus status) {
    switch (status) {
      case PickupStatus.scheduled: return AppTheme.warning;
      case PickupStatus.inProgress: return AppTheme.info;
      case PickupStatus.completed: return AppTheme.success;
      case PickupStatus.cancelled:
      case PickupStatus.failed: return AppTheme.error;
    }
  }

  void _showAssignWorkerDialog(Pickup pickup, List<User> workers) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Assign Field Dispatcher', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
            const Text('Select a worker to complete this collection unit.', style: TextStyle(color: AppTheme.grey400, fontSize: 14)),
            const SizedBox(height: 24),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.4),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: workers.length,
                itemBuilder: (context, index) {
                  final worker = workers[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(color: AppTheme.grey50, borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                      leading: CircleAvatar(backgroundColor: AppTheme.primaryEmerald.withValues(alpha: 0.1), 
                        child: Text(worker.name[0], style: const TextStyle(color: AppTheme.primaryEmerald, fontWeight: FontWeight.bold))),
                      title: Text(worker.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Text('Ward ${worker.wardNumber ?? "N/A"} • Active', style: const TextStyle(fontSize: 12)),
                      onTap: () async {
                        Navigator.pop(context);
                        final success = await context.read<AdminService>().assignWorkerToBooking(pickup.id, worker.id);
                        if (context.mounted && success) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dispatcher assigned successfully')));
                        }
                      },
                    ),
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
