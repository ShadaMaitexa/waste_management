import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../common/help_screen.dart';
import '../common/notifications_screen.dart';
import 'manage_pickup_slots_screen.dart';
import 'admin_reports_screen.dart';

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
      backgroundColor: AppTheme.bgSurface,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: Container(
          padding: const EdgeInsets.only(top: 20),
          decoration: const BoxDecoration(
            color: AppTheme.bgSurface,
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            title: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'System Settings',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                  color: AppTheme.grey900,
                  letterSpacing: -1.2,
                ),
              ),
            ),
            centerTitle: true,
            foregroundColor: AppTheme.grey900,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.grey900, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16),
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.grey100),
                  boxShadow: AppTheme.cardShadow,
                ),
                child: IconButton(
                  icon: const Icon(Icons.help_outline_rounded, color: AppTheme.grey900, size: 18),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpScreen())),
                ),
              ),
            ],
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
        physics: const BouncingScrollPhysics(),
        children: [
          _buildProfileSection(),
          const SizedBox(height: 32),
          _buildSection('Operation Settings', [
            _buildSwitchTile(
              'Automatic Dispatch',
              'Automatically assign workers to pickups',
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
              'Get notified about system issues',
              _notificationsEnabled,
              (v) => setState(() => _notificationsEnabled = v),
            ),
            _buildActionTile(
              'Communication Hub',
              'Manage email, SMS, and broadcast gateways',
              Icons.sensors_rounded,
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
            ),
          ]),
          const SizedBox(height: 24),
          _buildSection('Data Management', [
            _buildActionTile(
              'Booking Slots',
              'Configure citizen pickup booking slots',
              Icons.event_available_rounded,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ManagePickupSlotsScreen()),
              ),
            ),
            _buildActionTile(
              'Ward Boundaries',
              'Modify ward boundaries and coverage areas',
              Icons.map_rounded,
              () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Geospatial Zoning is under development.'))),
            ),
            _buildActionTile(
              'Cloud Data Integrity',
              'Last automated backup: 04:00 AM UTC',
              Icons.cloud_done_rounded,
              () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Backup systems are active.'))),
            ),
            _buildActionTile(
              'System Logs',
              'Review high-level administrative logs',
              Icons.security_rounded,
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminReportsScreen())),
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
        borderRadius: BorderRadius.circular(36),
        boxShadow: AppTheme.cardShadow,
        border: Border.all(color: AppTheme.grey100, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: AppTheme.primaryEmerald.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            alignment: Alignment.center,
            child: Text(
              'HQ',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 26, 
                fontWeight: FontWeight.w900, 
                color: AppTheme.primaryEmerald,
              ),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Command Admin',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.grey900,
                    letterSpacing: -1,
                  ),
                ),
                Text(
                  'hq.operations@kozhikode.gov.in',
                  style: GoogleFonts.inter(
                    color: AppTheme.grey400, 
                    fontSize: 13, 
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.success.withValues(alpha: 0.05),
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
          padding: const EdgeInsets.only(left: 12, bottom: 16),
          child: Text(
            title.toUpperCase(),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: AppTheme.grey500,
              letterSpacing: 2.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(36),
            boxShadow: AppTheme.cardShadow,
            border: Border.all(color: AppTheme.grey100, width: 1.5),
          ),
          child: Column(
            children: children.asMap().entries.map((entry) {
              final index = entry.key;
              final widget = entry.value;
              return Column(
                children: [
                   widget,
                   if (index != children.length - 1)
                     Divider(height: 1, color: AppTheme.grey100, indent: 24, endIndent: 24),
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
      title: Text(
        title, 
        style: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w900, 
          fontSize: 16, 
          color: AppTheme.grey900, 
          letterSpacing: -0.5,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          subtitle, 
          style: GoogleFonts.inter(
            fontSize: 12, 
            color: AppTheme.grey400, 
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: AppTheme.primaryEmerald,
      activeTrackColor: AppTheme.primaryEmerald.withValues(alpha: 0.1),
      inactiveThumbColor: Colors.white,
      inactiveTrackColor: AppTheme.grey100,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    );
  }

  Widget _buildActionTile(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.primaryEmerald.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(icon, size: 20, color: AppTheme.primaryEmerald),
      ),
      title: Text(
        title, 
        style: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w900, 
          fontSize: 16, 
          color: AppTheme.grey900, 
          letterSpacing: -0.5,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          subtitle, 
          style: GoogleFonts.inter(
            fontSize: 12, 
            color: AppTheme.grey400, 
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.grey200),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ElevatedButton(
        onPressed: () {
          Provider.of<AuthService>(context, listen: false).logout();
          Navigator.of(context).pushReplacementNamed('/login');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.error.withValues(alpha: 0.05),
          foregroundColor: AppTheme.error,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 22),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: AppTheme.error.withValues(alpha: 0.1), width: 1.5),
          ),
        ),
        child: Text(
          'LOG OUT',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w900, 
            fontSize: 13, 
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}
