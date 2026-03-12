class ApiConstants {
  static const String baseUrl = 'https://waste-management-backend-1.onrender.com';
  
  // Auth Endpoints
  static const String login = '$baseUrl/api/auth/login/';
  static const String register = '$baseUrl/api/auth/register/';
  static const String profile = '$baseUrl/api/auth/profile/';
  static const String forgotPassword = '$baseUrl/api/auth/forgot-password/';
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
  
  // Notifications Endpoints
  static const String notifications = '$baseUrl/api/notifications/';
  
  // Pickups Endpoints
  static const String pickups = '$baseUrl/api/pickups/';
}
