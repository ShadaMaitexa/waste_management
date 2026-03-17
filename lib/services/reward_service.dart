import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/reward.dart';
import '../utils/api_constants.dart';
import 'auth_service.dart';

class RewardService extends ChangeNotifier {
  final AuthService _authService;
  Map<String, UserRewards> _userRewards = {};
  List<Map<String, dynamic>> _leaderboard = [];
  bool _isLoading = false;

  RewardService(this._authService);

  List<UserRewards> get allUserRewards => _userRewards.values.toList();
  bool get isLoading => _isLoading;

  Future<void> fetchUserRewards(String userId) async {
    if (!_authService.isAuthenticated) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse(ApiConstants.rewards),
        headers: {'Authorization': 'Bearer ${_authService.token}'},
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Assuming API returns a UserRewards JSON structure for the current user
        // Adjust based on your API's actual return format
        final rewards = UserRewards(
          userId: userId,
          totalPoints: data['total_points'] ?? 0,
          badgesEarned: data['badges_earned'] ?? 0,
          couponsRedeemed: data['coupons_redeemed'] ?? 0,
          totalSavings: (data['total_savings'] as num?)?.toDouble() ?? 0.0,
          rewards: (data['history'] as List?)?.map((r) => Reward(
                 id: r['id'].toString(),
                 userId: userId,
                 points: r['points'] ?? 0,
                 type: RewardType.values.firstWhere((e) => e.name == r['type'], orElse: () => RewardType.points),
                 title: r['title'] ?? '',
                 description: r['description'] ?? '',
                 earnedAt: DateTime.parse(r['earned_at']),
                 monetaryValue: (r['monetary_value'] as num?)?.toDouble() ?? 0.0,
                 icon: r['icon'],
                 rewardItem: r['reward_item'],
                 redeemedAt: r['redeemed_at'] != null ? DateTime.parse(r['redeemed_at']) : null,
              )).toList() ?? [],
        );
        _userRewards[userId] = rewards;
      }
    } catch (e) {
      debugPrint('Error fetching rewards: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchLeaderboard() async {
    if (!_authService.isAuthenticated) return;
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.rewardsLeaderboard),
        headers: {'Authorization': 'Bearer ${_authService.token}'},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _leaderboard = data.map((item) => item as Map<String, dynamic>).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching leaderboard: $e');
    }
  }

  UserRewards? getUserRewards(String userId) {
    return _userRewards[userId];
  }

  int getUserPoints(String userId) {
    return _userRewards[userId]?.totalPoints ?? 0;
  }

  // Award points/badges via API 
  Future<bool> awardPoints(String userId, int points, String title, String description) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.rewards}award/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_authService.token}'
        },
        body: jsonEncode({
          'points': points,
          'title': title,
          'description': description,
          'type': 'points',
        }),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        await fetchUserRewards(userId);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error awarding points: $e');
      return false;
    }
  }

  Future<bool> redeemCoupon(String userId, String rewardId) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.rewards}redeem/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_authService.token}'
        },
        body: jsonEncode({'reward_id': rewardId}),
      );
      if (response.statusCode == 200) {
        await fetchUserRewards(userId);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error redeeming coupon: $e');
      return false;
    }
  }

  List<Reward> getAvailableRewards(String userId) {
    return _userRewards[userId]?.rewards.where((reward) => reward.isPending).toList() ?? [];
  }

  List<Reward> getRecentActivity(String userId, {int limit = 5}) {
    return _userRewards[userId]?.rewards.take(limit).toList() ?? [];
  }

  int getUserLevel(String userId) {
    final points = getUserPoints(userId);
    return (points / 500).floor() + 1;
  }

  int getPointsForNextLevel(String userId) {
    final currentLevel = getUserLevel(userId);
    final currentPoints = getUserPoints(userId);
    return (currentLevel * 500) - currentPoints;
  }

  List<Map<String, dynamic>> getLeaderboard() {
    return _leaderboard;
  }

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
