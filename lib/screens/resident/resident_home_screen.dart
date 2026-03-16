import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/auth_service.dart';
import '../../services/pickup_service.dart';
import '../../services/referral_service.dart';
import '../../theme/app_theme.dart';
import 'book_pickup_screen.dart';
import 'referral_screen.dart';
import 'profile_screen.dart';

class ResidentHomeScreen extends StatefulWidget {
  const ResidentHomeScreen({super.key});

  @override
  State<ResidentHomeScreen> createState() => _ResidentHomeScreenState();
}

class _ResidentHomeScreenState extends State<ResidentHomeScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgSurface,
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() => _selectedIndex = index);
        },
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _DashboardTab(onNavigate: _onItemTapped),
          const BookPickupScreen(),
          const ReferralScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.bgCanvas,
          border: Border(top: BorderSide(color: AppTheme.grey200.withValues(alpha: 0.5))),
          boxShadow: [
            BoxShadow(
              color: AppTheme.grey900.withValues(alpha: 0.04),
              blurRadius: 24,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onItemTapped,
              backgroundColor: Colors.transparent,
              elevation: 0,
              indicatorColor: AppTheme.primaryEmerald.withValues(alpha: 0.12),
              height: 60,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined, size: 22, color: AppTheme.grey500),
                  selectedIcon: Icon(Icons.dashboard_rounded, color: AppTheme.primaryEmerald, size: 24),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.add_circle_outline_rounded, size: 22, color: AppTheme.grey500),
                  selectedIcon: Icon(Icons.add_circle_rounded, color: AppTheme.primaryEmerald, size: 24),
                  label: 'Book',
                ),
                NavigationDestination(
                  icon: Icon(Icons.auto_awesome_outlined, size: 22, color: AppTheme.grey500),
                  selectedIcon: Icon(Icons.auto_awesome_rounded, color: AppTheme.primaryEmerald, size: 24),
                  label: 'Rewards',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline_rounded, size: 22, color: AppTheme.grey500),
                  selectedIcon: Icon(Icons.person_rounded, color: AppTheme.primaryEmerald, size: 24),
                  label: 'Profile',
                ),
              ],
            ),
          ),
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
    return Consumer3<AuthService, PickupService, ReferralService>(
      builder: (context, authService, pickupService, referralService, _) {
        final userId = authService.currentUser?.id ?? '';
        final userName = authService.currentUserName ?? 'Resident';
        
        final pickups = pickupService.getUpcomingPickupsForUser(userId);
        final totalWaste = pickupService.getTotalWasteCollectedForUser(userId);
        final wardNumber = authService.currentUser?.wardNumber;
        
        final stats = {
          'referralCount': referralService.referralCount,
          'totalEarned': referralService.totalEarned,
          'totalWaste': totalWaste,
        };

        return Scaffold(
          backgroundColor: AppTheme.bgSurface,
          body: RefreshIndicator(
            color: AppTheme.primaryEmerald,
            onRefresh: () async {
              await pickupService.fetchPickups();
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                _buildSliverAppBar(context, userName, wardNumber),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
                    child: Column(
                      children: [
                        const SizedBox(height: AppTheme.spacingL),
                        _buildNextPickupCard(context, pickups.isNotEmpty ? pickups.first : null),
                        const SizedBox(height: AppTheme.spacingL),
                        _buildStatsOverview(context, stats, wardNumber),
                        const SizedBox(height: AppTheme.spacingL),
                        _buildQuickActionsGrid(context),
                        const SizedBox(height: AppTheme.spacingL),
                        _buildRecentActivity(context, referralService),
                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSliverAppBar(BuildContext context, String userName, String? wardNumber) {
    return SliverAppBar(
      expandedHeight: 220.0,
      floating: false,
      pinned: true,
      backgroundColor: AppTheme.bgDark,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: AppTheme.slateGradient,
              ),
            ),
            Positioned(
              right: -60,
              top: -40,
              child: Icon(
                Icons.radar_rounded,
                size: 280,
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryEmerald.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.primaryEmerald.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.verified_rounded, color: AppTheme.primaryEmerald, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          'PREMIUM AMBASSADOR',
                          style: GoogleFonts.plusJakartaSans(
                            color: AppTheme.primaryEmerald,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Hello, $userName.',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on_rounded, color: Colors.white.withValues(alpha: 0.6), size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Ward ${wardNumber ?? "15"} • Kozhikode Area',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        Container(
          height: 40,
          width: 40,
          margin: const EdgeInsets.only(right: 8, top: 4, bottom: 4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 20),
            onPressed: () => Navigator.pushNamed(context, '/notifications'),
          ),
        ),
        Container(
          height: 40,
          width: 40,
          margin: const EdgeInsets.only(right: 16, top: 4, bottom: 4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: IconButton(
            icon: const Icon(Icons.power_settings_new_rounded, color: Colors.white, size: 20),
            onPressed: () {
              Provider.of<AuthService>(context, listen: false).logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNextPickupCard(BuildContext context, dynamic pickup) {
    if (pickup == null) {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppTheme.bgCanvas,
          borderRadius: BorderRadius.circular(28),
          boxShadow: AppTheme.cardShadow,
          border: Border.all(color: AppTheme.grey200),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                top: -20,
                child: Icon(
                  Icons.recycling_rounded,
                  size: 140,
                  color: AppTheme.grey100,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryEmerald.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.add_task_rounded, color: AppTheme.primaryEmerald, size: 28),
                    ),
                    const SizedBox(width: AppTheme.spacingL),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ready to Recycle?',
                            style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18,
                                  color: AppTheme.grey900,
                                  letterSpacing: -0.5,
                                ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Schedule your next pickup today.',
                            style: GoogleFonts.plusJakartaSans(color: AppTheme.grey500, fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => onNavigate(1),
                      child: const Text('Book'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: AppTheme.emeraldGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: AppTheme.intenseShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            Positioned(
              right: -30,
              bottom: -30,
              child: Icon(
                Icons.local_shipping_rounded,
                size: 180,
                color: Colors.white.withValues(alpha: 0.15),
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
                          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.access_time_filled, color: Colors.white, size: 12),
                            const SizedBox(width: 8),
                            Text(
                              'UPCOMING DISPATCH',
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
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
                        child: const Icon(Icons.more_horiz_rounded, color: Colors.white, size: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Text(
                    pickup.scheduledDate != null
                        ? DateFormat('EEEE, MMM d').format(pickup.scheduledDate!)
                        : 'Tomorrow',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'ETA: ${pickup.formattedTime ?? '10:30 AM'} • Your Location',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      _pickupTag(Icons.delete_outline_rounded, 'Mixed Waste'),
                      const SizedBox(width: 12),
                      _pickupTag(Icons.eco_rounded, 'Eco Friendly'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pickupTag(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsOverview(BuildContext context, Map<String, dynamic> stats, String? wardNumber) {
    return Row(
      children: [
        Expanded(
          child: _expressCard(context, wardNumber),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _statCard(
            context,
            'Recycled (Kg)',
            stats['totalWaste'].toStringAsFixed(1),
            Icons.scale_rounded,
            AppTheme.info,
          ),
        ),
      ],
    );
  }

  Widget _expressCard(BuildContext context, String? wardNumber) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Initializing live tracking module...')),
        );
      },
      child: Container(
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.info.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.route_rounded,
                    color: AppTheme.info,
                    size: 24,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppTheme.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'LIVE',
                        style: GoogleFonts.plusJakartaSans(
                          color: AppTheme.error,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              'Fleet Tracking',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppTheme.grey900,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Text(
                  'Ward ${wardNumber ?? "15"}',
                  style: GoogleFonts.plusJakartaSans(
                    color: AppTheme.grey500,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: AppTheme.info,
                  size: 14,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(BuildContext context, String title, String value, IconData icon, Color color) {
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
          const SizedBox(height: 28),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: AppTheme.grey900,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title.toUpperCase(),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              color: AppTheme.grey500,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsGrid(BuildContext context) {
    final actions = [
      {'icon': Icons.add_rounded, 'label': 'Book Pickup', 'color': AppTheme.primaryEmerald, 'index': 1},
      {'icon': Icons.history_rounded, 'label': 'History', 'color': AppTheme.accentIndigo, 'index': -1},
      {'icon': Icons.support_agent_rounded, 'label': 'Support', 'color': const Color(0xFF8B5CF6), 'index': -1},
      {'icon': Icons.military_tech_rounded, 'label': 'Rewards', 'color': const Color(0xFFF59E0B), 'index': 2},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'QUICK LAUNCH',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: AppTheme.grey500,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: actions.map((action) {
            final color = action['color'] as Color;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  final navIndex = action['index'] as int;
                  if (navIndex != -1) onNavigate(navIndex);
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  padding: const EdgeInsets.symmetric(vertical: 24),
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
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(action['icon'] as IconData, color: color, size: 24),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        (action['label'] as String).split(' ')[0],
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.grey700,
                          letterSpacing: 0.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRecentActivity(BuildContext context, ReferralService referralService) {
    final activities = referralService.getReferralHistory();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'NETWORK LOG',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppTheme.grey500,
                letterSpacing: 1.5,
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: Text(
                'VIEW ALL',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primaryEmerald,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.bgCanvas,
            borderRadius: BorderRadius.circular(28),
            boxShadow: AppTheme.cardShadow,
            border: Border.all(color: AppTheme.grey200),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: 8),
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activities.isEmpty ? 2 : activities.length,
            separatorBuilder: (_, __) => Divider(color: AppTheme.grey200, height: 1, indent: 24, endIndent: 24),
            itemBuilder: (context, index) {
              if (activities.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.hub_rounded, size: 48, color: AppTheme.grey200),
                        const SizedBox(height: 12),
                        Text('No network activity detected', style: GoogleFonts.plusJakartaSans(color: AppTheme.grey500, fontWeight: FontWeight.w600, fontSize: 13)),
                      ],
                    ),
                  ),
                );
              }
              final item = activities[index];
              final isPaid = item.amount > 0;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryEmerald.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.person_add_rounded, color: AppTheme.primaryEmerald, size: 20),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              color: AppTheme.grey900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.date,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: AppTheme.grey500,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (isPaid)
                          Text(
                            '+₹${item.amount.toStringAsFixed(0)}',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              color: AppTheme.success,
                            ),
                          ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: (isPaid ? AppTheme.success : AppTheme.grey400).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item.status.toUpperCase(),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: isPaid ? AppTheme.success : AppTheme.grey500,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
