import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/auth_service.dart';
import '../../services/pickup_service.dart';
import '../../services/referral_service.dart';
import '../../models/pickup.dart';
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          if (mounted) setState(() => _selectedIndex = index);
        },
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _DashboardTab(onNavigate: _onItemTapped, key: const ValueKey('dash_tab')),
          const BookPickupScreen(key: ValueKey('book_tab')),
          const ReferralScreen(key: ValueKey('earn_tab')),
          const ProfileScreen(key: ValueKey('self_tab')),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        decoration: BoxDecoration(
          color: Colors.transparent,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              color: AppTheme.bgDark.withValues(alpha: 0.98),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05), width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(0, Icons.grid_view_rounded, 'DASH'),
                  _buildNavItem(1, Icons.add_circle_outline_rounded, 'BOOK'),
                  _buildNavItem(2, Icons.auto_awesome_rounded, 'EARN'),
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
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryEmerald.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              key: ValueKey('icon_$index'),
              color: isSelected ? AppTheme.primaryEmerald : Colors.white.withValues(alpha: 0.3),
              size: 18,
            ),
            if (isSelected) 
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                child: Row(
                  children: [
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: GoogleFonts.plusJakartaSans(
                        color: AppTheme.primaryEmerald,
                        fontWeight: FontWeight.w900,
                        fontSize: 9,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DashboardTab extends StatelessWidget {
  final Function(int) onNavigate;

  const _DashboardTab({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Consumer3<AuthService, PickupService, ReferralService>(
      builder: (context, authService, pickupService, referralService, _) {
        final userId = authService.currentUser?.id ?? '';
        final userName = authService.currentUserName ?? 'Resident';
        
        final pickups = pickupService.getPickupsForUser(userId)
          ..sort((a, b) => b.scheduledDate.compareTo(a.scheduledDate));
        final totalWaste = pickupService.getTotalWasteCollectedForUser(userId);
        final wardNumber = authService.currentUser?.wardNumber;
        
        final stats = {
          'referralCount': referralService.referralCount,
          'totalEarned': referralService.totalEarned,
          'totalWaste': totalWaste,
        };

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0), // Adjusted
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        _buildNextPickupCard(context, pickups.isNotEmpty ? pickups.first : null),
                        const SizedBox(height: 20),
                        _buildStatsOverview(context, stats, wardNumber),
                        _buildRecentActivity(context, pickups),
                        const SizedBox(height: 100),
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
      expandedHeight: 180.0, // Reduced from 240
      floating: false,
      pinned: true,
      backgroundColor: AppTheme.bgDark,
      elevation: 0,
      scrolledUnderElevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            color: AppTheme.bgDark,
            gradient: AppTheme.slateGradient,
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned(
                right: -40,
                top: -10,
                child: Icon(
                  Icons.eco_rounded,
                  size: 180, // Reduced from 280
                  color: Colors.white.withValues(alpha: 0.03),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24), // Reduced
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      'Welcome back,',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 13, // Reduced from 14
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      userName,
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 32, // Reduced from 40
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.2,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded, color: AppTheme.primaryEmerald, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          'Ward ${wardNumber ?? "15"} • Smart City District',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
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
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 22), // Reduced size
          onPressed: () => Navigator.pushNamed(context, '/notifications'),
        ),
        IconButton(
          icon: const Icon(Icons.power_settings_new_rounded, color: Colors.white, size: 22), // Reduced size
          onPressed: () {
            Provider.of<AuthService>(context, listen: false).logout();
            Navigator.pushReplacementNamed(context, '/login');
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildNextPickupCard(BuildContext context, dynamic pickup) {
    if (pickup == null) {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24), // Reduced
          boxShadow: AppTheme.cardShadow,
          border: Border.all(color: AppTheme.grey100, width: 1.2),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              Positioned(
                right: -15,
                top: -15,
                child: Icon(
                  Icons.recycling_rounded,
                  size: 100, // Reduced from 140
                  color: AppTheme.grey50,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20), // Reduced from 24
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryEmerald.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.add_task_rounded, color: AppTheme.primaryEmerald, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Plan Next Collection',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w900,
                              fontSize: 16, // Reduced from 18
                              color: Theme.of(context).textTheme.headlineLarge?.color ?? AppTheme.grey900,
                              letterSpacing: -0.4,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Ready to recycle? Schedule now.',
                            style: GoogleFonts.plusJakartaSans(
                              color: AppTheme.grey500, 
                              fontSize: 12, // Reduced from 13
                              fontWeight: FontWeight.w600
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios_rounded, color: AppTheme.grey300, size: 14),
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
        color: AppTheme.primaryEmerald,
        borderRadius: BorderRadius.circular(24), // Reduced
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryEmerald.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned(
              right: -15,
              bottom: -15,
              child: Icon(
                Icons.local_shipping_rounded,
                size: 130, // Reduced from 180
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24), // Reduced from 28
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), // Reduced
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.access_time_filled_rounded, color: Colors.white, size: 11),
                            const SizedBox(width: 6),
                            Text(
                              'NEXT COLLECTION',
                              style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white, 
                                  fontWeight: FontWeight.w900, 
                                  fontSize: 9, // Reduced from 10
                                  letterSpacing: 0.8),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.more_horiz_rounded, color: Colors.white, size: 18),
                    ],
                  ),
                  const SizedBox(height: 24), // Reduced from 32
                  Text(
                    pickup.scheduledDate != null
                        ? DateFormat('EEEE, MMM d').format(pickup.scheduledDate!)
                        : 'Tomorrow',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 26, // Reduced from 32
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.8,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Time: ${pickup.formattedTime ?? '09:30 AM'} • ${pickup.address}',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 12, // Reduced from 13
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 20), // Reduced from 28
                  Row(
                    children: [
                      _pickupTag(Icons.auto_awesome_mosaic_rounded, 'Mixed Load'),
                      const SizedBox(width: 8),
                      _pickupTag(Icons.verified_rounded, 'Verified'),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label.toUpperCase(),
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 9,
              letterSpacing: 0.5,
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
          child: _liveTrackerCard(context, wardNumber),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _statCard(
            context,
            'NET RECYCLED',
            '${stats['totalWaste'].toStringAsFixed(1)} kg',
            Icons.eco_rounded,
            AppTheme.success,
          ),
        ),
      ],
    );
  }

  Widget _liveTrackerCard(BuildContext context, String? wardNumber) {
    return Container(
      padding: const EdgeInsets.all(18), // Reduced from 24
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24), // Reduced from 28
        boxShadow: AppTheme.cardShadow,
        border: Border.all(color: AppTheme.grey100, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryEmerald.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.radar_rounded,
                  color: AppTheme.primaryEmerald,
                  size: 20,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(color: AppTheme.error, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'LIVE',
                      style: GoogleFonts.plusJakartaSans(
                        color: AppTheme.error,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16), // Reduced from 24
          Text(
            'Fleet Tracker',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14, // Reduced from 16
              fontWeight: FontWeight.w900,
              color: AppTheme.grey900,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Ward ${wardNumber ?? "15"} Territory',
            style: GoogleFonts.plusJakartaSans(
              color: AppTheme.grey500,
              fontSize: 11, // Reduced from 12
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(18), // Reduced from 24
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24), // Reduced from 28
        boxShadow: AppTheme.cardShadow,
        border: Border.all(color: AppTheme.grey100, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8), // Reduced from 10
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10), // Reduced from 12
            ),
            child: Icon(icon, color: color, size: 18), // Reduced from 20
          ),
          const SizedBox(height: 16), // Reduced from 20
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20, // Reduced from 24
              fontWeight: FontWeight.w900,
              color: AppTheme.grey900,
              letterSpacing: -0.8, // Reduced from -1
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 8, // Reduced from 9
              color: AppTheme.grey400,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8, // Reduced from 1
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildRecentActivity(BuildContext context, List<Pickup> activities) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'RECENT ACTIVITY',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: AppTheme.grey500,
                letterSpacing: 1.5,
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/resident/my-pickups'),
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
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(32),
            boxShadow: AppTheme.smoothShadow,
            border: Border.all(color: AppTheme.grey200.withValues(alpha: 0.5)),
          ),
          child: activities.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.hub_rounded, size: 40, color: AppTheme.grey200),
                        const SizedBox(height: 12),
                        Text('No activity detected', style: GoogleFonts.plusJakartaSans(color: AppTheme.grey500, fontWeight: FontWeight.w600, fontSize: 13)),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: activities.take(5).length,
                  separatorBuilder: (_, __) => Divider(color: AppTheme.grey200, height: 1, indent: 20, endIndent: 20),
                  itemBuilder: (context, index) {
                    final pickup = activities[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryEmerald.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.receipt_long_rounded, color: AppTheme.primaryEmerald, size: 20),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  pickup.itemDisplay,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                    color: Theme.of(context).textTheme.titleLarge?.color ?? AppTheme.grey900,
                                  ),
                                ),
                                Text(
                                  DateFormat('MMM dd, yyyy').format(pickup.scheduledDate),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    color: AppTheme.grey400,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStatusColor(pickup.status).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              pickup.status.name.toUpperCase(),
                              style: GoogleFonts.plusJakartaSans(
                                color: _getStatusColor(pickup.status),
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
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
