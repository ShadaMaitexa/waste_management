import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../services/auth_service.dart';
import '../../services/pickup_service.dart';
import '../../services/reward_service.dart';
import '../../theme/app_theme.dart';

import 'book_pickup_screen.dart';
import 'rewards_screen.dart';
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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PickupService()),
        ChangeNotifierProvider(create: (_) => RewardService()),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('GreenLoop'),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: _showNotifications,
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                Provider.of<AuthService>(context, listen: false).logout();
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() => _selectedIndex = index);
          },
          children: [
            _buildDashboardTab(),
            const BookPickupScreen(),
            const RewardsScreen(),
            const ProfileScreen(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppTheme.primaryGreen,
          unselectedItemColor: AppTheme.grey500,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.schedule_outlined),
              activeIcon: Icon(Icons.schedule),
              label: 'Book Pickup',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.stars_outlined),
              activeIcon: Icon(Icons.stars),
              label: 'Rewards',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardTab() {
    return Consumer2<PickupService, RewardService>(
      builder: (context, pickupService, rewardService, _) {
        final pickups = pickupService.getUpcomingPickupsForUser('user1');
        final stats = rewardService.getRewardsStatistics('user1');

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeCard(),
              const SizedBox(height: AppTheme.spacingM),
              _buildQuickStats(stats),
              const SizedBox(height: AppTheme.spacingM),
              if (pickups.isNotEmpty) _buildNextPickupCard(pickups.first),
              const SizedBox(height: AppTheme.spacingM),
              _buildRecentActivity(rewardService),
              const SizedBox(height: AppTheme.spacingM),
              _buildQuickActions(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back, John!',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Ward 15, Kozhikode',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(Map<String, dynamic> stats) {
    return Row(
      children: [
        _stat('Points', stats['totalPoints'] ?? 0, Icons.stars),
        _stat('Level', stats['level'] ?? 1, Icons.emoji_events),
        _stat('Badges', stats['badgesEarned'] ?? 0, Icons.workspace_premium),
      ],
    );
  }

  Widget _stat(String title, dynamic value, IconData icon) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(icon, color: AppTheme.primaryGreen),
              const SizedBox(height: 6),
              Text(
                '$value',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(title),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNextPickupCard(dynamic pickup) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Next Pickup',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              pickup.scheduledDate != null
                  ? DateFormat('EEE, MMM d')
                      .format(pickup.scheduledDate!)
                  : 'Date TBD',
            ),
            const SizedBox(height: 4),
            Text(pickup.formattedTime ?? 'Time TBD'),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity(RewardService rewardService) {
    final rewards = rewardService.getRecentActivity('user1', limit: 3);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Activity',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (rewards.isEmpty)
              const Text('No recent activity')
            else
              ...rewards.map(
                (r) => ListTile(
                  leading: const Icon(Icons.stars),
                  title: Text(r.title),
                  subtitle: Text(r.description),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => _onItemTapped(1),
            child: const Text('Emergency Pickup'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton(
            onPressed: _reportIssue,
            child: const Text('Report Issue'),
          ),
        ),
      ],
    );
  }

  void _showNotifications() {
    showDialog(
      context: context,
      builder: (_) => const AlertDialog(
        title: Text('Notifications'),
        content: Text('No new notifications'),
      ),
    );
  }

  void _reportIssue() {
    showDialog(
      context: context,
      builder: (_) => const AlertDialog(
        title: Text('Report Issue'),
        content: Text('Feature coming soon'),
      ),
    );
  }
}
