import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
      backgroundColor: AppTheme.bgSurface,
      body: isDesktop
          ? Row(
              children: [
                // Desktop/Tablet Navigation Rail
                _buildNavigationRail(),
                // Content Area
                Expanded(
                  child: ClipRRect(
                    child: content,
                  ),
                ),
              ],
            )
          : Stack(
              children: [
                content,
                _buildFloatingBottomBar(),
              ],
            ),
    );
  }

  Widget _buildNavigationRail() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bgCanvas,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 40,
            offset: const Offset(10, 0),
          ),
        ],
      ),
      child: NavigationRail(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutQuart,
          );
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        labelType: NavigationRailLabelType.none,
        leading: Column(
          children: [
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: AppTheme.emeraldGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryEmerald.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(Icons.hub_rounded, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 60),
          ],
        ),
        trailing: Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildRailAction(Icons.settings_suggest_rounded, 'Settings'),
              const SizedBox(height: 8),
              _buildRailAction(Icons.help_center_rounded, 'Help'),
              const SizedBox(height: 32),
            ],
          ),
        ),
        destinations: [
          _buildRailDestination(Icons.dashboard_rounded, Icons.dashboard_outlined, 'DASHBOARD'),
          _buildRailDestination(Icons.analytics_rounded, Icons.analytics_outlined, 'REPORTS'),
          _buildRailDestination(Icons.badge_rounded, Icons.badge_outlined, 'PERSONNEL'),
        ],
        indicatorColor: AppTheme.primaryEmerald.withValues(alpha: 0.1),
        selectedIconTheme: const IconThemeData(color: AppTheme.primaryEmerald, size: 26),
        unselectedIconTheme: IconThemeData(color: AppTheme.grey400, size: 24),
      ),
    );
  }

  Widget _buildRailAction(IconData icon, String tooltip) {
    return IconButton(
      icon: Icon(icon, color: AppTheme.grey400, size: 22),
      onPressed: () {},
      tooltip: tooltip,
    );
  }

  Widget _buildFloatingBottomBar() {
    return Positioned(
      left: 24,
      right: 24,
      bottom: 32,
      child: Container(
        height: 76,
        decoration: BoxDecoration(
          color: AppTheme.bgDark.withValues(alpha: 0.98),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 40,
              offset: const Offset(0, 20),
            ),
            BoxShadow(
              color: AppTheme.primaryEmerald.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(color: Colors.white.withValues(alpha: 0.05), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(0, Icons.dashboard_rounded, 'Dash'),
            _buildNavItem(1, Icons.analytics_rounded, 'Metrics'),
            _buildNavItem(2, Icons.badge_rounded, 'Users'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _currentIndex = index);
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutQuart,
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryEmerald.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.primaryEmerald : Colors.white.withValues(alpha: 0.5),
              size: 22,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label.toUpperCase(),
                style: GoogleFonts.plusJakartaSans(
                  color: AppTheme.primaryEmerald,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  NavigationRailDestination _buildRailDestination(IconData icon, IconData unselectedIcon, String label) {
    return NavigationRailDestination(
      icon: Icon(unselectedIcon),
      selectedIcon: Icon(icon),
      label: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 1,
        ),
      ),
    );
  }
}
