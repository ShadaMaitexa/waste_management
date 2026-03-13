import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'manage_pickup_slots_screen.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  bool _notificationsEnabled = true;
  bool _autoDispatchEnabled = true;
  bool _maintenanceMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.grey50,
      appBar: AppBar(
        title: const Text(
          'System Configuration',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: -0.5),
        ),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        children: [
          _buildProfileSection(),
          const SizedBox(height: AppTheme.spacingL),
          _buildSection('System Configuration', [
            _buildSwitchTile(
              'Auto-Dispatch Routes',
              'Automatically assign routes to closest available workers',
              _autoDispatchEnabled,
              (v) => setState(() => _autoDispatchEnabled = v),
            ),
            _buildSwitchTile(
              'Maintenance Mode',
              'Suspend all non-essential system operations',
              _maintenanceMode,
              (v) => setState(() => _maintenanceMode = v),
            ),
          ]),
          const SizedBox(height: AppTheme.spacingM),
          _buildSection('Notifications', [
            _buildSwitchTile(
              'System Alerts',
              'Receive push notifications for critical alerts',
              _notificationsEnabled,
              (v) => setState(() => _notificationsEnabled = v),
            ),
             _buildActionTile(
               'Notification Channels',
               'Configure email and SMS preferences',
               Icons.arrow_forward_ios,
               () {},
             ),
          ]),
          const SizedBox(height: AppTheme.spacingM),
          _buildSection('Data Management', [
             _buildActionTile(
                'Manage Pickup Slots',
                'Define when residents can book pickups',
                Icons.calendar_month,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ManagePickupSlotsScreen()),
                ),
              ),
              _buildActionTile(
                'Manage Wards & Zones',
                'Add or edit geographical boundaries',
                Icons.map,
                () {},
              ),
             _buildActionTile(
               'Data Backup',
               'Last backup: Today, 04:00 AM',
               Icons.cloud_upload,
               () {},
             ),
             _buildActionTile(
               'Audit Logs',
               'View system access logs',
               Icons.history,
               () {},
             ),
          ]),
          const SizedBox(height: AppTheme.spacingL),
          _buildLogoutButton(),
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primaryGreen, AppTheme.secondaryGreen],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.center,
            child: const Text(
              'AD',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Supreme Admin',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.grey900,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'admin.hq@kozhikode.gov',
                  style: TextStyle(color: AppTheme.grey500, fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.verified_user_rounded, color: AppTheme.primaryGreen, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppTheme.grey500,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 20,
                offset: const Offset(0, 8),
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
                    Divider(height: 1, color: AppTheme.grey100, indent: 20, endIndent: 20),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.grey600)),
      value: value,
      onChanged: onChanged,
      activeColor: AppTheme.primaryGreen,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildActionTile(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.grey600)),
      trailing: Icon(icon, size: 18, color: AppTheme.grey400),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextButton(
        onPressed: () {},
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: AppTheme.error.withOpacity(0.05),
        ),
        child: const Text(
          'Logout Session',
          style: TextStyle(color: AppTheme.error, fontWeight: FontWeight.w800, fontSize: 16),
        ),
      ),
    );
  }
}
