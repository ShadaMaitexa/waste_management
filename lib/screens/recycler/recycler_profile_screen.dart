import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class RecyclerProfileScreen extends StatelessWidget {
  const RecyclerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgSurface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220.0, // Reduced from 280
            floating: false,
            pinned: true,
            backgroundColor: AppTheme.bgDark,
            elevation: 0,
            stretch: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  color: AppTheme.bgDark,
                  gradient: AppTheme.slateGradient,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 32), // Reduced from 40
                    Container(
                      padding: const EdgeInsets.all(4), // Reduced from 6
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 2), // Changed
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(3), // Reduced from 4
                        decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                        child: CircleAvatar(
                          radius: 44, // Reduced from 54
                          backgroundColor: AppTheme.bgSurface,
                          child: Text(
                            'ER',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 28, // Reduced from 34
                              fontWeight: FontWeight.w900,
                              color: AppTheme.primaryEmerald,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10), // Reduced from 12
                    Text(
                      'EcoRecycle Solutions',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20, // Reduced from 26
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.8, // Reduced
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), // Reduced
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10), // Reduced from 14
                        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      child: Text(
                        'Verified Partner • ID: RP-2501',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white.withValues(alpha: 0.9), 
                          fontWeight: FontWeight.w900, 
                          fontSize: 9, // Reduced from 10
                          letterSpacing: 1.2, // Reduced
                        ),
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
      padding: const EdgeInsets.all(20), // Reduced from 28
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24), // Reduced from 32
        boxShadow: AppTheme.smoothShadow,
        border: Border.all(color: AppTheme.grey200.withValues(alpha: 0.5), width: 1.5),
      ),
      child: Row(
        children: [
          _buildStatItem('Total Processed', '480T', AppTheme.accentIndigo),
          _divider(),
          _buildStatItem('Revenue', '₹45L', AppTheme.primaryEmerald),
          _divider(),
          _buildStatItem('Rating', '4.8', AppTheme.warning),
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
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18, // Reduced from 22
              fontWeight: FontWeight.w900,
              color: color,
              letterSpacing: -0.8, // Reduced
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 8,
              fontWeight: FontWeight.w900,
              color: AppTheme.grey400,
              letterSpacing: 1,
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
          padding: const EdgeInsets.only(left: 10, bottom: 12), // Reduced
          child: Text(
            title.toUpperCase(),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 9, // Reduced from 10
              fontWeight: FontWeight.w900,
              color: AppTheme.grey500,
              letterSpacing: 1.5, // Reduced
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24), // Reduced from 32
            boxShadow: AppTheme.smoothShadow,
            border: Border.all(color: AppTheme.grey200.withValues(alpha: 0.5), width: 1.2), // Reduced width
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
        padding: const EdgeInsets.all(8), // Reduced from 12
        decoration: BoxDecoration(
          color: AppTheme.grey50,
          borderRadius: BorderRadius.circular(12), // Reduced from 16
        ),
        child: Icon(icon, color: AppTheme.grey400, size: 18), // Reduced from 22
      ),
      title: Text(
        title, 
        style: GoogleFonts.inter(
          fontSize: 11, // Reduced from 12
          color: AppTheme.grey400, 
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: Text(
        subtitle, 
        style: GoogleFonts.plusJakartaSans(
          fontSize: 14, // Reduced from 16
          fontWeight: FontWeight.w900, 
          color: AppTheme.grey900, 
          letterSpacing: -0.4, // Reduced
        ),
      ),
    );
  }

  Widget _buildActionTile(String title, String subtitle, IconData icon) {
    return ListTile(
      onTap: () {},
      leading: Container(
        padding: const EdgeInsets.all(8), // Reduced from 12
        decoration: BoxDecoration(
          color: AppTheme.primaryEmerald.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12), // Reduced from 16
        ),
        child: Icon(icon, color: AppTheme.primaryEmerald, size: 18), // Reduced from 22
      ),
      title: Text(
        title, 
        style: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w900, 
          color: AppTheme.grey900, 
          fontSize: 14, // Reduced from 16
          letterSpacing: -0.4, // Reduced
        ),
      ),
      subtitle: Text(
        subtitle, 
        style: GoogleFonts.inter(
          fontSize: 11, // Reduced from 12
          color: AppTheme.grey400, 
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, size: 18, color: AppTheme.grey300), // Reduced
    );
  }

  Widget _buildLogoutTile() {
    return ListTile(
      onTap: () {
        // Implement logout logic here or trigger a dialog
      },
      leading: Container(
        padding: const EdgeInsets.all(8), // Reduced from 12
        decoration: BoxDecoration(
          color: AppTheme.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12), // Reduced from 16
        ),
        child: const Icon(Icons.logout_rounded, color: AppTheme.error, size: 18), // Reduced
      ),
      title: Text(
        'Terminate Session', 
        style: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w900, 
          color: AppTheme.error, 
          fontSize: 14, // Reduced from 16
          letterSpacing: -0.4, // Reduced
        ),
      ),
    );
  }
}
