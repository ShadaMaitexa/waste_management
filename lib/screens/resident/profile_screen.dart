import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

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
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Column(
                    children: [
                      _buildPersonalDetails(context, user),
                      const SizedBox(height: 32),
                      _buildStatsSection(),
                      const SizedBox(height: 40),
                      _buildActionSection(context, authService),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: 50,
            left: 20,
            child: Container(
              decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: AppTheme.cardShadow, border: Border.all(color: Colors.white, width: 2)),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.grey900, size: 18),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          if (_isLoading)
            Container(color: Colors.black26, child: const Center(child: CircularProgressIndicator(color: AppTheme.primaryEmerald))),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(expandedHeight: 120.0, pinned: true, backgroundColor: AppTheme.bgDark, automaticallyImplyLeading: false, elevation: 0, flexibleSpace: FlexibleSpaceBar(background: Container(decoration: const BoxDecoration(color: AppTheme.bgDark, gradient: AppTheme.slateGradient))));
  }

  Widget _buildPersonalDetails(BuildContext context, User? user) {
    final userName = user?.name ?? 'Loading...';
    final userEmail = user?.email ?? '';
    final roleName = user?.userType.name.toUpperCase() ?? 'RESIDENT';

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppTheme.primaryEmerald.withOpacity(0.1), width: 2)),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: AppTheme.cardShadow),
                child: CircleAvatar(radius: 54, backgroundColor: AppTheme.grey50, child: Icon(Icons.person_outline_rounded, size: 40, color: AppTheme.grey300)),
              ),
            ),
            Positioned(right: 4, bottom: 4, child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(gradient: AppTheme.emeraldGradient, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3), boxShadow: AppTheme.cardShadow), child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16))),
          ],
        ),
        const SizedBox(height: 20),
        Text(userName, style: GoogleFonts.plusJakartaSans(fontSize: 26, fontWeight: FontWeight.w900, color: AppTheme.grey900, letterSpacing: -1.0)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(color: AppTheme.primaryEmerald.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.verified_rounded, color: AppTheme.primaryEmerald, size: 14),
              const SizedBox(width: 8),
              Text(
                'CERTIFIED $roleName',
                style: GoogleFonts.plusJakartaSans(color: AppTheme.primaryEmerald, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.5),
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

  Widget _buildActionSection(BuildContext context, AuthService authService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('CORE INFRASTRUCTURE'),
        const SizedBox(height: 16),
        _buildSettingsCard([
          _SettingItem(Icons.person_outline_rounded, 'Authentication Profiles', Icons.person_rounded, () => _showEditProfileDialog(context)),
          _SettingItem(Icons.location_on_outlined, 'Service Geometry', Icons.map_rounded, () {}),
          _SettingItem(Icons.security_outlined, 'Privacy Protocol', Icons.security_rounded, () {}),
        ]),
        const SizedBox(height: 48),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              authService.logout();
              Navigator.of(context).pushReplacementNamed('/login');
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.bgDark, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), padding: EdgeInsets.zero),
            child: Ink(
              decoration: BoxDecoration(gradient: AppTheme.slateGradient, borderRadius: BorderRadius.circular(16)),
              child: Container(
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('LOGOUT', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 13)),
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
    return Padding(padding: const EdgeInsets.only(left: 4, bottom: 8), child: Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w900, color: AppTheme.grey400, letterSpacing: 2)));
  }

  Widget _buildStatItem(String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: AppTheme.cardShadow, border: Border.all(color: AppTheme.grey100, width: 1)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color, size: 18)),
          const SizedBox(height: 16),
          Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.grey900, letterSpacing: -0.8)),
          const SizedBox(height: 1),
          Text(label, style: GoogleFonts.plusJakartaSans(color: AppTheme.grey400, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 0.8)),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(List<_SettingItem> items) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: AppTheme.cardShadow, border: Border.all(color: AppTheme.grey100, width: 1.2)),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Column(
            children: [
              ListTile(
                leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppTheme.primaryEmerald.withOpacity(0.1), shape: BoxShape.circle), child: Icon(item.activeIcon, color: AppTheme.primaryEmerald, size: 16)),
                title: Text(item.title, style: GoogleFonts.plusJakartaSans(color: AppTheme.grey900, fontWeight: FontWeight.w700, fontSize: 14)),
                trailing: const Icon(Icons.chevron_right_rounded, size: 18, color: AppTheme.grey300),
                onTap: item.onTap,
              ),
              if (index != items.length - 1) Divider(height: 1, color: AppTheme.grey100, indent: 60, endIndent: 16),
            ],
          );
        }).toList(),
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;
    final nameController = TextEditingController(text: user?.name);
    final phoneController = TextEditingController(text: user?.phone);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(36))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 32, right: 32, top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 48, height: 5, decoration: BoxDecoration(color: AppTheme.grey200, borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 32),
            Text('Update Profile', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, fontSize: 26, letterSpacing: -1.5, color: AppTheme.grey900)),
            const SizedBox(height: 24),
            _buildDialogField('USERNAME', nameController, Icons.person_rounded),
            const SizedBox(height: 20),
            _buildDialogField('PHONE NUMBER', phoneController, Icons.phone_rounded),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () async {
                  setState(() => _isLoading = true);
                  Navigator.pop(context);
                  final success = await authService.updateProfile(name: nameController.text, phone: phoneController.text);
                  setState(() => _isLoading = false);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(success ? 'Profile updated successfully' : 'Update failed'), backgroundColor: success ? AppTheme.success : AppTheme.error));
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryEmerald, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                child: Text('SAVE CHANGES', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, letterSpacing: 1.5, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogField(String label, TextEditingController controller, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w900, color: AppTheme.grey400, letterSpacing: 1.5)),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 20, color: AppTheme.grey400),
            filled: true, fillColor: AppTheme.grey50,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
          ),
        ),
      ],
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
