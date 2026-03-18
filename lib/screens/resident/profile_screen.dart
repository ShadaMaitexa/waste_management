import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgSurface,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: AppTheme.bgSurface,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppTheme.bgSurface, Color(0xFFF1F8E9)],
              ),
            ),
          ),
          CustomScrollView(
            slivers: [
              _buildSliverAppBar(),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24), // Reduced
                  child: Column(
                    children: [
                      _buildPersonalDetails(context),
                      const SizedBox(height: 32), // Reduced
                      _buildStatsSection(),
                      const SizedBox(height: 40), // Reduced
                      _buildActionSection(context),
                      const SizedBox(height: 80), // Reduced
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Back Button
          Positioned(
            top: 50,
            left: 20,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: AppTheme.cardShadow,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.grey900, size: 18),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120.0,
      floating: false,
      pinned: true,
      backgroundColor: AppTheme.bgDark,
      automaticallyImplyLeading: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            color: AppTheme.bgDark,
            gradient: AppTheme.slateGradient,
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalDetails(BuildContext context) {
    final user = Provider.of<AuthService>(context).currentUser;
    final userName = user?.name ?? 'Loading...';
    final userEmail = user?.email ?? '';
    final userWard = user?.wardNumber ?? 'Not Assigned';

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.primaryEmerald.withValues(alpha: 0.1), width: 2),
              ),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: AppTheme.cardShadow,
                ),
                child: CircleAvatar(
                  radius: 54, // Reduced from 64
                  backgroundColor: AppTheme.grey50,
                  child: Icon(Icons.person_outline_rounded, size: 40, color: AppTheme.grey300), // Reduced from 48
                ),
              ),
            ),
            Positioned(
              right: 4,
              bottom: 4,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: AppTheme.emeraldGradient,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: AppTheme.cardShadow,
                ),
                child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20), // Reduced from 24
        Text(
          userName,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 26, // Reduced from 32
            fontWeight: FontWeight.w900,
            color: AppTheme.grey900,
            letterSpacing: -1.0,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.success.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.success.withValues(alpha: 0.1)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.verified_rounded, color: AppTheme.success, size: 14),
              const SizedBox(width: 8),
              Text(
                'CERTIFIED AMBASSADOR',
                style: GoogleFonts.plusJakartaSans(
                  color: AppTheme.success,
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                  letterSpacing: 1.5,
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
        Expanded(child: _buildStatItem('1,250', 'XP SCORE', Icons.military_tech_rounded, const Color(0xFFF59E0B))),
        const SizedBox(width: 16),
        Expanded(child: _buildStatItem('24', 'TOTAL LOGS', Icons.local_shipping_rounded, AppTheme.primaryEmerald)),
      ],
    );
  }

  Widget _buildActionSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('CORE INFRASTRUCTURE'),
        const SizedBox(height: 16),
        _buildSettingsCard([
          _SettingItem(Icons.person_outline_rounded, 'Authentication Profiles', Icons.person_rounded, () {}),
          _SettingItem(Icons.location_on_outlined, 'Service Geometry', Icons.map_rounded, () {}),
          _SettingItem(Icons.security_outlined, 'Privacy Protocol', Icons.security_rounded, () {}),
        ]),
        const SizedBox(height: 40),
        _buildSectionHeader('SYSTEM PREFERENCES'),
        const SizedBox(height: 16),
        _buildSettingsCard([
          _SettingItem(Icons.notifications_none_rounded, 'Alert Preferences', Icons.notifications_rounded, () {}),
          _SettingItem(Icons.language_rounded, 'Regional Settings', Icons.translate_rounded, () {}),
          _SettingItem(Icons.help_outline_rounded, 'Support Modules', Icons.support_agent_rounded, () {}),
        ]),
        const SizedBox(height: 48), // Reduced from 56
        SizedBox(
          width: double.infinity,
          height: 56, // Reduced from 64
          child: ElevatedButton(
            onPressed: () {
              Provider.of<AuthService>(context, listen: false).logout();
              Navigator.of(context).pushReplacementNamed('/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.bgDark,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), // Reduced from 20
              elevation: 0,
              padding: EdgeInsets.zero,
            ),
            child: Ink(
              decoration: BoxDecoration(
                gradient: AppTheme.slateGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'LOGOUT',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        fontSize: 13, // Reduced from 14
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.power_settings_new_rounded, size: 18, color: AppTheme.primaryEmerald),
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
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: AppTheme.grey400,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20), // Reduced from 24
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24), // Reduced from 28
        boxShadow: AppTheme.cardShadow,
        border: Border.all(color: AppTheme.grey100, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8), // Reduced from 10
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18), // Reduced from 20
          ),
          const SizedBox(height: 16), // Reduced from 20
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24, // Reduced from 28
              fontWeight: FontWeight.w900,
              color: AppTheme.grey900,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              color: AppTheme.grey400,
              fontSize: 8, // Reduced from 9
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
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
        borderRadius: BorderRadius.circular(24), // Reduced from 28
        boxShadow: AppTheme.cardShadow,
        border: Border.all(color: AppTheme.grey100, width: 1.2),
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
                  ? const BorderRadius.vertical(top: Radius.circular(24))
                  : index == items.length - 1
                    ? const BorderRadius.vertical(bottom: Radius.circular(24))
                    : null,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16), // Reduced from 20
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8), // Reduced from 10
                        decoration: BoxDecoration(
                          color: AppTheme.primaryEmerald.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(item.activeIcon, color: AppTheme.primaryEmerald, size: 16), // Reduced from 18
                      ),
                      const SizedBox(width: 14),
                      Text(
                        item.title,
                        style: GoogleFonts.plusJakartaSans(
                          color: AppTheme.grey900,
                          fontWeight: FontWeight.w700,
                          fontSize: 14, // Reduced from 15
                          letterSpacing: -0.2,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.chevron_right_rounded, size: 18, color: AppTheme.grey300),
                    ],
                  ),
                ),
              ),
              if (index != items.length - 1)
                Padding(
                  padding: const EdgeInsets.only(left: 60, right: 16),
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
