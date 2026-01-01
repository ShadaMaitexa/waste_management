import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/responsive_scaffold.dart';
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
    return ResponsiveScaffold(
      selectedIndex: _selectedIndex,
      onDestinationSelected: _onItemTapped,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard, color: AppTheme.primaryGreen),
          label: 'Dashboard',
        ),
        NavigationDestination(
          icon: Icon(Icons.recycling_outlined),
          selectedIcon: Icon(Icons.recycling, color: AppTheme.primaryGreen),
          label: 'Materials',
        ),
        NavigationDestination(
          icon: Icon(Icons.card_membership_outlined),
          selectedIcon: Icon(Icons.card_membership, color: AppTheme.primaryGreen),
          label: 'Certificates',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person, color: AppTheme.primaryGreen),
          label: 'Profile',
        ),
      ],
      body: PageView(
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
    );
  }
}
