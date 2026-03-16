import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'admin_dashboard_tab.dart';
import 'admin_reports_screen.dart';
import 'admin_user_management_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width >= 600;

    Widget content = PageView(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        AdminDashboardTab(onNavigate: (index) {
          setState(() => _currentIndex = index);
          _pageController.jumpToPage(index);
        }),
        const AdminReportsScreen(),
        const AdminUserManagementScreen(),
      ],
    );

    return Scaffold(
      backgroundColor: AppTheme.grey50,
      body: isDesktop
          ? Row(
              children: [
                // Desktop/Tablet Navigation Rail
                NavigationRail(
                  selectedIndex: _currentIndex,
                  onDestinationSelected: (index) {
                    setState(() => _currentIndex = index);
                    _pageController.jumpToPage(index);
                  },
                  backgroundColor: Colors.white,
                  elevation: 1,
                  labelType: NavigationRailLabelType.none,
                  leading: Column(
                    children: [
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryEmerald.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.hub_rounded, color: AppTheme.primaryEmerald, size: 28),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                  trailing: Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.settings_outlined, color: AppTheme.grey400),
                          onPressed: () {},
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                  destinations: [
                    _buildRailDestination(Icons.dashboard_rounded, Icons.dashboard_outlined, 'Dash'),
                    _buildRailDestination(Icons.analytics_rounded, Icons.analytics_outlined, 'Reports'),
                    _buildRailDestination(Icons.badge_rounded, Icons.badge_outlined, 'Users'),
                  ],
                  indicatorColor: AppTheme.primaryEmerald.withValues(alpha: 0.12),
                  selectedIconTheme: const IconThemeData(color: AppTheme.primaryEmerald, size: 28),
                  unselectedIconTheme: const IconThemeData(color: AppTheme.grey400, size: 26),
                ),
                // Content Area
                Expanded(child: content),
              ],
            )
          : content,
      bottomNavigationBar: isDesktop
          ? null
          : BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() => _currentIndex = index);
                _pageController.jumpToPage(index);
              },
              backgroundColor: Colors.white,
              selectedItemColor: AppTheme.primaryEmerald,
              unselectedItemColor: AppTheme.grey400,
              showSelectedLabels: true,
              showUnselectedLabels: false,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard_rounded), label: 'Dash'),
                BottomNavigationBarItem(icon: Icon(Icons.analytics_outlined), activeIcon: Icon(Icons.analytics_rounded), label: 'Reports'),
                BottomNavigationBarItem(icon: Icon(Icons.badge_outlined), activeIcon: Icon(Icons.badge_rounded), label: 'Users'),
              ],
            ),
    );
  }

  NavigationRailDestination _buildRailDestination(IconData icon, IconData unselectedIcon, String label) {
    return NavigationRailDestination(
      icon: Icon(unselectedIcon),
      selectedIcon: Icon(icon),
      label: Text(label),
    );
  }
}
