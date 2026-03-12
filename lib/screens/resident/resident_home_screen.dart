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
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        backgroundColor: Colors.white,
        indicatorColor: AppTheme.primaryGreen.withOpacity(0.1),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard, color: AppTheme.primaryGreen),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.schedule_outlined),
            selectedIcon: Icon(Icons.schedule, color: AppTheme.primaryGreen),
            label: 'Book Pickup',
          ),
          NavigationDestination(
            icon: Icon(Icons.share_outlined),
            selectedIcon: Icon(Icons.share, color: AppTheme.primaryGreen),
            label: 'Refer & Earn',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: AppTheme.primaryGreen),
            label: 'Profile',
          ),
        ],
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
        final stats = {
          'referralCount': referralService.referralCount,
          'totalEarned': referralService.totalEarned,
        };

        return Scaffold(
          backgroundColor: AppTheme.grey50,
          body: RefreshIndicator(
            onRefresh: () => pickupService.fetchPickups(),
            child: CustomScrollView(
              slivers: [
                _buildSliverAppBar(context, userName),
                SliverPadding(
                  padding: const EdgeInsets.all(AppTheme.spacingM),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildNextPickupCard(context, pickups.isNotEmpty ? pickups.first : null),
                      const SizedBox(height: AppTheme.spacingL),
                      _buildStatsOverview(context, stats),
                      const SizedBox(height: AppTheme.spacingL),
                      _buildQuickActionsGrid(context),
                      const SizedBox(height: AppTheme.spacingL),
                      _buildRecentActivity(context, referralService),
                      const SizedBox(height: AppTheme.spacingL), // Bottom padding
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

  Widget _buildSliverAppBar(BuildContext context, String userName) {
    return SliverAppBar(
      expandedHeight: 180.0,
      floating: false,
      pinned: true,
      backgroundColor: AppTheme.primaryGreen,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
                gradient: LinearGradient(
                  colors: [AppTheme.primaryGreen, AppTheme.secondaryGreen],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            Positioned(
              right: -30,
              top: -20,
              child: Icon(
                Icons.eco_rounded,
                size: 180,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, bottom: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome back,',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    userName,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.white70, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        'Ward 15, Kozhikode',
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 12,
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
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.white),
          onPressed: () => Navigator.pushNamed(context, '/notifications'),
        ),
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.white),
          onPressed: () {
            Provider.of<AuthService>(context, listen: false).logout();
            Navigator.pushReplacementNamed(context, '/login');
          },
        ),
      ],
    );
  }

  Widget _buildNextPickupCard(BuildContext context, dynamic pickup) {
    // If no pickup, show "Schedule Now" card
    if (pickup == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppTheme.grey300.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.schedule_rounded, color: AppTheme.primaryGreen, size: 28),
            ),
            const SizedBox(width: AppTheme.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'No Pending Pickups',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppTheme.grey900,
                          letterSpacing: -0.5,
                        ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Schedule a waste pickup now.',
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text('Book'),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E7D32), Color(0xFF43A047)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGreen.withOpacity(0.4),
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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.access_time, color: Colors.white, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'UPCOMING',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward, color: Colors.white70, size: 16),
            ],
          ),
          const SizedBox(height: AppTheme.spacingM),
          const Text(
            'Next Pickup Scheduled',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                pickup.formattedTime ?? '10:00 AM', // Fallback
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                pickup.scheduledDate != null
                    ? DateFormat('EEE, MMM d').format(pickup.scheduledDate!)
                    : 'Tomorrow',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingM),
          Row(
            children: [
              _pickupTag(Icons.delete_outline, 'Dry Waste'),
              const SizedBox(width: 8),
              _pickupTag(Icons.recycling, 'Plastic'),
            ],
          ),
        ],
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

  Widget _buildStatsOverview(BuildContext context, Map<String, dynamic> stats) {
    return Row(
      children: [
        Expanded(
          child: _expressCard(context),
        ),
        const SizedBox(width: AppTheme.spacingM),
        Expanded(
          child: _statCard(
            context,
            'Kg Collected',
            '24.5', // Mock data
            Icons.scale,
            AppTheme.info,
          ),
        ),
      ],
    );
  }

  Widget _expressCard(BuildContext context) {
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
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1976D2).withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
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
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.local_shipping,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Colors.greenAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'LIVE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingM),
            const Text(
              'Express',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Text(
                  'Track Truck',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward,
                  color: Colors.white70,
                  size: 12,
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
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.grey300.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: AppTheme.spacingM),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.grey900,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.grey600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsGrid(BuildContext context) {
    final actions = [
      {'icon': Icons.add_circle_outline, 'label': 'Book', 'index': 1},
      {'icon': Icons.history, 'label': 'History', 'index': -1}, // TODO: Link to history
      {'icon': Icons.support_agent, 'label': 'Support', 'index': -1},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.grey900,
          ),
        ),
        const SizedBox(height: AppTheme.spacingM),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 0.8,
            crossAxisSpacing: AppTheme.spacingM,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final action = actions[index];
            return GestureDetector(
              onTap: () {
                final navIndex = action['index'] as int;
                if (navIndex != -1) {
                  onNavigate(navIndex);
                }
              },
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.grey300.withOpacity(0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      action['icon'] as IconData,
                      color: AppTheme.primaryGreen,
                      size: 26,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    action['label'] as String,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.grey700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          },
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
              'Recent Activity',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.grey900,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingS),
        Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusM)),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activities.isEmpty ? 3 : activities.length,
            separatorBuilder: (_, __) => Divider(color: AppTheme.grey100, height: 1),
            itemBuilder: (context, index) {
              final item = activities[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.primaryGreen.withOpacity(0.1),
                  child: const Icon(Icons.person_add_rounded, color: AppTheme.primaryGreen, size: 20),
                ),
                title: Text(item.name),
                subtitle: Text('Status: ${item.status}'),
                trailing: Text(
                  item.date,
                  style: const TextStyle(color: AppTheme.grey500, fontSize: 12),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
