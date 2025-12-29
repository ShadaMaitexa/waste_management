import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/reward_service.dart';
import '../../theme/app_theme.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rewards & Points'),
        elevation: 0,
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: Consumer<RewardService>(
        builder: (context, rewardService, child) {
          final stats = rewardService.getRewardsStatistics('user1');
          final recentRewards = rewardService.getRecentActivity('user1', limit: 10);
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPointsCard(stats, context),
                const SizedBox(height: AppTheme.spacingM),
                _buildLevelProgress(stats, context),
                const SizedBox(height: AppTheme.spacingM),
                _buildRewardsList(recentRewards, context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPointsCard(Map<String, dynamic> stats, BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
      ),
      child: Column(
        children: [
          const Icon(Icons.stars, color: Colors.white, size: 48),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            '${stats['totalPoints']}',
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Text(
            'GreenLeaf Points',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStat('Level', '${stats['level']}'),
              _buildStat('Badges', '${stats['badgesEarned']}'),
              _buildStat('Saved', '₹${stats['totalSavings']}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildLevelProgress(Map<String, dynamic> stats, BuildContext context) {
    final nextLevelPoints = stats['nextLevelPoints'];
    final progress = ((500 - nextLevelPoints) / 500).clamp(0.0, 1.0);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Level Progress',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTheme.spacingM),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: AppTheme.grey300,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
            ),
            const SizedBox(height: AppTheme.spacingS),
            Text(
              '$nextLevelPoints points to next level',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.grey600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardsList(List<dynamic> rewards, BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Rewards',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTheme.spacingM),
            if (rewards.isEmpty)
              const Text('No rewards yet. Book a pickup to start earning!')
            else
              ...rewards.map((reward) => ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.accentGreen,
                  child: Icon(
                    _getRewardIcon(reward.type),
                    color: Colors.white,
                  ),
                ),
                title: Text(reward.title),
                subtitle: Text(reward.description),
                trailing: Text('+${reward.points} pts'),
              )),
          ],
        ),
      ),
    );
  }

  IconData _getRewardIcon(dynamic type) {
    switch (type.toString()) {
      case 'RewardType.points':
        return Icons.stars;
      case 'RewardType.badge':
        return Icons.workspace_premium;
      case 'RewardType.coupon':
        return Icons.local_offer;
      default:
        return Icons.card_giftcard;
    }
  }
}
