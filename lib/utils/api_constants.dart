class ApiConstants {
  static const String baseUrl = 'https://waste-management-backend-1.onrender.com';
  static const String wards = '$baseUrl/api/wards/';
  
  // Auth Endpoints
  static const String login = '$baseUrl/api/auth/login/';
  static const String register = '$baseUrl/api/auth/register/';
  static const String profile = '$baseUrl/api/auth/profile/';
  static const String forgotPassword = '$baseUrl/api/auth/forgot-password/';
  static const String resetPassword = '$baseUrl/api/auth/reset-password/'; // {uid}/{token}/ to be appended
  static const String createHksWorker = '$baseUrl/api/auth/create-hks-worker/';
  static const String users = '$baseUrl/api/auth/users/';
  
  // Dashboard Endpoints
  static const String dashboard = '$baseUrl/api/auth/dashboard/';
  static const String complaintsStats = '$baseUrl/api/auth/dashboard/complaints/';
  static const String feesStats = '$baseUrl/api/auth/dashboard/fees/';
  static const String liveMap = '$baseUrl/api/auth/dashboard/live-map/';
  static const String wardMonitoring = '$baseUrl/api/auth/dashboard/ward-monitoring/';
  static const String wasteReports = '$baseUrl/api/auth/dashboard/waste-reports/';
  
  // Complaints Endpoints
  static const String complaints = '$baseUrl/api/complaints/';
  static const String complaintsPresignedUrl = '$baseUrl/api/complaints/presigned-url/';
  
  // Notifications Endpoints
  static const String notifications = '$baseUrl/api/notifications/';
  
  // Pickups Endpoints
  static const String pickups = '$baseUrl/api/pickups/';
  static const String availableWorkers = '$baseUrl/api/pickups/available-workers/';
  
  // Pickup Slots Endpoints
  static const String pickupSlots = '$baseUrl/api/pickup-slots/';
  static const String availableDates = '$baseUrl/api/pickup-slots/available-dates/';

  // Worker Endpoints
  static const String workerShifts = '$baseUrl/api/worker-shifts/';
  static const String workerAttendance = '$baseUrl/api/worker-attendance/';
  static const String workerStats = '$baseUrl/api/worker-stats/';

  // Rewards Endpoints
  static const String rewards = '$baseUrl/api/rewards/';
  static const String rewardsHistory = '$baseUrl/api/rewards/history/';
  static const String rewardsLeaderboard = '$baseUrl/api/rewards/leaderboard/';

  // Referrals Endpoints
  static const String referrals = '$baseUrl/api/referrals/';

  // Schema
  static const String schema = '$baseUrl/api/schema/';
}
