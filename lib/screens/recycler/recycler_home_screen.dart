import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import 'materials_management_screen.dart';
import 'recycler_certificates_screen.dart';
import 'recycler_dashboard_tab.dart';
import 'recycler_profile_screen.dart';

class RecyclerHomeScreen extends StatefulWidget {
  const RecyclerHomeScreen({super.key});

  @override
  State<RecyclerHomeScreen> createState() => _RecyclerHomeScreenState();
}

class _RecyclerHomeScreenState extends State<RecyclerHomeScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgSurface,
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _selectedIndex = index);
            },
            physics: const NeverScrollableScrollPhysics(),
            children: [
              RecyclerDashboardTab(onNavigate: _onItemTapped),
              const MaterialsManagementScreen(),
              const RecyclerCertificatesScreen(),
              const RecyclerProfileScreen(),
            ],
          ),
          _buildFloatingBottomBar(),
        ],
      ),
    );
  }

  Widget _buildFloatingBottomBar() {
    return Positioned(
      left: 24,
      right: 24,
      bottom: 32,
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          color: AppTheme.bgDark.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 40,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(0, Icons.dashboard_rounded, 'Dash'),
            _buildNavItem(1, Icons.recycling_rounded, 'Waste'),
            _buildNavItem(2, Icons.workspace_premium_rounded, 'Badge'),
            _buildNavItem(3, Icons.person_rounded, 'Meta'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryEmerald.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
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
}
