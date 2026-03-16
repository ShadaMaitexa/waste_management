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
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(80),
            child: Container(
              padding: const EdgeInsets.only(top: 10),
              decoration: const BoxDecoration(
                gradient: AppTheme.slateGradient,
              ),
              child: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                scrolledUnderElevation: 0,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Dispatch Control',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                        color: Colors.white,
                        letterSpacing: -0.8,
                      ),
                    ),
                    Text(
                      'Logistics and field assignment management',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                foregroundColor: Colors.white,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.history_rounded, color: Colors.white70),
                    onPressed: () {},
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),
          body: adminService.isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: () => adminService.fetchAllBookings(),
                  color: AppTheme.primaryEmerald,
                  child: pickups.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                          physics: const BouncingScrollPhysics(),
                          itemCount: pickups.length,
                          itemBuilder: (context, index) => _buildPickupCard(pickups[index], adminService),
                        ),
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
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppTheme.grey100,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.local_shipping_rounded, size: 64, color: AppTheme.grey300),
          ),
          const SizedBox(height: 24),
          const Text('All Dispatched', 
            style: TextStyle(color: AppTheme.grey900, fontWeight: FontWeight.w900, fontSize: 20)),
          const SizedBox(height: 8),
          const Text('No pending collection units requiring assignment.', 
            style: TextStyle(color: AppTheme.grey400, fontSize: 14)),
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
        orElse: () => User(id: '', name: 'Inactive Resource', email: '', phoneNumber: '', userType: UserType.worker, createdAt: DateTime.now(), address: 'N/A')
      );
      assignedWorkerName = worker.name;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
        border: Border.all(color: statusColor.withValues(alpha: 0.15), width: 1.5),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(Icons.inventory_2_rounded, color: statusColor, size: 24),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (pickup.specialInstructions ?? "STANDARD COLLECTION").toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: AppTheme.grey900, letterSpacing: 0.5),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        pickup.address,
                        style: const TextStyle(fontSize: 14, color: AppTheme.grey500, fontWeight: FontWeight.w500, height: 1.4),
                        maxLines: 2,
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
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              color: AppTheme.grey50.withValues(alpha: 0.5),
              border: const Border(top: BorderSide(color: AppTheme.grey100)),
            ),
            child: Row(
              children: [
                _buildInfoBit(Icons.calendar_today_rounded, DateFormat('MMM d, h:mm a').format(pickup.scheduledDate)),
                const SizedBox(width: 24),
                _buildInfoBit(Icons.location_on_rounded, 'Ward ${pickup.wardNumber}'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                if (assignedWorkerName != null)
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryEmerald.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.primaryEmerald.withValues(alpha: 0.15)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(color: AppTheme.primaryEmerald, shape: BoxShape.circle),
                            child: const Icon(Icons.check_rounded, color: Colors.white, size: 14),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('ASSIGNED DISPATCHER', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppTheme.grey500, letterSpacing: 1.0)),
                                const SizedBox(height: 2),
                                Text(assignedWorkerName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppTheme.grey900), maxLines: 1, overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_rounded, size: 20, color: AppTheme.primaryEmerald),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () => _showAssignWorkerDialog(pickup, workers),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showAssignWorkerDialog(pickup, workers),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.grey900,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      icon: const Icon(Icons.person_add_rounded, size: 20, color: Colors.white),
                      label: const Text('ASSIGN FIELD DISPATCHER', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5, color: Colors.white, fontSize: 13)),
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
        Icon(icon, size: 15, color: AppTheme.grey400),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.grey700)),
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
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(36))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(color: AppTheme.grey200, borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Asset Deployment', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: -0.5)),
            const Text('Assign an active field resource to this collection unit.', style: TextStyle(color: AppTheme.grey500, fontSize: 14)),
            const SizedBox(height: 32),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.5),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemCount: workers.length,
                itemBuilder: (context, index) {
                  final worker = workers[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.grey50, 
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.grey100),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      leading: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: AppTheme.emeraldGradient,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Text(worker.name[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
                        ),
                      ),
                      title: Text(worker.name, style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.grey900)),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text('Ward ${worker.wardNumber ?? "N/A"} • Fleet Active', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primaryEmerald)),
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.grey300),
                      onTap: () async {
                        Navigator.pop(context);
                        final success = await context.read<AdminService>().assignWorkerToBooking(pickup.id, worker.id);
                        if (context.mounted && success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Field resource deployed successfully'),
                              backgroundColor: AppTheme.primaryEmerald,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            )
                          );
                        }
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
