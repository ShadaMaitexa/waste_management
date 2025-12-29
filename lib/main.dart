import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/resident/resident_home_screen.dart';
import 'screens/worker/worker_home_screen.dart';
import 'screens/admin/admin_home_screen.dart';
import 'screens/recycler/recycler_home_screen.dart';
import 'services/auth_service.dart';

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
      ],
      child: MaterialApp(
        title: 'GreenLoop - Smart Waste Management',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        initialRoute: '/splash',
        routes: {
          '/splash': (_) => const SplashScreen(),
          '/login': (_) => const LoginScreen(),
          '/resident': (_) => const ResidentHomeScreen(),
          '/worker': (_) => const WorkerHomeScreen(),
          '/admin': (_) => const AdminHomeScreen(),
          '/recycler': (_) => const RecyclerHomeScreen(),
        },
      ),
    );
  }
}
