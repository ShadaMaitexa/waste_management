import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/onboarding_screen.dart';
import 'screens/auth/registration_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/reset_password_screen.dart';
import 'screens/resident/resident_home_screen.dart';
import 'screens/resident/book_pickup_screen.dart';
import 'screens/resident/my_pickups_screen.dart';
import 'screens/resident/pickup_history_screen.dart';
import 'screens/resident/referral_screen.dart';
import 'screens/resident/profile_screen.dart';
import 'screens/resident/complaint_screen.dart';
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
import 'services/referral_service.dart';
import 'services/admin_service.dart';
import 'services/complaint_service.dart';
import 'services/worker_service.dart'; // Added WorkerService
import 'services/notification_service.dart';

import 'services/theme_service.dart';
import 'services/location_service.dart';

void main() {
  runApp(const GreenLoopApp());
}

class GreenLoopApp extends StatelessWidget {
  const GreenLoopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeService()),
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProxyProvider<AuthService, PickupService>(
          create: (context) => PickupService(context.read<AuthService>()),
          update: (_, auth, pickup) => PickupService(auth),
        ),
        ChangeNotifierProxyProvider<AuthService, ComplaintService>(
          create: (context) => ComplaintService(context.read<AuthService>()),
          update: (_, auth, complaint) => ComplaintService(auth),
        ),
        ChangeNotifierProxyProvider<AuthService, AdminService>(
          create: (context) => AdminService(context.read<AuthService>()),
          update: (_, auth, admin) => AdminService(auth),
        ),
        ChangeNotifierProxyProvider<AuthService, RewardService>(
          create: (context) => RewardService(context.read<AuthService>()),
          update: (_, auth, reward) => RewardService(auth),
        ),
        ChangeNotifierProxyProvider<AuthService, ReferralService>(
          create: (context) => ReferralService(context.read<AuthService>()),
          update: (_, auth, referral) => ReferralService(auth),
        ),
        ChangeNotifierProxyProvider<AuthService, WorkerService>(
          create: (context) => WorkerService(context.read<AuthService>()),
          update: (_, auth, worker) => WorkerService(auth),
        ),
        ChangeNotifierProxyProvider<AuthService, NotificationService>(
          create: (context) => NotificationService(context.read<AuthService>()),
          update: (_, auth, notification) => NotificationService(auth),
        ),
        ChangeNotifierProxyProvider<AuthService, LocationService>(
          create: (context) => LocationService(context.read<AuthService>()),
          update: (_, auth, location) => LocationService(auth),
        ),
      ],
      child: Consumer<ThemeService>(
        builder: (context, themeService, _) {
          return MaterialApp(
            title: 'GreenLoop - Smart Waste Management',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeService.themeMode,
            initialRoute: '/splash',
        onGenerateRoute: (settings) {
          final uri = Uri.parse(settings.name ?? '/');
          
          // Handle routes with query parameters (e.g., /reset-password?uid=...&token=...)
          if (uri.path == '/reset-password') {
            final uid = uri.queryParameters['uid'];
            final token = uri.queryParameters['token'];
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => ResetPasswordScreen(uid: uid, token: token),
            );
          }

          // Standard routes
          switch (uri.path) {
            case '/splash':
              return MaterialPageRoute(builder: (_) => const SplashScreen(), settings: settings);
            case '/onboarding':
              return MaterialPageRoute(builder: (_) => const OnboardingScreen(), settings: settings);
            case '/login':
              return MaterialPageRoute(builder: (_) => const LoginScreen(), settings: settings);
            case '/register':
              return MaterialPageRoute(builder: (_) => const RegistrationScreen(), settings: settings);
            case '/forgot-password':
              return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen(), settings: settings);
            
            // Resident Routes
            case '/resident':
              return MaterialPageRoute(builder: (_) => const ResidentHomeScreen(), settings: settings);
            case '/resident/book-pickup':
              return MaterialPageRoute(builder: (_) => const BookPickupScreen(), settings: settings);
            case '/resident/my-pickups':
              return MaterialPageRoute(builder: (_) => const MyPickupsScreen(), settings: settings);
            case '/resident/pickup-history':
              return MaterialPageRoute(builder: (_) => const PickupHistoryScreen(), settings: settings);
            case '/resident/rewards':
              return MaterialPageRoute(builder: (_) => const ReferralScreen(), settings: settings);
            case '/resident/profile':
              return MaterialPageRoute(builder: (_) => const ProfileScreen(), settings: settings);
            case '/resident/complaints':
              return MaterialPageRoute(builder: (_) => const ComplaintScreen(), settings: settings);
            
            // Worker Routes
            case '/worker':
              return MaterialPageRoute(builder: (_) => const WorkerHomeScreen(), settings: settings);
            case '/worker/today-route':
              return MaterialPageRoute(builder: (_) => const WorkerRoutePlannerScreen(), settings: settings);
            case '/worker/attendance':
              return MaterialPageRoute(builder: (_) => const WorkerAttendanceScreen(), settings: settings);
            case '/worker/schedule':
              return MaterialPageRoute(builder: (_) => const WorkerScheduleScreen(), settings: settings);
            
            // Admin Routes
            case '/admin':
              return MaterialPageRoute(builder: (_) => const AdminHomeScreen(), settings: settings);
            case '/admin/analytics':
              return MaterialPageRoute(builder: (_) => const AnalyticsDashboardScreen(), settings: settings);
            case '/admin/user-management':
              return MaterialPageRoute(builder: (_) => const AdminUserManagementScreen(), settings: settings);
            
            // Recycler Routes
            case '/recycler':
              return MaterialPageRoute(builder: (_) => const RecyclerHomeScreen(), settings: settings);
            case '/recycler/materials':
              return MaterialPageRoute(builder: (_) => const MaterialsManagementScreen(), settings: settings);
            case '/recycler/certificates':
              return MaterialPageRoute(builder: (_) => const RecyclerCertificatesScreen(), settings: settings);
            
            // Common Routes
            case '/settings':
              return MaterialPageRoute(builder: (_) => const SettingsScreen(), settings: settings);
            case '/help':
              return MaterialPageRoute(builder: (_) => const HelpScreen(), settings: settings);
            case '/notifications':
              return MaterialPageRoute(builder: (_) => const NotificationsScreen(), settings: settings);
            case '/contact-support':
              return MaterialPageRoute(builder: (_) => const ContactSupportScreen(), settings: settings);
            
            default:
              return MaterialPageRoute(builder: (_) => const SplashScreen(), settings: settings);
          }
        },
            );
          },
        ),
      );
  }
}
