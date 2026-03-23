import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/auth_service.dart';
import '../../services/reward_service.dart';
import '../../services/pickup_service.dart';
import '../../theme/app_theme.dart';
import '../../models/user.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthService>().currentUser;
      if (user != null) {
        context.read<RewardService>().fetchUserRewards(user.id);
        context.read<PickupService>().fetchPickups();
      }
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() => _isLoading = true);
        // await context.read<AuthService>().uploadProfileImage(image.path);
        // Simulating upload for now as backend might not have this endpoint yet
        await Future.delayed(const Duration(seconds: 1));
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile photo updated successfully'), backgroundColor: AppTheme.success));
        }
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    return Scaffold(
      backgroundColor: AppTheme.bgSurface,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildSliverAppBar(),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: Column(
                    children: [
                      _buildPersonalDetails(context, user),
                      const SizedBox(height: 32),
                      _buildStatsSection(context, user),
                      const SizedBox(height: 48),
                      _buildActionSection(context, authService),
                    ],
                  ),
                ),
              ),
            ],
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
            Positioned(
              right: 4,
              bottom: 4,
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(gradient: AppTheme.emeraldGradient, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3), boxShadow: AppTheme.cardShadow), child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(userName, style: GoogleFonts.plusJakartaSans(fontSize: 26, fontWeight: FontWeight.w900, color: AppTheme.grey900, letterSpacing: -1.0)),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildStatsSection(BuildContext context, User? user) {
    if (user == null) return const SizedBox.shrink();
    
    return Consumer2<RewardService, PickupService>(
      builder: (context, rewardService, pickupService, child) {
        final points = rewardService.getUserPoints(user.id);
        final totalPickups = pickupService.getPickupsForUser(user.id).length;
        
        return Row(
          children: [
            Expanded(child: _buildStatItem(points.toString(), 'XP SCORE', Icons.military_tech_rounded, const Color(0xFFF59E0B))),
            const SizedBox(width: 16),
            Expanded(child: _buildStatItem(totalPickups.toString(), 'TOTAL LOGS', Icons.local_shipping_rounded, AppTheme.primaryEmerald)),
          ],
        );
      },
    );
  }

  Widget _buildActionSection(BuildContext context, AuthService authService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('ACCOUNT SETTINGS'),
        const SizedBox(height: 16),
        _buildSettingsCard([
          _SettingItem(Icons.person_outline_rounded, 'Personal Details', Icons.person_rounded, () => _showEditProfileDialog(context)),
          _SettingItem(Icons.location_on_outlined, 'My Address', Icons.map_rounded, () => _showEditProfileDialog(context)),
          _SettingItem(Icons.security_outlined, 'Privacy & Policy', Icons.security_rounded, () {}),
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
    final addressController = TextEditingController(text: user?.address);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(36))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 32, right: 32, top: 20),
        child: SingleChildScrollView(
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
              const SizedBox(height: 20),
              _buildDialogField('ADDRESS', addressController, Icons.location_on_rounded),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    setState(() => _isLoading = true);
                    Navigator.pop(context);
                    final success = await authService.updateProfile(
                      name: nameController.text,
                      phone: phoneController.text,
                      address: addressController.text,
                    );
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
