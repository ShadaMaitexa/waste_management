import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgSurface,
      appBar: AppBar(
        title: Text(
          'Profile Infrastructure',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w900, 
            fontSize: 18,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppTheme.bgDark,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.slateGradient,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 40),
            _buildStatsSection(),
            const SizedBox(height: 48),
            _buildActionSection(),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.primaryEmerald.withValues(alpha: 0.1), width: 2),
              ),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: AppTheme.smoothShadow,
                ),
                child: CircleAvatar(
                  radius: 72,
                  backgroundColor: AppTheme.bgSurface,
                  child: Icon(Icons.person_rounded, size: 56, color: AppTheme.grey300),
                ),
              ),
            ),
            Positioned(
              right: 12,
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: AppTheme.slateGradient,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: AppTheme.intenseShadow,
                ),
                child: const Icon(Icons.edit_rounded, color: Colors.white, size: 18),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Text(
          'John Doe',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 36,
            fontWeight: FontWeight.w900,
            color: AppTheme.grey900,
            letterSpacing: -1.5,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: AppTheme.smoothShadow,
            border: Border.all(color: AppTheme.primaryEmerald.withValues(alpha: 0.1)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.verified_rounded, color: AppTheme.primaryEmerald, size: 16),
              const SizedBox(width: 10),
              Text(
                'CERTIFIED AMBASSADOR',
                style: GoogleFonts.plusJakartaSans(
                  color: AppTheme.primaryEmerald,
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection() {
    return Row(
      children: [
        Expanded(child: _buildStatItem('1,250', 'XP METRIC', Icons.military_tech_rounded, const Color(0xFFF59E0B))),
        const SizedBox(width: 16),
        Expanded(child: _buildStatItem('24', 'PICKUPS', Icons.local_shipping_rounded, AppTheme.primaryEmerald)),
      ],
    );
  }

  Widget _buildActionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('ACCOUNT INFRASTRUCTURE'),
        const SizedBox(height: 20),
        _buildSettingsCard([
          _SettingItem(Icons.person_outline_rounded, 'Authentication Profiles', Icons.person_rounded, () {}),
          _SettingItem(Icons.location_on_outlined, 'Service Geometry', Icons.map_rounded, () {}),
          _SettingItem(Icons.security_outlined, 'Privacy & Security', Icons.security_rounded, () {}),
        ]),
        const SizedBox(height: 48),
        _buildSectionHeader('SYSTEM PREFERENCES'),
        const SizedBox(height: 20),
        _buildSettingsCard([
          _SettingItem(Icons.notifications_none_rounded, 'Alert Preferences', Icons.notifications_rounded, () {}),
          _SettingItem(Icons.language_rounded, 'Operational Language', Icons.translate_rounded, () {}),
          _SettingItem(Icons.help_outline_rounded, 'Support Protocol', Icons.support_agent_rounded, () {}),
        ]),
        const SizedBox(height: 56),
        SizedBox(
          width: double.infinity,
          height: 64,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.bgDark,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              elevation: 12,
              shadowColor: AppTheme.bgDark.withValues(alpha: 0.4),
              padding: EdgeInsets.zero,
            ),
            child: Ink(
              decoration: BoxDecoration(
                gradient: AppTheme.slateGradient,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Container(
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'TERMINATE SESSION',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.power_settings_new_rounded, size: 20, color: Colors.white),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: AppTheme.grey400,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: AppTheme.smoothShadow,
        border: Border.all(color: AppTheme.grey200.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 28),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              color: AppTheme.grey900,
              letterSpacing: -2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              color: AppTheme.grey400,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildSettingsCard(List<_SettingItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(36),
        boxShadow: AppTheme.smoothShadow,
        border: Border.all(color: AppTheme.grey200.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          
          return Column(
            children: [
              InkWell(
                onTap: item.onTap,
                borderRadius: index == 0 
                  ? const BorderRadius.vertical(top: Radius.circular(36))
                  : index == items.length - 1
                    ? const BorderRadius.vertical(bottom: Radius.circular(36))
                    : null,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryEmerald.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(item.activeIcon, color: AppTheme.primaryEmerald, size: 20),
                      ),
                      const SizedBox(width: 18),
                      Text(
                        item.title,
                        style: GoogleFonts.plusJakartaSans(
                          color: AppTheme.grey900,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.chevron_right_rounded, size: 24, color: AppTheme.grey300),
                    ],
                  ),
                ),
              ),
              if (index != items.length - 1)
                Padding(
                  padding: const EdgeInsets.only(left: 74, right: 24),
                  child: Divider(height: 1, color: AppTheme.grey100),
                ),
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
  final IconData activeIcon;
  final VoidCallback onTap;

  _SettingItem(this.icon, this.title, this.activeIcon, this.onTap);
}
