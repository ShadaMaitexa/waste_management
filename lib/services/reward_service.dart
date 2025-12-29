import 'package:flutter/foundation.dart';
import '../models/reward.dart';

class RewardService extends ChangeNotifier {
  final Map<String, UserRewards> _userRewards = {};
  
  List<UserRewards> get allUserRewards => _userRewards.values.toList();

  // Mock data initialization
  void _initializeMockData() {
    if (_userRewards.isNotEmpty) return;

    final now = DateTime.now();
    
    // Mock rewards for user1
    final user1Rewards = UserRewards(
      userId: 'user1',
      totalPoints: 1250,
      badgesEarned: 5,
      couponsRedeemed: 12,
      totalSavings: 850.50,
      rewards: [
        Reward(
          id: '1',
          userId: 'user1',
          points: 50,
          type: RewardType.points,
          title: 'Perfect Segregation',
          description: 'Earned for proper waste segregation',
          earnedAt: now.subtract(const Duration(days: 1)),
          monetaryValue: 5.0,
        ),
        Reward(
          id: '2',
          userId: 'user1',
          points: 100,
          type: RewardType.badge,
          title: 'Green Champion',
          description: 'First 10 pickups completed',
          icon: '🏆',
          earnedAt: now.subtract(const Duration(days: 5)),
          monetaryValue: 0,
        ),
        Reward(
          id: '3',
          userId: 'user1',
          points: 0,
          type: RewardType.coupon,
          title: '₹50 Shopping Coupon',
          description: 'Valid at partner stores',
          earnedAt: now.subtract(const Duration(days: 10)),
          redeemedAt: now.subtract(const Duration(days: 2)),
          rewardItem: 'Big Bazaar ₹50 Off',
          monetaryValue: 50.0,
        ),
      ],
    );

    _userRewards['user1'] = user1Rewards;
  }

  RewardService() {
    _initializeMockData();
  }

  // Get rewards for a specific user
  UserRewards? getUserRewards(String userId) {
    return _userRewards[userId];
  }

  // Get user's total points
  int getUserPoints(String userId) {
    return _userRewards[userId]?.totalPoints ?? 0;
  }

  // Add points to user
  Future<bool> addPoints(String userId, int points, String title, String description) async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 300));

    if (!_userRewards.containsKey(userId)) {
      _userRewards[userId] = UserRewards(
        userId: userId,
        totalPoints: 0,
        rewards: [],
        badgesEarned: 0,
        couponsRedeemed: 0,
        totalSavings: 0,
      );
    }

    final userRewards = _userRewards[userId]!;
    final newReward = Reward(
      id: 'reward_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      points: points,
      type: RewardType.points,
      title: title,
      description: description,
      earnedAt: DateTime.now(),
      monetaryValue: points / 10.0, // 1 point = ₹0.10
    );

    final updatedRewards = List<Reward>.from(userRewards.rewards)
      ..insert(0, newReward);

    _userRewards[userId] = userRewards.copyWith(
      totalPoints: userRewards.totalPoints + points,
      rewards: updatedRewards,
    );

    notifyListeners();
    return true;
  }

  // Award badge
  Future<bool> awardBadge(String userId, String title, String description, String icon) async {
    await Future.delayed(const Duration(milliseconds: 300));

    if (!_userRewards.containsKey(userId)) {
      _userRewards[userId] = UserRewards(
        userId: userId,
        totalPoints: 0,
        rewards: [],
        badgesEarned: 0,
        couponsRedeemed: 0,
        totalSavings: 0,
      );
    }

    final userRewards = _userRewards[userId]!;
    final newReward = Reward(
      id: 'badge_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      points: 0,
      type: RewardType.badge,
      title: title,
      description: description,
      icon: icon,
      earnedAt: DateTime.now(),
      monetaryValue: 0,
    );

    final updatedRewards = List<Reward>.from(userRewards.rewards)
      ..insert(0, newReward);

    _userRewards[userId] = userRewards.copyWith(
      rewards: updatedRewards,
      badgesEarned: userRewards.badgesEarned + 1,
    );

    notifyListeners();
    return true;
  }

  // Redeem coupon
  Future<bool> redeemCoupon(String userId, String rewardId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final userRewards = _userRewards[userId];
    if (userRewards == null) return false;

    final rewardIndex = userRewards.rewards.indexWhere((r) => r.id == rewardId);
    if (rewardIndex == -1) return false;

    final reward = userRewards.rewards[rewardIndex];
    if (reward.isRedeemed) return false;

    final updatedRewards = List<Reward>.from(userRewards.rewards);
    updatedRewards[rewardIndex] = reward.copyWith(
      redeemedAt: DateTime.now(),
    );

    _userRewards[userId] = userRewards.copyWith(
      rewards: updatedRewards,
      couponsRedeemed: userRewards.couponsRedeemed + 1,
      totalSavings: userRewards.totalSavings + (reward.monetaryValue ?? 0),
    );

    notifyListeners();
    return true;
  }

  // Get available rewards for redemption
  List<Reward> getAvailableRewards(String userId) {
    final userRewards = _userRewards[userId];
    if (userRewards == null) return [];

    return userRewards.rewards.where((reward) => reward.isPending).toList();
  }

  // Get recent activity
  List<Reward> getRecentActivity(String userId, {int limit = 5}) {
    final userRewards = _userRewards[userId];
    if (userRewards == null) return [];

    return userRewards.rewards.take(limit).toList();
  }

  // Calculate user's level based on points
  int getUserLevel(String userId) {
    final points = getUserPoints(userId);
    return (points / 500).floor() + 1; // Level up every 500 points
  }

  // Get points needed for next level
  int getPointsForNextLevel(String userId) {
    final currentLevel = getUserLevel(userId);
    final currentPoints = getUserPoints(userId);
    final nextLevelPoints = currentLevel * 500;
    return nextLevelPoints - currentPoints;
  }

  // Get leaderboard (mock implementation)
  List<Map<String, dynamic>> getLeaderboard() {
    return [
      {'name': 'John Doe', 'points': 1250, 'rank': 1},
      {'name': 'Jane Smith', 'points': 980, 'rank': 2},
      {'name': 'Mike Johnson', 'points': 750, 'rank': 3},
      {'name': 'Sarah Wilson', 'points': 620, 'rank': 4},
      {'name': 'Alex Brown', 'points': 580, 'rank': 5},
    ];
  }

  // Get rewards statistics
  Map<String, dynamic> getRewardsStatistics(String userId) {
    final userRewards = _userRewards[userId];
    if (userRewards == null) {
      return {
        'totalPoints': 0,
        'badgesEarned': 0,
        'couponsRedeemed': 0,
        'totalSavings': 0.0,
        'level': 1,
        'nextLevelPoints': 500,
      };
    }

    return {
      'totalPoints': userRewards.totalPoints,
      'badgesEarned': userRewards.badgesEarned,
      'couponsRedeemed': userRewards.couponsRedeemed,
      'totalSavings': userRewards.totalSavings,
      'level': getUserLevel(userId),
      'nextLevelPoints': getPointsForNextLevel(userId),
    };
  }
}
