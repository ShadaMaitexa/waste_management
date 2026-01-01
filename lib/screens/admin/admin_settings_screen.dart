import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

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
        title: const Text('Settings'),
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
      padding: const EdgeInsets.all(16),
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
          CircleAvatar(
            radius: 30,
            backgroundColor: AppTheme.primaryGreen.withOpacity(0.1),
            child: const Text(
              'AD',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'System Admin',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'admin@kozhikode.gov.in',
                  style: TextStyle(color: AppTheme.grey600, fontSize: 13),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: AppTheme.primaryGreen),
            onPressed: () {},
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
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.grey700,
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
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.error,
          side: const BorderSide(color: AppTheme.error),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text('Logout from Admin Console'),
      ),
    );
  }
}
