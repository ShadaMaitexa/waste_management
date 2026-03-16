import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';
import '../../services/pickup_service.dart';
import '../../models/pickup.dart';
import '../../theme/app_theme.dart';
import 'worker_route_planner_screen.dart';
import 'worker_attendance_screen.dart';
import 'worker_profile_screen.dart';

class WorkerHomeScreen extends StatefulWidget {
  const WorkerHomeScreen({super.key});

  @override
  State<WorkerHomeScreen> createState() => _WorkerHomeScreenState();
}

class _WorkerHomeScreenState extends State<WorkerHomeScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgSurface,
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        physics: const NeverScrollableScrollPhysics(), 
        children: [
          _DashboardTab(onNavigate: _onItemTapped),
          const WorkerRoutePlannerScreen(),
          const WorkerAttendanceScreen(),
          const WorkerProfileScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(28, 0, 28, 32),
        decoration: BoxDecoration(
          color: Colors.transparent,
          boxShadow: [
            BoxShadow(
              color: AppTheme.bgDark.withValues(alpha: 0.2),
              blurRadius: 40,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: Container(
            height: 72,
            decoration: BoxDecoration(
              color: AppTheme.bgDark.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 1.5),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(0, Icons.grid_view_rounded, 'DESK'),
                  _buildNavItem(1, Icons.map_rounded, 'ROUTE'),
                  _buildNavItem(2, Icons.assignment_rounded, 'LOGS'),
                  _buildNavItem(3, Icons.account_circle_rounded, 'SELF'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryEmerald.withValues(alpha: 0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.primaryEmerald : Colors.white.withValues(alpha: 0.2),
              size: 22,
            ),
            if (isSelected) ...[
              const SizedBox(width: 10),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  color: AppTheme.primaryEmerald,
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                  letterSpacing: 2,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DashboardTab extends StatelessWidget {
  final Function(int) onNavigate;

  const _DashboardTab({required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthService, PickupService>(
      builder: (context, authService, pickupService, _) {
        final workerName = authService.currentUserName ?? 'Technician';
        final workerId = authService.currentUser?.id ?? '';
        final todaysPickups = pickupService.getTodaysPickupsForWorker(workerId);
        final pendingCount = todaysPickups.where((p) => p.status == PickupStatus.scheduled).length;
        final completedCount = todaysPickups.where((p) => p.status == PickupStatus.completed).length;
        final currentPickup = todaysPickups.isEmpty ? null : todaysPickups.firstWhere((p) => p.status == PickupStatus.inProgress, orElse: () => todaysPickups.first);

        return Scaffold(
          backgroundColor: AppTheme.bgSurface,
          body: RefreshIndicator(
            color: AppTheme.primaryEmerald,
            onRefresh: () async {
              await pickupService.fetchPickups();
            },
            child: CustomScrollView(
              slivers: [
                _buildSliverAppBar(context, workerName),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL, vertical: AppTheme.spacingL),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildStatsGrid(context, pendingCount, completedCount),
                      const SizedBox(height: AppTheme.spacingXL),
                      _buildCurrentTaskCard(context, currentPickup),
                      const SizedBox(height: AppTheme.spacingXL),
                      _buildQuickActions(context),
                      const SizedBox(height: AppTheme.spacingXL),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSliverAppBar(BuildContext context, String name) {
    return SliverAppBar(
      expandedHeight: 280.0,
      pinned: true,
      elevation: 0,
      backgroundColor: AppTheme.bgDark,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.emeraldGradient,
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned(
                right: -60,
                top: -60,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 0, 32, 56),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1.5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppTheme.primaryEmerald,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryEmerald,
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                )
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'OPERATIVE ACTIVE',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      name,
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 52,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -3,
                        height: 0.9,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'HKS Logistics Specialist • Unit 204',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.tune_rounded, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildStatsGrid(BuildContext context, int pending, int completed) {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            'PENDING',
            pending.toString(),
            Icons.pending_actions_rounded,
            AppTheme.warning,
          ),
        ),
        const SizedBox(width: AppTheme.spacingL),
        Expanded(
          child: _buildStatItem(
            'COMPLETED',
            completed.toString(),
            Icons.task_alt_rounded,
            AppTheme.success,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: AppTheme.smoothShadow,
        border: Border.all(color: AppTheme.grey200.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 28),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              color: AppTheme.grey900,
              letterSpacing: -2,
            ),
          ),
          Text(
            title.toUpperCase(),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              color: AppTheme.grey400,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentTaskCard(BuildContext context, Pickup? pickup) {
    if (pickup == null) {
      return Container(
        padding: const EdgeInsets.all(AppTheme.spacingXL),
        decoration: BoxDecoration(
          color: AppTheme.bgCanvas,
          borderRadius: BorderRadius.circular(AppTheme.radiusXL),
          border: Border.all(color: AppTheme.grey200),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.inbox_rounded, size: 48, color: AppTheme.grey300),
              const SizedBox(height: 16),
              Text('Logistics Queue Empty', style: GoogleFonts.plusJakartaSans(color: AppTheme.grey500, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            'CURRENT OPERATIONAL UNIT',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: AppTheme.grey400,
              letterSpacing: 2,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppTheme.bgDark,
            borderRadius: BorderRadius.circular(44),
            boxShadow: [
              BoxShadow(
                color: AppTheme.bgDark.withValues(alpha: 0.4),
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryEmerald.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppTheme.primaryEmerald.withValues(alpha: 0.1), width: 1.5),
                          ),
                          child: Text(
                            'WARD ${pickup.wardNumber}',
                            style: GoogleFonts.plusJakartaSans(
                              color: AppTheme.primaryEmerald,
                              fontWeight: FontWeight.w900,
                              fontSize: 10,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.more_horiz_rounded, color: Colors.white24),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                    const SizedBox(height: 36),
                    Text(
                      pickup.address,
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        _infoChip(Icons.access_time_filled_rounded, pickup.formattedTime),
                        const SizedBox(width: 14),
                        _infoChip(Icons.layers_rounded, '${pickup.wasteTypes.length} Classes'),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.all(16),
                height: 64,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.05),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    elevation: 0,
                    padding: EdgeInsets.zero,
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: AppTheme.emeraldGradient,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryEmerald.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        )
                      ],
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(
                        'MARK EXTRACTION COMPLETE',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryEmerald, size: 14),
          const SizedBox(width: 10),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'OPERATIONAL TOOLS',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: AppTheme.grey400,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: AppTheme.spacingL),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppTheme.spacingM,
          crossAxisSpacing: AppTheme.spacingM,
          childAspectRatio: 0.85,
          children: [
            _actionCard('Reporting', Icons.camera_alt_rounded, AppTheme.accentIndigo),
            _actionCard('Manifest', Icons.history_edu_rounded, AppTheme.info),
            _actionCard('Signal Command', Icons.headset_mic_rounded, const Color(0xFFF59E0B)),
          ],
        ),
      ],
    );
  }

  Widget _actionCard(String label, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: AppTheme.smoothShadow,
        border: Border.all(color: AppTheme.grey200.withValues(alpha: 0.5)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 16),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: AppTheme.grey900,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
