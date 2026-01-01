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
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryGreen, AppTheme.secondaryGreen],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        child: Text(
                          'JD',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'John Doe',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Green Champion Lvl 3',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
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
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem('1,250', 'Points', Icons.stars, Colors.amber),
          _verticalDivider(),
          _buildStatItem('24', 'Cleanups', Icons.delete_outline, AppTheme.primaryGreen),
          _verticalDivider(),
          _buildStatItem('12kg', 'CO2 Saved', Icons.cloud_outlined, Colors.blue),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.grey900,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.grey600,
            fontSize: 12,
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
        padding: const EdgeInsets.only(bottom: 12, left: 4),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.grey900,
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<_SettingItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
                leading: Icon(
                  item.icon,
                  color: item.isDestructive ? AppTheme.error : AppTheme.grey600,
                ),
                title: Text(
                  item.title,
                  style: TextStyle(
                    color: item.isDestructive ? AppTheme.error : AppTheme.grey900,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right, size: 20, color: AppTheme.grey400),
                onTap: item.onTap,
              ),
              if (index != items.length - 1)
                Divider(height: 1, color: AppTheme.grey100),
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
