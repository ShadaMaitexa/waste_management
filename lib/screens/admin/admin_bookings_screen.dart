import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
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
          backgroundColor: AppTheme.bgSurface,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(100),
            child: Container(
              padding: const EdgeInsets.only(top: 20),
              decoration: const BoxDecoration(
                color: AppTheme.bgDark,
                gradient: AppTheme.slateGradient,
              ),
              child: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                scrolledUnderElevation: 0,
                title: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dispatch Control',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w900,
                          fontSize: 24,
                          color: Colors.white,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Logistics and field assignment management',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                foregroundColor: Colors.white,
                actions: [
                  Container(
                    margin: const EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.history_rounded, color: Colors.white, size: 20),
                      onPressed: () {},
                    ),
                  ),
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
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: AppTheme.grey100.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.local_shipping_rounded, size: 80, color: AppTheme.grey300),
          ),
          const SizedBox(height: 32),
          Text(
            'All Dispatched', 
            style: GoogleFonts.plusJakartaSans(
              color: AppTheme.grey900, 
              fontWeight: FontWeight.w900, 
              fontSize: 22,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'No pending collection units requiring assignment.', 
            style: GoogleFonts.inter(
              color: AppTheme.grey400, 
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
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
        boxShadow: AppTheme.smoothShadow,
        border: Border.all(color: AppTheme.grey200.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(Icons.inventory_2_rounded, color: statusColor, size: 24),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              (pickup.specialInstructions ?? "STANDARD COLLECTION").toUpperCase(),
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w900, 
                                fontSize: 11, 
                                color: AppTheme.grey900, 
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          AppTheme.statusTag(pickup.status.name, statusColor),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        pickup.address,
                        style: GoogleFonts.inter(
                          fontSize: 14, 
                          color: AppTheme.grey500, 
                          fontWeight: FontWeight.w500, 
                          height: 1.5,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
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
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppTheme.primaryEmerald.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(
                              gradient: AppTheme.emeraldGradient,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.check_rounded, color: Colors.white, size: 14),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ASSIGNED DISPATCHER', 
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 8, 
                                    fontWeight: FontWeight.w900, 
                                    color: AppTheme.grey400, 
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  assignedWorkerName, 
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.w800, 
                                    fontSize: 15, 
                                    color: AppTheme.grey900,
                                  ), 
                                  maxLines: 1, 
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_rounded, size: 18, color: AppTheme.primaryEmerald),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 2,
                              shadowColor: AppTheme.primaryEmerald.withValues(alpha: 0.2),
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
                        backgroundColor: AppTheme.bgDark,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 22),
                        elevation: 4,
                        shadowColor: AppTheme.bgDark.withValues(alpha: 0.3),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      ),
                      icon: const Icon(Icons.person_add_rounded, size: 20),
                      label: Text(
                        'ASSIGN FIELD DISPATCHER', 
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w900, 
                          letterSpacing: 1, 
                          fontSize: 12,
                        ),
                      ),
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
        const SizedBox(width: 8),
        Text(
          text, 
          style: GoogleFonts.inter(
            fontSize: 13, 
            fontWeight: FontWeight.w700, 
            color: AppTheme.grey700,
          ),
        ),
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
            const SizedBox(height: 32),
            Text(
              'Asset Deployment', 
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w900, 
                fontSize: 24, 
                letterSpacing: -1,
                color: AppTheme.grey900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Assign an active field resource to this collection unit.', 
              style: GoogleFonts.inter(
                color: AppTheme.grey500, 
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
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
                      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      leading: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: AppTheme.emeraldGradient,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryEmerald.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            worker.name[0], 
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white, 
                              fontWeight: FontWeight.w900, 
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        worker.name, 
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w900, 
                          color: AppTheme.grey900,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            Text(
                              'Ward ${worker.wardNumber ?? "N/A"}', 
                              style: GoogleFonts.inter(
                                fontSize: 12, 
                                fontWeight: FontWeight.w600, 
                                color: AppTheme.grey400,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryEmerald.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'ACTIVE',
                                style: GoogleFonts.inter(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.primaryEmerald,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.grey300),
                      onTap: () async {
                        Navigator.pop(context);
                        final success = await context.read<AdminService>().assignWorkerToBooking(pickup.id, worker.id);
                        if (context.mounted && success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Field resource deployed successfully',
                                style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                              ),
                              backgroundColor: AppTheme.bgDark,
                              behavior: SnackBarBehavior.floating,
                              margin: const EdgeInsets.all(24),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
