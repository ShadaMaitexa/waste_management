import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/onboarding_screen.dart';
import 'screens/resident/resident_home_screen.dart';
import 'screens/resident/book_pickup_screen.dart';
import 'screens/resident/my_pickups_screen.dart';
import 'screens/resident/pickup_history_screen.dart';
import 'screens/resident/rewards_screen.dart';
import 'screens/resident/profile_screen.dart';
import 'screens/worker/worker_home_screen.dart';
import 'screens/worker/worker_route_planner_screen.dart';
import 'screens/worker/worker_attendance_screen.dart';
import 'screens/worker/worker_schedule_screen.dart';
import 'screens/admin/admin_home_screen.dart';
import 'screens/admin/analytics_dashboard_screen.dart';
import 'screens/admin/admin_user_management_screen.dart';
import 'screens/recycler/recycler_home_screen.dart';
import 'screens/recycler/materials_management_screen.dart';
import 'screens/recycler/recycler_certificates_screen.dart';
import 'screens/common/settings_screen.dart';
import 'screens/common/help_screen.dart';
import 'screens/common/notifications_screen.dart';
import 'screens/common/contact_support_screen.dart';
import 'services/auth_service.dart';
import 'services/pickup_service.dart';
import 'services/reward_service.dart';

void main() {
  runApp(const GreenLoopApp());
}

class GreenLoopApp extends StatelessWidget {
  const GreenLoopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => PickupService()),
        ChangeNotifierProvider(create: (_) => RewardService()),
      ],
      child: MaterialApp(
        title: 'GreenLoop - Smart Waste Management',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        initialRoute: '/splash',
        routes: {
          // Authentication & Onboarding
          '/splash': (_) => const SplashScreen(),
          '/onboarding': (_) => const OnboardingScreen(),
          '/login': (_) => const LoginScreen(),
          
          // Resident Routes
          '/resident': (_) => const ResidentHomeScreen(),
          '/resident/book-pickup': (_) => const BookPickupScreen(),
          '/resident/my-pickups': (_) => const MyPickupsScreen(),
          '/resident/pickup-history': (_) => const PickupHistoryScreen(),
          '/resident/rewards': (_) => const RewardsScreen(),
          '/resident/profile': (_) => const ProfileScreen(),
          
          // Worker Routes
          '/worker': (_) => const WorkerHomeScreen(),
          '/worker/today-route': (_) => const WorkerRoutePlannerScreen(),
          '/worker/attendance': (_) => const WorkerAttendanceScreen(),
          '/worker/schedule': (_) => const WorkerScheduleScreen(),
          
          // Admin Routes
          '/admin': (_) => const AdminHomeScreen(),
          '/admin/analytics': (_) => const AnalyticsDashboardScreen(),
          '/admin/user-management': (_) => const AdminUserManagementScreen(),
          
          // Recycler Routes
          '/recycler': (_) => const RecyclerHomeScreen(),
          '/recycler/materials': (_) => const MaterialsManagementScreen(),
          '/recycler/certificates': (_) => const RecyclerCertificatesScreen(),
          
          // Common Routes
          '/settings': (_) => const SettingsScreen(),
          '/help': (_) => const HelpScreen(),
          '/notifications': (_) => const NotificationsScreen(),
          '/contact-support': (_) => const ContactSupportScreen(),
        },
      ),
    );
  }
}
