import 'package:flutter/foundation.dart';

class ReferralService extends ChangeNotifier {
  final String _referralCode = "GREENLOOP2024";
  final int _referralCount = 12;
  final double _totalEarned = 150.0;

  String get referralCode => _referralCode;
  int get referralCount => _referralCount;
  double get totalEarned => _totalEarned;

  List<ReferralHistory> getReferralHistory() {
    return [
      ReferralHistory(name: "Rahul Sharma", date: "2 hours ago", amount: 20.0, status: "Success"),
      ReferralHistory(name: "Amit Patel", date: "Yesterday", amount: 15.0, status: "Success"),
      ReferralHistory(name: "Sneha Reddy", date: "2 days ago", amount: 20.0, status: "Success"),
      ReferralHistory(name: "Vijay Kumar", date: "5 days ago", amount: 0.0, status: "Pending"),
    ];
  }

  Future<void> shareReferral() async {
    // In a real app, this would use the share_plus package
    await Future.delayed(const Duration(milliseconds: 500));
  }
}

class ReferralHistory {
  final String name;
  final String date;
  final double amount;
  final String status;

  ReferralHistory({
    required this.name,
    required this.date,
    required this.amount,
    required this.status,
  });
}
