import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgSurface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 340.0,
            floating: false,
            pinned: true,
            backgroundColor: AppTheme.bgDark,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: AppTheme.slateGradient,
                    ),
                  ),
                  Positioned(
                    right: -40,
                    top: -40,
                    child: Icon(Icons.fingerprint_rounded, size: 320, color: Colors.white.withValues(alpha: 0.03)),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 50),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 2),
                          boxShadow: [
                            BoxShadow(color: AppTheme.bgDark.withValues(alpha: 0.5), blurRadius: 20, offset: const Offset(0, 8))
                          ]
                        ),
                        child: CircleAvatar(
                          radius: 56,
                          backgroundColor: Colors.white,
                          child: Text(
                            'JD',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.bgDark,
                              letterSpacing: -1,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'John Doe',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryEmerald.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.primaryEmerald.withValues(alpha: 0.3), width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.verified_rounded, color: AppTheme.primaryEmerald, size: 14),
                            const SizedBox(width: 8),
                            Text(
                              'AMBASSADOR • LEVEL 4',
                              style: GoogleFonts.plusJakartaSans(
                                color: AppTheme.primaryEmerald, 
                                fontWeight: FontWeight.w800, 
                                fontSize: 10,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
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
              padding: const EdgeInsets.all(AppTheme.spacingL),
              child: Column(
                children: [
                  _buildStatsRow(),
                  const SizedBox(height: AppTheme.spacingXL),
                  _buildSectionTitle('Network'),
                  _buildSettingsCard(
                    [
                      _SettingItem(Icons.person_rounded, 'Authentication Data', () {}),
                      _SettingItem(Icons.map_rounded, 'Service Location', () {}),
                      _SettingItem(Icons.qr_code_2_rounded, 'Identity Token', () {}),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingL),
                  _buildSectionTitle('Preferences'),
                  _buildSettingsCard(
                    [
                      _SettingItem(Icons.notifications_active_rounded, 'Alert Settings', () {}),
                      _SettingItem(Icons.language_rounded, 'Localization', () {}),
                      _SettingItem(Icons.contrast_rounded, 'Visual Mode', () {}),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingL),
                  _buildSectionTitle('System Status'),
                  _buildSettingsCard(
                    [
                      _SettingItem(Icons.support_agent_rounded, 'Support Protocol', () {}),
                      _SettingItem(Icons.security_rounded, 'Data Privacy', () {}),
                      _SettingItem(
                        Icons.exit_to_app_rounded,
                        'End Session',
                        () {},
                        isDestructive: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 60),
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
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: AppTheme.bgCanvas,
        borderRadius: BorderRadius.circular(28),
        boxShadow: AppTheme.cardShadow,
        border: Border.all(color: AppTheme.grey200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem('1,250', 'XP METRIC', Icons.military_tech_rounded, const Color(0xFFF59E0B)),
          _verticalDivider(),
          _buildStatItem('24', 'DISPATCHES', Icons.local_shipping_rounded, AppTheme.primaryEmerald),
          _verticalDivider(),
          _buildStatItem('12kg', 'CO2 INDEX', Icons.cloud_done_rounded, AppTheme.info),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 12),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppTheme.grey900,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            color: AppTheme.grey500,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _verticalDivider() {
    return Container(
      height: 48,
      width: 1,
      color: AppTheme.grey200,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12, left: 16, top: 8),
        child: Text(
          title.toUpperCase(),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: AppTheme.grey400,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<_SettingItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bgCanvas,
        borderRadius: BorderRadius.circular(28),
        boxShadow: AppTheme.cardShadow,
        border: Border.all(color: AppTheme.grey200),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Column(
          children: items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final color = item.isDestructive ? AppTheme.error : AppTheme.grey700;
            
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: item.onTap,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: item.isDestructive ? AppTheme.error.withValues(alpha: 0.1) : AppTheme.bgSurface,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(item.icon, color: color, size: 20),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              item.title,
                              style: GoogleFonts.plusJakartaSans(
                                color: color,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded, size: 20, color: AppTheme.grey400),
                        ],
                      ),
                    ),
                    if (index != items.length - 1)
                      Divider(height: 1, color: AppTheme.grey100, indent: 72, endIndent: 24),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
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
