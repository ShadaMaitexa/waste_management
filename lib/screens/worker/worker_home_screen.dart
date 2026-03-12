import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        physics: const NeverScrollableScrollPhysics(), // Disable swipe to prevent conflict with maps
        children: [
          _DashboardTab(onNavigate: _onItemTapped), // Dashboard is internal class
          const WorkerRoutePlannerScreen(),
          const WorkerAttendanceScreen(),
          const WorkerProfileScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: NavigationBar(
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
              icon: Icon(Icons.map_outlined),
              selectedIcon: Icon(Icons.map, color: AppTheme.primaryGreen),
              label: 'Route',
            ),
            NavigationDestination(
              icon: Icon(Icons.fact_check_outlined),
              selectedIcon: Icon(Icons.fact_check, color: AppTheme.primaryGreen),
              label: 'Attendance',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person, color: AppTheme.primaryGreen),
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
        final workerName = authService.currentUserName ?? 'Worker';
        final workerId = authService.currentUser?.id ?? '';
        final todaysPickups = pickupService.getTodaysPickupsForWorker(workerId);
        final pendingCount = todaysPickups.where((p) => p.status == PickupStatus.scheduled).length;
        final completedCount = todaysPickups.where((p) => p.status == PickupStatus.completed).length;
        final currentPickup = todaysPickups.isEmpty ? null : todaysPickups.firstWhere((p) => p.status == PickupStatus.inProgress, orElse: () => todaysPickups.first);

        return Scaffold(
          backgroundColor: AppTheme.grey50,
          body: RefreshIndicator(
            onRefresh: () => pickupService.fetchPickups(),
            child: CustomScrollView(
              slivers: [
                _buildSliverAppBar(context),
                SliverPadding(
                  padding: const EdgeInsets.all(AppTheme.spacingM),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildWelcomeSection(context, workerName),
                      const SizedBox(height: AppTheme.spacingL),
                      _buildStatsGrid(context, pendingCount, completedCount),
                      const SizedBox(height: AppTheme.spacingL),
                      _buildCurrentTaskCard(context, currentPickup),
                      const SizedBox(height: AppTheme.spacingL),
                      _buildQuickActions(context),
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

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 80.0,
      floating: true,
      pinned: true,
      elevation: 0,
      backgroundColor: AppTheme.primaryGreen,
      title: const Text('GreenLoop Worker'),
      centerTitle: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () {
            Provider.of<AuthService>(context, listen: false).logout();
            Navigator.of(context).pushReplacementNamed('/login');
          },
        ),
      ],
    );
  }

  Widget _buildWelcomeSection(BuildContext context, String name) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Good Morning,',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.grey600,
              ),
        ),
        Text(
          name,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.grey900,
              ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(BuildContext context, int pending, int completed) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            'Pending',
            pending.toString(),
            Icons.pending_actions,
            AppTheme.warning,
            Colors.orange.shade50,
          ),
        ),
        const SizedBox(width: AppTheme.spacingM),
        Expanded(
          child: _buildStatCard(
            context,
            'Completed',
            completed.toString(),
            Icons.task_alt,
            AppTheme.success,
            Colors.green.shade50,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value,
      IconData icon, Color color, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: AppTheme.spacingM),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.grey900,
                ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.grey600,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentTaskCard(BuildContext context, Pickup? pickup) {
    if (pickup == null) {
      return Container(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusL),
          border: Border.all(color: AppTheme.grey200),
        ),
        child: const Center(child: Text('No pickups assigned today')),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Current Route',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            TextButton(
              onPressed: () => onNavigate(1), // Go to Route tab
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingS),
        Container(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.primaryGreen, AppTheme.secondaryGreen],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppTheme.radiusL),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryGreen.withOpacity(0.3),
                blurRadius: 12,
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Ward ${pickup.wardNumber}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios,
                      color: Colors.white, size: 16),
                ],
              ),
              const SizedBox(height: AppTheme.spacingL),
              Text(
                'Next Pickup: ${pickup.address}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppTheme.spacingS),
              Row(
                children: [
                  const Icon(Icons.access_time, color: Colors.white70, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Est. ${pickup.formattedTime}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.delete_outline,
                      color: Colors.white70, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    pickup.wasteTypes.map((e) => e.toString().split('.').last).join(', '),
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      {'icon': Icons.add_a_photo, 'label': 'Report', 'route': ''},
      {'icon': Icons.history, 'label': 'History', 'route': ''},
      {'icon': Icons.support_agent, 'label': 'Support', 'route': ''},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AppTheme.spacingM),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: actions.map((action) {
            return Column(
              children: [
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      action['icon'] as IconData,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingS),
                Text(
                  action['label'] as String,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}
