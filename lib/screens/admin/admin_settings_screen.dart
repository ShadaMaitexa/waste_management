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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          padding: const EdgeInsets.only(top: 10),
          decoration: const BoxDecoration(
            gradient: AppTheme.slateGradient,
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            title: const Text(
              'System Configuration',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 22,
                color: Colors.white,
                letterSpacing: -0.8,
              ),
            ),
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.help_outline_rounded, color: Colors.white70),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        physics: const BouncingScrollPhysics(),
        children: [
          _buildProfileSection(),
          const SizedBox(height: 32),
          _buildSection('Operational Core', [
            _buildSwitchTile(
              'Autonomous Dispatch',
              'Al-driven route optimization and assignment',
              _autoDispatchEnabled,
              (v) => setState(() => _autoDispatchEnabled = v),
            ),
            _buildSwitchTile(
              'Maintenance Mode',
              'Suspend non-essential system services',
              _maintenanceMode,
              (v) => setState(() => _maintenanceMode = v),
            ),
          ]),
          const SizedBox(height: 24),
          _buildSection('Security & Alerting', [
            _buildSwitchTile(
              'Critical System Alerts',
              'Real-time push notifications for anomalies',
              _notificationsEnabled,
              (v) => setState(() => _notificationsEnabled = v),
            ),
            _buildActionTile(
              'Communication Hub',
              'Manage email, SMS, and broadcast gateways',
              Icons.sensors_rounded,
              () {},
            ),
          ]),
          const SizedBox(height: 24),
          _buildSection('Resource Management', [
            _buildActionTile(
              'Availability Matrices',
              'Configure citizen pickup booking slots',
              Icons.event_available_rounded,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ManagePickupSlotsScreen()),
              ),
            ),
            _buildActionTile(
              'Geospatial Zoning',
              'Modify ward boundaries and coverage areas',
              Icons.map_rounded,
              () {},
            ),
            _buildActionTile(
              'Cloud Data Integrity',
              'Last automated backup: 04:00 AM UTC',
              Icons.cloud_done_rounded,
              () {},
            ),
            _buildActionTile(
              'Audit Intelligence',
              'Review high-level administrative logs',
              Icons.security_rounded,
              () {},
            ),
          ]),
          const SizedBox(height: 48),
          _buildLogoutButton(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: AppTheme.cardShadow,
        border: Border.all(color: AppTheme.grey100),
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: AppTheme.emeraldGradient,
              borderRadius: BorderRadius.circular(24),
            ),
            alignment: Alignment.center,
            child: const Text(
              'HQ',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Command Admin',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.grey900,
                    letterSpacing: -0.8,
                  ),
                ),
                Text(
                  'hq.operations@kozhikode.gov.in',
                  style: TextStyle(color: AppTheme.grey500, fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.verified_rounded, color: AppTheme.success, size: 20),
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
                color: Colors.black.withValues(alpha: 0.04),
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
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppTheme.grey900, letterSpacing: -0.2)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.grey400, fontWeight: FontWeight.w500)),
      value: value,
      onChanged: onChanged,
      activeTrackColor: AppTheme.primaryEmerald.withValues(alpha: 0.1),
      thumbColor: WidgetStateProperty.all(AppTheme.primaryEmerald),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppTheme.primaryEmerald.withValues(alpha: 0.15);
        }
        return AppTheme.grey200;
      }),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    );
  }

  Widget _buildActionTile(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppTheme.grey50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 20, color: AppTheme.grey500),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppTheme.grey900, letterSpacing: -0.2)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.grey400, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.grey300),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.error.withValues(alpha: 0.05),
          foregroundColor: AppTheme.error,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: AppTheme.error.withValues(alpha: 0.1)),
          ),
        ),
        child: const Text(
          'TERMINATE SESSION',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1),
        ),
      ),
    );
  }
}
