import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.grey50,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 320.0,
            floating: false,
            pinned: true,
            backgroundColor: AppTheme.primaryGreen,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.primaryGreen, AppTheme.secondaryGreen],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  Positioned(
                    right: -20,
                    top: -20,
                    child: Icon(Icons.person_rounded, size: 280, color: Colors.white.withOpacity(0.08)),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 60),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
                        ),
                        child: const CircleAvatar(
                          radius: 54,
                          backgroundColor: Colors.white,
                          child: Text(
                            'JD',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.primaryGreen,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'John Doe',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                        ),
                        child: const Text(
                          'GREEN AMBASSADOR • LEVEL 4',
                          style: TextStyle(
                            color: Colors.white, 
                            fontWeight: FontWeight.w900, 
                            fontSize: 10,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              child: Column(
                children: [
                  _buildStatsRow(),
                  const SizedBox(height: AppTheme.spacingL),
                  _buildSectionTitle('Account'),
                  _buildSettingsCard(
                    [
                      _SettingItem(Icons.person_outline, 'Personal Information', () {}),
                      _SettingItem(Icons.location_on_outlined, 'My Address', () {}),
                      _SettingItem(Icons.qr_code, 'My QR Code', () {}),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingL),
                  _buildSectionTitle('Preferences'),
                  _buildSettingsCard(
                    [
                      _SettingItem(Icons.notifications_outlined, 'Notifications', () {}),
                      _SettingItem(Icons.language, 'Language', () {}),
                      _SettingItem(Icons.dark_mode_outlined, 'Theme', () {}),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingL),
                  _buildSectionTitle('Support'),
                  _buildSettingsCard(
                    [
                      _SettingItem(Icons.help_outline, 'Help Center', () {}),
                      _SettingItem(Icons.policy_outlined, 'Privacy Policy', () {}),
                      _SettingItem(
                        Icons.logout,
                        'Logout',
                        () {},
                        isDestructive: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem('1,250', 'XP POINTS', Icons.auto_awesome_rounded, Colors.amber),
          _verticalDivider(),
          _buildStatItem('24', 'CLEANUPS', Icons.eco_rounded, AppTheme.primaryGreen),
          _verticalDivider(),
          _buildStatItem('12kg', 'CO2 SAVED', Icons.cloud_done_rounded, Colors.blue),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 12),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: AppTheme.grey900,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: AppTheme.grey500,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _verticalDivider() {
    return Container(
      height: 40,
      width: 1,
      color: AppTheme.grey200,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12, left: 12, top: 4),
        child: Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: AppTheme.grey500,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<_SettingItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.grey300.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (item.isDestructive ? AppTheme.error : AppTheme.primaryGreen).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    item.icon,
                    color: item.isDestructive ? AppTheme.error : AppTheme.primaryGreen,
                    size: 22,
                  ),
                ),
                title: Text(
                  item.title,
                  style: TextStyle(
                    color: item.isDestructive ? AppTheme.error : AppTheme.grey900,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                trailing: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppTheme.grey50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.chevron_right_rounded, size: 20, color: AppTheme.grey600),
                ),
                onTap: item.onTap,
              ),
              if (index != items.length - 1)
                Divider(height: 1, color: AppTheme.grey100, indent: 64, endIndent: 20),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _SettingItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;

  _SettingItem(this.icon, this.title, this.onTap, {this.isDestructive = false});
}
