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
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() => _selectedIndex = index);
        },
        physics: const NeverScrollableScrollPhysics(), // Prevent horizontal swipe
        children: [
          _DashboardTab(onNavigate: _onItemTapped),
          const BookPickupScreen(),
          const ReferralScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onItemTapped,
              backgroundColor: Colors.transparent,
              elevation: 0,
              indicatorColor: AppTheme.primaryGreen.withOpacity(0.1),
              height: 64,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              destinations: const [
                NavigationDestination(
                icon: Icon(Icons.dashboard_outlined, size: 22),
                selectedIcon: Icon(Icons.dashboard_rounded, color: AppTheme.primaryGreen, size: 24),
                label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.add_circle_outline_rounded, size: 22),
                  selectedIcon: Icon(Icons.add_circle_rounded, color: AppTheme.primaryGreen, size: 24),
                  label: 'Book',
                ),
                NavigationDestination(
                  icon: Icon(Icons.auto_awesome_outlined, size: 22),
                  selectedIcon: Icon(Icons.auto_awesome_rounded, color: AppTheme.primaryGreen, size: 24),
                  label: 'Rewards',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline_rounded, size: 22),
                  selectedIcon: Icon(Icons.person_rounded, color: AppTheme.primaryGreen, size: 24),
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
        
        // Fetch pickups if not already done (proactive)
        // Note: fetchPickups usually called at login or app start, but good to have here too
        
        final pickups = pickupService.getUpcomingPickupsForUser(userId);
        final totalWaste = pickupService.getTotalWasteCollectedForUser(userId);
        final wardNumber = authService.currentUser?.wardNumber;
        
        final stats = {
          'referralCount': referralService.referralCount,
          'totalEarned': referralService.totalEarned,
          'totalWaste': totalWaste,
        };

        return Scaffold(
      backgroundColor: AppTheme.grey50,
      body: RefreshIndicator(
        color: AppTheme.primaryGreen,
        onRefresh: () async {
          await pickupService.fetchPickups();
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            _buildSliverAppBar(context, userName, wardNumber),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
                child: Column(
                  children: [
                    const SizedBox(height: AppTheme.spacingM),
                    _buildNextPickupCard(context, pickups.isNotEmpty ? pickups.first : null),
                    const SizedBox(height: AppTheme.spacingL),
                    _buildStatsOverview(context, stats, wardNumber),
                    const SizedBox(height: AppTheme.spacingL),
                    _buildQuickActionsGrid(context),
                    const SizedBox(height: AppTheme.spacingL),
                    _buildRecentActivity(context, referralService),
                    const SizedBox(height: AppTheme.spacingXXL), // Extra padding at bottom
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
      expandedHeight: 200.0,
      floating: false,
      pinned: true,
      backgroundColor: AppTheme.primaryGreen,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryGreen, AppTheme.secondaryGreen],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            Positioned(
              right: -50,
              top: -20,
              child: Icon(
                Icons.eco_rounded,
                size: 240,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'STATUS: PREMIUM AMBASSADOR',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Hello, $userName!',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on_rounded, color: Colors.white.withOpacity(0.8), size: 14),
                      const SizedBox(width: 4),
                      Text(
                        'Ward ${wardNumber ?? "15"} • Kozhikode Metropolitan',
                        style: GoogleFonts.inter(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
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
          margin: const EdgeInsets.only(right: 8, top: 4, bottom: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 22),
            onPressed: () => Navigator.pushNamed(context, '/notifications'),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(right: 16, top: 4, bottom: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.power_settings_new_rounded, color: Colors.white, size: 22),
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: AppTheme.softShadow,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                top: -20,
                child: Icon(
                  Icons.calendar_today_outlined,
                  size: 100,
                  color: AppTheme.primaryGreen.withOpacity(0.05),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: AppTheme.glassGradient,
                        color: AppTheme.primaryGreen.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.add_task_rounded, color: AppTheme.primaryGreen, size: 28),
                    ),
                    const SizedBox(width: AppTheme.spacingM),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ready to Recycle?',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.grey900,
                                  letterSpacing: -0.5,
                                ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Pickups start from ₹10/Kg',
                            style: TextStyle(color: AppTheme.grey600, fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => onNavigate(1), // Go to Book Pickup
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Book Now'),
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
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.primaryShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned(
              right: -40,
              bottom: -40,
              child: Icon(
                Icons.local_shipping_rounded,
                size: 200,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.access_time_filled, color: Colors.white, size: 14),
                            SizedBox(width: 6),
                            Text(
                              'UPCOMING PICKUP',
                              style: TextStyle(
                                  color: Colors.white, 
                                  fontWeight: FontWeight.bold, 
                                  fontSize: 10,
                                  letterSpacing: 0.5),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.more_horiz, color: Colors.white70),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pickup.scheduledDate != null
                                  ? DateFormat('EEEE, MMM d').format(pickup.scheduledDate!)
                                  : 'Tomorrow',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Arriving around ${pickup.formattedTime ?? '10:30 AM'}',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingL),
                  Row(
                    children: [
                      _pickupTag(Icons.auto_delete_rounded, 'Dry Waste'),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppTheme.primaryGreen),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.primaryGreen,
              fontWeight: FontWeight.bold,
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
        const SizedBox(width: AppTheme.spacingM),
        Expanded(
          child: _statCard(
            context,
            'Kg Collected',
            stats['totalWaste'].toStringAsFixed(1),
            Icons.scale,
            AppTheme.info,
          ),
        ),
      ],
    );
  }

  Widget _expressCard(BuildContext context, String? wardNumber) {
    return GestureDetector(
      onTap: () {
        // TODO: Navigate to live map screen showing truck location
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Opening live truck tracking map...'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: AppTheme.infoGradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppTheme.info.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
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
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.local_shipping_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF00E676),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Color(0xFF00E676), blurRadius: 4),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'LIVE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Truck Tracking',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  'On the way to Ward ${wardNumber ?? "15"}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white54,
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.1), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 20),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppTheme.grey900,
              letterSpacing: -1,
            ),
          ),
          Text(
            title.toUpperCase(),
            style: TextStyle(
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
      {'icon': Icons.add_circle_rounded, 'label': 'Book Pickup', 'color': AppTheme.primaryGreen, 'index': 1},
      {'icon': Icons.history_rounded, 'label': 'My History', 'color': const Color(0xFF3B82F6), 'index': -1},
      {'icon': Icons.support_agent_rounded, 'label': 'Support', 'color': const Color(0xFF8B5CF6), 'index': -1},
      {'icon': Icons.auto_awesome_rounded, 'label': 'Rewards', 'color': Colors.orange, 'index': 2},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'QUICK ACTIONS',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
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
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(action['icon'] as IconData, color: color, size: 22),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        (action['label'] as String).split(' ')[0],
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
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
            const Text(
              'RECENT ACTIVITY',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: AppTheme.grey500,
                letterSpacing: 1.5,
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: const Text(
                'VIEW ALL',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.primaryGreen,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activities.isEmpty ? 2 : activities.length,
            separatorBuilder: (_, __) => Divider(color: AppTheme.grey100, height: 1, indent: 72, endIndent: 20),
            itemBuilder: (context, index) {
              if (activities.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.history_rounded, size: 40, color: AppTheme.grey300),
                        const SizedBox(height: 8),
                        const Text('No recent activity', style: TextStyle(color: AppTheme.grey400, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                );
              }
              final item = activities[index];
              final isPaid = item.amount > 0;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.person_add_rounded, color: AppTheme.primaryGreen, size: 20),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              color: AppTheme.grey900,
                            ),
                          ),
                          Text(
                            item.date,
                            style: const TextStyle(
                              fontSize: 11,
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
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                              color: AppTheme.success,
                            ),
                          ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: (isPaid ? AppTheme.success : AppTheme.grey400).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item.status.toUpperCase(),
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: isPaid ? AppTheme.success : AppTheme.grey400,
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
