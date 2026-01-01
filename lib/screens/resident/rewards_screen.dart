import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/reward_service.dart';
import '../../theme/app_theme.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.grey50,
      appBar: AppBar(
        title: const Text('Green Rewards'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: AppTheme.grey900,
        elevation: 0,
      ),
      body: Consumer<RewardService>(
        builder: (context, rewardService, child) {
          final stats = rewardService.getRewardsStatistics('user1');
          
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingM),
                  child: Column(
                    children: [
                      _buildBalanceCard(stats),
                      const SizedBox(height: AppTheme.spacingL),
                      _buildSectionTitle('Redeem Points'),
                      _buildRewardsGrid(),
                      const SizedBox(height: AppTheme.spacingL),
                      _buildSectionTitle('History'),
                    ],
                  ),
                ),
              ),
              _buildHistoryList(rewardService),
              const SliverPadding(padding: EdgeInsets.only(bottom: 20)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBalanceCard(Map<String, dynamic> stats) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFFFA000)], // Gold gradient
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFA000).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.stars, color: Colors.white, size: 48),
          const SizedBox(height: 12),
          Text(
            '${stats['totalPoints']}',
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1,
            ),
          ),
          const Text(
            'Green Points Balance',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildMiniStat('Lifetime Earned', '5,400'),
              Container(width: 1, height: 30, color: Colors.white30, margin: const EdgeInsets.symmetric(horizontal: 24)),
              _buildMiniStat('Level', '${stats['level']}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12, left: 4),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.grey900,
          ),
        ),
      ),
    );
  }

  Widget _buildRewardsGrid() {
    final rewards = [
      {'name': '₹50 OFF Bill', 'points': 500, 'icon': Icons.receipt_long, 'color': Colors.blue},
      {'name': 'Eco Bag', 'points': 800, 'icon': Icons.shopping_bag, 'color': Colors.green},
      {'name': 'Movie Ticket', 'points': 1500, 'icon': Icons.movie, 'color': Colors.purple},
      {'name': 'Gift Card', 'points': 2000, 'icon': Icons.card_giftcard, 'color': Colors.red},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: rewards.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemBuilder: (context, index) {
        final item = rewards[index];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.grey200),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (item['color'] as Color).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(item['icon'] as IconData, color: item['color'] as Color, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                item['name'] as String,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(
                '${item['points']} pts',
                style: const TextStyle(
                  color: AppTheme.primaryGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHistoryList(RewardService rewardService) {
    // Mock Data
    final history = [
      {'title': 'Pickup Bonus', 'date': 'Today', 'points': '+50', 'isCredit': true},
      {'title': 'Redeemed Eco Bag', 'date': 'Yesterday', 'points': '-800', 'isCredit': false},
      {'title': 'Weekly Streak', 'date': 'Aug 20', 'points': '+100', 'isCredit': true},
    ];

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final item = history[index];
          final isCredit = item['isCredit'] as bool;
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isCredit ? AppTheme.success.withOpacity(0.1) : AppTheme.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                  color: isCredit ? AppTheme.success : AppTheme.error,
                  size: 20,
                ),
              ),
              title: Text(item['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(item['date'] as String),
              trailing: Text(
                item['points'] as String,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isCredit ? AppTheme.success : AppTheme.grey900,
                ),
              ),
            ),
          );
        },
        childCount: history.length,
      ),
    );
  }
}
