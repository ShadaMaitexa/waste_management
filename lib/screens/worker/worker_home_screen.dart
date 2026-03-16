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
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: _onItemTapped,
          backgroundColor: AppTheme.bgCanvas,
          surfaceTintColor: Colors.transparent,
          indicatorColor: AppTheme.primaryEmerald.withValues(alpha: 0.15),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard_rounded, color: AppTheme.primaryEmerald),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(Icons.map_outlined),
              selectedIcon: Icon(Icons.map_rounded, color: AppTheme.primaryEmerald),
              label: 'Routing',
            ),
            NavigationDestination(
              icon: Icon(Icons.fact_check_outlined),
              selectedIcon: Icon(Icons.fact_check_rounded, color: AppTheme.primaryEmerald),
              label: 'Logbook',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person_rounded, color: AppTheme.primaryEmerald),
              label: 'Profile',
            ),
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
                      const SizedBox(height: AppTheme.spacingXXL),
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
      expandedHeight: 180.0,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: AppTheme.bgDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(36)),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: AppTheme.slateGradient,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(36)),
              ),
            ),
            Positioned(
              right: -30,
              top: -20,
              child: Icon(
                Icons.memory_rounded,
                size: 200,
                color: Colors.white.withValues(alpha: 0.03),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 24, bottom: 24, right: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Operational Status: Online',
                    style: GoogleFonts.plusJakartaSans(color: AppTheme.grey400, fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    name,
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryEmerald.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.primaryEmerald.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.verified_rounded, color: AppTheme.primaryEmerald, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          'FIELD OPERATIVE #GLW204',
                          style: GoogleFonts.plusJakartaSans(color: AppTheme.primaryEmerald, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_active_rounded, color: AppTheme.grey300),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.exit_to_app_rounded, color: AppTheme.grey300),
          onPressed: () {
            Provider.of<AuthService>(context, listen: false).logout();
            Navigator.of(context).pushReplacementNamed('/login');
          },
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.bgCanvas,
        borderRadius: BorderRadius.circular(28),
        boxShadow: AppTheme.cardShadow,
        border: Border.all(color: AppTheme.grey200),
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
          const SizedBox(height: 20),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppTheme.grey900,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              color: AppTheme.grey500,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Active Waypoint',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppTheme.grey900,
                letterSpacing: -0.5,
              ),
            ),
            TextButton(
              onPressed: () => onNavigate(1),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                backgroundColor: AppTheme.primaryEmerald.withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('ROUTE MAP', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5, color: AppTheme.primaryEmerald)),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingL),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: AppTheme.emeraldGradient,
            borderRadius: BorderRadius.circular(32),
            boxShadow: AppTheme.intenseShadow,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: Stack(
              children: [
                Positioned(
                  right: -40,
                  bottom: -40,
                  child: Icon(
                    Icons.location_city_rounded,
                    size: 200,
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.gps_fixed_rounded, color: Colors.white, size: 14),
                                const SizedBox(width: 6),
                                Text(
                                  'PRIORITY DISPATCH',
                                  style: GoogleFonts.plusJakartaSans(
                                      color: Colors.white, 
                                      fontWeight: FontWeight.w800, 
                                      fontSize: 10,
                                      letterSpacing: 1),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                            ),
                            child: Text(
                              'Ward ${pickup.wardNumber}',
                              style: GoogleFonts.plusJakartaSans(
                                color: AppTheme.primaryEmerald,
                                fontWeight: FontWeight.w800,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      Text(
                        pickup.address,
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(Icons.schedule_rounded, color: Colors.white.withValues(alpha: 0.8), size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'ETA: ${pickup.formattedTime}',
                            style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                          const Spacer(),
                          Text(
                            '${pickup.wasteTypes.length} Classes',
                            style: GoogleFonts.plusJakartaSans(color: Colors.white.withValues(alpha: 0.8), fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppTheme.primaryEmerald,
                          elevation: 0,
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.verified_rounded, size: 20),
                            const SizedBox(width: 12),
                            Text('CONFIRM EXTRACTION', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 1)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Operational Tools',
          style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppTheme.grey900,
                letterSpacing: -0.5,
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
        color: AppTheme.bgCanvas,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.cardShadow,
        border: Border.all(color: AppTheme.grey200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppTheme.grey800,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
