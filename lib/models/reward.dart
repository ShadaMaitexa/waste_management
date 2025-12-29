import 'package:flutter/foundation.dart';

class Reward {
  final String id;
  final String userId;
  final int points;
  final RewardType type;
  final String title;
  final String description;
  final String? icon;
  final DateTime earnedAt;
  final DateTime? redeemedAt;
  final String? rewardItem;
  final double? monetaryValue;

  Reward({
    required this.id,
    required this.userId,
    required this.points,
    required this.type,
    required this.title,
    required this.description,
    this.icon,
    required this.earnedAt,
    this.redeemedAt,
    this.rewardItem,
    this.monetaryValue,
  });

  factory Reward.fromJson(Map<String, dynamic> json) {
    return Reward(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      points: json['points'] ?? 0,
      type: RewardType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => RewardType.points,
      ),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'],
      earnedAt: DateTime.parse(json['earnedAt']),
      redeemedAt: json['redeemedAt'] != null ? DateTime.parse(json['redeemedAt']) : null,
      rewardItem: json['rewardItem'],
      monetaryValue: json['monetaryValue']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'points': points,
      'type': type.toString().split('.').last,
      'title': title,
      'description': description,
      'icon': icon,
      'earnedAt': earnedAt.toIso8601String(),
      'redeemedAt': redeemedAt?.toIso8601String(),
      'rewardItem': rewardItem,
      'monetaryValue': monetaryValue,
    };
  }

  Reward copyWith({
    String? id,
    String? userId,
    int? points,
    RewardType? type,
    String? title,
    String? description,
    String? icon,
    DateTime? earnedAt,
    DateTime? redeemedAt,
    String? rewardItem,
    double? monetaryValue,
  }) {
    return Reward(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      points: points ?? this.points,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      earnedAt: earnedAt ?? this.earnedAt,
      redeemedAt: redeemedAt ?? this.redeemedAt,
      rewardItem: rewardItem ?? this.rewardItem,
      monetaryValue: monetaryValue ?? this.monetaryValue,
    );
  }

  bool get isRedeemed => redeemedAt != null;
  bool get isPending => !isRedeemed;
}

enum RewardType { points, badge, coupon, cashback, discount }

class UserRewards {
  final String userId;
  final int totalPoints;
  final List<Reward> rewards;
  final int badgesEarned;
  final int couponsRedeemed;
  final double totalSavings;

  UserRewards({
    required this.userId,
    required this.totalPoints,
    required this.rewards,
    required this.badgesEarned,
    required this.couponsRedeemed,
    required this.totalSavings,
  });

  factory UserRewards.fromJson(Map<String, dynamic> json) {
    return UserRewards(
      userId: json['userId'] ?? '',
      totalPoints: json['totalPoints'] ?? 0,
      rewards: (json['rewards'] as List).map((e) => Reward.fromJson(e)).toList(),
      badgesEarned: json['badgesEarned'] ?? 0,
      couponsRedeemed: json['couponsRedeemed'] ?? 0,
      totalSavings: (json['totalSavings'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'totalPoints': totalPoints,
      'rewards': rewards.map((e) => e.toJson()).toList(),
      'badgesEarned': badgesEarned,
      'couponsRedeemed': couponsRedeemed,
      'totalSavings': totalSavings,
    };
  }

  UserRewards copyWith({
    String? userId,
    int? totalPoints,
    List<Reward>? rewards,
    int? badgesEarned,
    int? couponsRedeemed,
    double? totalSavings,
  }) {
    return UserRewards(
      userId: userId ?? this.userId,
      totalPoints: totalPoints ?? this.totalPoints,
      rewards: rewards ?? this.rewards,
      badgesEarned: badgesEarned ?? this.badgesEarned,
      couponsRedeemed: couponsRedeemed ?? this.couponsRedeemed,
      totalSavings: totalSavings ?? this.totalSavings,
    );
  }
}
