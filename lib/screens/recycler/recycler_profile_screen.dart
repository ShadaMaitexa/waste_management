import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class RecyclerProfileScreen extends StatelessWidget {
  const RecyclerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.grey50,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280.0,
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
                          'ER',
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
                      'EcoRecycle Solutions',
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
                        'Verified Partner • ID: RP-2501',
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
                  _buildBusinessStats(),
                  const SizedBox(height: AppTheme.spacingL),
                  _buildSection('Business Details', [
                    _buildInfoTile(Icons.business, 'Registration Number', 'REG-85934-KL'),
                    _buildInfoTile(Icons.location_on, 'Facility Address', 'Industrial Area, West Hill, Kozhikode'),
                    _buildInfoTile(Icons.phone, 'Contact Number', '+91 98765 00123'),
                  ]),
                  const SizedBox(height: AppTheme.spacingL),
                  _buildSection('Compliance', [
                    _buildActionTile('Licenses & Permits', 'View active licenses', Icons.verified_user),
                    _buildActionTile('EPR Authorization', 'Valid until Dec 2026', Icons.gavel),
                    _buildActionTile('Inspection Reports', 'Last inspection: Oct 2025', Icons.assignment),
                  ]),
                  const SizedBox(height: AppTheme.spacingL),
                  _buildSection('Settings', [
                    _buildActionTile('Notifications', 'Alerts & Reminders', Icons.notifications),
                    _buildActionTile('Account Security', 'Password & 2FA', Icons.security),
                    _buildLogoutTile(),
                  ]),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessStats() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildStatItem('Total Processed', '480T', Colors.blue),
          _divider(),
          _buildStatItem('Revenue', '₹45L', Colors.green),
          _divider(),
          _buildStatItem('Rating', '4.8', Colors.orange),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.grey600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(
      height: 40,
      width: 1,
      color: AppTheme.grey200,
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.grey900,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: children.asMap().entries.map((entry) {
              final index = entry.key;
              final widget = entry.value;
              return Column(
                children: [
                  widget,
                  if (index != children.length - 1)
                    Divider(height: 1, color: AppTheme.grey100, indent: 16, endIndent: 16),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.grey50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppTheme.grey600, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontSize: 14, color: AppTheme.grey600)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppTheme.grey900)),
    );
  }

  Widget _buildActionTile(String title, String subtitle, IconData icon) {
    return ListTile(
      onTap: () {},
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primaryGreen.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppTheme.primaryGreen, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.grey600)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.grey400),
    );
  }

  Widget _buildLogoutTile() {
    return ListTile(
      onTap: () {
        // Implement logout logic here or trigger a dialog
      },
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.logout, color: AppTheme.error, size: 20),
      ),
      title: const Text('Logout', style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.error)),
    );
  }
}
