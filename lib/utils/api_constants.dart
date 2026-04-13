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

  // HKS API: Attendance & Daily Tracking
  static const String hksAttendance = '$baseUrl/api/v1/hks/attendance/';
  static const String hksActiveRoute = '$baseUrl/api/v1/hks/routes/today/';

  // HKS API: Waste Pickup & Verification
  static const String hksPickups = '$baseUrl/api/v1/pickups/';
  static String hksPickupComplete(String id) => '$baseUrl/api/v1/pickups/$id/complete/';
  static String hksPickupCancel(String id) => '$baseUrl/api/v1/pickups/$id/cancel/';
  static String hksPickupVerify(String id) => '$baseUrl/api/v1/pickups/$id/verify_scan/';

  // HKS API: Complaints & Issue Reporting
  static const String hksComplaints = '$baseUrl/api/v1/complaints/';
  static String hksComplaintResolve(String id) => '$baseUrl/api/v1/complaints/$id/advance_status/';

  // HKS API: Payments & Fee Collection
  static const String hksPayments = '$baseUrl/api/v1/payments/';
  static const String hksPaymentsSummary = '$baseUrl/api/v1/payments/summary/';
  static String hksPaymentCorrect(String id) => '$baseUrl/api/v1/payments/$id/';

  // HKS API: Authentication & Worker Login
  static const String hksWorkerLogin = '$baseUrl/api/v1/auth/worker-login/';
  static const String hksAuthPing = '$baseUrl/api/v1/auth/ping/';
  static const String hksLogout = '$baseUrl/api/v1/auth/logout/';

  // Rewards Endpoints
  static const String rewards = '$baseUrl/api/rewards/';
  static const String rewardsHistory = '$baseUrl/api/rewards/history/';
  static const String rewardsLeaderboard = '$baseUrl/api/rewards/leaderboard/';

  // Referrals Endpoints
  static const String referrals = '$baseUrl/api/referrals/';

  // Schema
  static const String schema = '$baseUrl/api/schema/';
}
