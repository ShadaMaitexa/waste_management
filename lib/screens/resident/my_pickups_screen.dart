import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../services/pickup_service.dart';
import '../../services/auth_service.dart';
import '../../models/pickup.dart';
import '../../theme/app_theme.dart';

class MyPickupsScreen extends StatefulWidget {
  const MyPickupsScreen({super.key});

  @override
  State<MyPickupsScreen> createState() => _MyPickupsScreenState();
}

class _MyPickupsScreenState extends State<MyPickupsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PickupService>(context, listen: false).fetchPickups();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Service Registry',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w900, 
            fontSize: 18,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppTheme.bgDark,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.slateGradient,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Container(
            margin: const EdgeInsets.fromLTRB(24, 0, 24, 20),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              labelColor: AppTheme.bgDark,
              unselectedLabelColor: Colors.white.withValues(alpha: 0.6),
              labelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1),
              unselectedLabelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 1),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: 'ACTIVE'),
                Tab(text: 'HISTORY'),
                Tab(text: 'ABORTED'),
              ],
            ),
          ),
        ),
      ),
      body: Consumer2<AuthService, PickupService>(
        builder: (context, authService, pickupService, child) {
          final userId = authService.currentUser?.id ?? '';
          final allUserPickups = pickupService.getPickupsForUser(userId);

          return TabBarView(
            controller: _tabController,
            children: [
              _buildPickupList(
                allUserPickups.where((p) => p.status == PickupStatus.scheduled || p.status == PickupStatus.assigned || p.status == PickupStatus.inProgress).toList(),
                'upcoming'
              ),
              _buildPickupList(
                allUserPickups.where((p) => p.status == PickupStatus.completed).toList(),
                'completed'
              ),
              _buildPickupList(
                allUserPickups.where((p) => p.status == PickupStatus.cancelled || p.status == PickupStatus.failed).toList(),
                'cancelled'
              ),
            ],
          );
        },
      ),
      floatingActionButton: Container(
        height: 72,
        width: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryEmerald.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () => Navigator.pushNamed(context, '/book-pickup'),
          backgroundColor: AppTheme.primaryEmerald,
          elevation: 0,
          shape: const CircleBorder(),
          child: Ink(
            decoration: BoxDecoration(
              gradient: AppTheme.emeraldGradient,
              shape: BoxShape.circle,
            ),
            child: Container(
              alignment: Alignment.center,
              child: const Icon(Icons.add_rounded, color: Colors.white, size: 36),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPickupList(List<Pickup> pickups, String type) {
    if (pickups.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                shape: BoxShape.circle,
                boxShadow: AppTheme.smoothShadow,
              ),
              child: Icon(Icons.layers_clear_rounded, size: 64, color: AppTheme.grey200),
            ),
            const SizedBox(height: 32),
            Text(
              'NO RECORDS FOUND',
              style: GoogleFonts.plusJakartaSans(
                color: AppTheme.grey400, 
                fontWeight: FontWeight.w900, 
                fontSize: 12,
                letterSpacing: 2,
              ),
            ),
             const SizedBox(height: 8),
            Text(
              'Logs for this category are currently empty.',
              style: GoogleFonts.inter(
                color: AppTheme.grey300, 
                fontWeight: FontWeight.w500, 
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => Provider.of<PickupService>(context, listen: false).fetchPickups(),
      child: ListView.builder(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        itemCount: pickups.length,
        itemBuilder: (context, index) {
          return _buildPickupCard(pickups[index]);
        },
      ),
    );
  }

  Widget _buildPickupCard(Pickup pickup) {
    final isUpcoming = pickup.status == PickupStatus.scheduled || pickup.status == PickupStatus.assigned || pickup.status == PickupStatus.inProgress;
    final statusColor = _getStatusColor(pickup.status);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(40),
        boxShadow: AppTheme.smoothShadow,
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppTheme.primaryEmerald.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat('dd').format(pickup.scheduledDate),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.primaryEmerald,
                        height: 1,
                        letterSpacing: -1.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('MMM').format(pickup.scheduledDate).toUpperCase(),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.primaryEmerald,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          pickup.formattedTime,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Theme.of(context).textTheme.titleLarge?.color ?? AppTheme.grey900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        _buildStatusBadge(pickup.status, statusColor),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      pickup.address,
                      style: GoogleFonts.inter(
                        color: AppTheme.grey500, 
                        fontSize: 14, 
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                         Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Theme.of(context).dividerColor),
                          ),
                          child: Text(
                            pickup.itemDisplay.toUpperCase(),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.grey700,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Theme.of(context).dividerColor),
                          ),
                          child: Text(
                            pickup.wasteType.toUpperCase(),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.grey700,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (isUpcoming && pickup.status == PickupStatus.scheduled) ...[
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 56,
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        side: BorderSide(color: AppTheme.grey200.withValues(alpha: 0.5), width: 1.5),
                        foregroundColor: AppTheme.grey700,
                      ),
                      child: Text(
                        'CONFIGURE',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w900, 
                          fontSize: 12, 
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () async {
                        final success = await Provider.of<PickupService>(context, listen: false).cancelPickup(pickup.id);
                         if (success && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Pickup cancelled successfully')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.error.withValues(alpha: 0.1),
                        foregroundColor: AppTheme.error,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 0,
                      ),
                      child: Text(
                        'ABORT',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w900, 
                          fontSize: 12, 
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildStatusBadge(PickupStatus status, Color color) {
    String label = status.name;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.plusJakartaSans(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Color _getStatusColor(PickupStatus status) {
    switch (status) {
      case PickupStatus.scheduled: return AppTheme.primaryEmerald;
      case PickupStatus.assigned: return AppTheme.info;
      case PickupStatus.inProgress: return AppTheme.warning;
      case PickupStatus.completed: return AppTheme.success;
      case PickupStatus.cancelled: return AppTheme.error;
      case PickupStatus.failed: return AppTheme.error;
    }
  }
}
