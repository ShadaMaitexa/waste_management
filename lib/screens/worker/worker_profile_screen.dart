import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';

class WorkerProfileScreen extends StatefulWidget {
  const WorkerProfileScreen({super.key});

  @override
  State<WorkerProfileScreen> createState() => _WorkerProfileScreenState();
}

class _WorkerProfileScreenState extends State<WorkerProfileScreen> {
  bool _isEditing = false;
  
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;
    final isHks = user?.rawRole.contains('hks') ?? false;

    final String workerName = user?.name ?? 'Mohammed Rafi';
    final String employeeId = user?.id != null ? (isHks ? 'HKS-${user!.id}' : 'EMP-${user!.id}') : 'HKS-2024-001';
    final String phoneNumber = user?.phone ?? '+91 9876543210';
    final String email = user?.email ?? 'rafi.mohammed@hks.gov.in';
    final String ward = 'Ward ${user?.ward ?? "15"}';
    return Scaffold(
      backgroundColor: AppTheme.bgSurface,
      appBar: AppBar(
        title: Text(
          isHks ? 'HKS Identity & Access' : 'Identity & Access',
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
        leading: Navigator.canPop(context) ? IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ) : null,
        actions: [
          IconButton(
            icon: Icon(
              _isEditing ? Icons.check_circle_rounded : Icons.tune_rounded,
              color: AppTheme.primaryEmerald,
              size: 20,
            ),
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
              });
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 32),
            _buildProfileHeader(workerName, isHks, ward, employeeId),
            const SizedBox(height: 40),
            _buildPerformanceGrid(),
            const SizedBox(height: 48),
            _buildSectionHeader('CORE CREDENTIALS'),
            const SizedBox(height: 16),
            _buildCredentialCard(phoneNumber, email),
            const SizedBox(height: 32),
            _buildSectionHeader('SYSTEM PREFERENCES'),
            const SizedBox(height: 16),
            _buildSettingsModule(),
            const SizedBox(height: 40),
            _buildLogoutButton(),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: AppTheme.grey400,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: ElevatedButton(
        onPressed: () {
          Provider.of<AuthService>(context, listen: false).logout();
          Navigator.of(context).pushReplacementNamed('/login');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.bgDark,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
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
                const Icon(Icons.power_settings_new_rounded, size: 20, color: Color(0xFFF43F5E)),
                const SizedBox(width: 12),
                Text(
                  'LOGOUT',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(String workerName, bool isHks, String ward, String employeeId) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppTheme.emeraldGradient,
                boxShadow: AppTheme.intenseShadow,
              ),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: const CircleAvatar(
                  radius: 64,
                  backgroundColor: AppTheme.grey100,
                  child: Icon(Icons.person_rounded, size: 72, color: AppTheme.grey300),
                ),
              ),
            ),
            Positioned(
              bottom: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: AppTheme.slateGradient,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: AppTheme.smoothShadow,
                ),
                child: const Icon(Icons.camera_enhance_rounded, color: Colors.white, size: 16),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Text(
          workerName,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 36,
            fontWeight: FontWeight.w900,
            color: AppTheme.grey900,
            letterSpacing: -2,
            height: 1,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          '${isHks ? "HKS Specialist" : "Logistics Specialist"} • $ward',
          style: GoogleFonts.plusJakartaSans(
            color: AppTheme.grey400,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.bgDark,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.bgDark.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.verified_rounded, color: AppTheme.primaryEmerald, size: 16),
              const SizedBox(width: 12),
              Text(
                'UNIT ID: ${employeeId.toUpperCase()}',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceGrid() {
    return Row(
      children: [
        Expanded(child: _perfCard('4.8', 'Rating', Icons.auto_awesome_rounded, Colors.amber)),
        const SizedBox(width: 16),
        Expanded(child: _perfCard('2,450', 'XP', Icons.electric_bolt_rounded, const Color(0xFF6366F1))),
        const SizedBox(width: 16),
        Expanded(child: _perfCard('120', 'Days', Icons.verified_user_rounded, AppTheme.primaryEmerald)),
      ],
    );
  }

  Widget _perfCard(String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: AppTheme.smoothShadow,
        border: Border.all(color: AppTheme.grey200.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 24),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: AppTheme.grey900,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label.toUpperCase(),
            style: GoogleFonts.plusJakartaSans(
              color: AppTheme.grey400,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCredentialCard(String phoneNumber, String email) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: AppTheme.smoothShadow,
        border: Border.all(color: AppTheme.grey200.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          _credentialRow(Icons.phone_iphone_rounded, 'CONTACT', phoneNumber),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Divider(height: 1, color: AppTheme.grey100),
          ),
          _credentialRow(Icons.alternate_email_rounded, 'SECURE EMAIL', email),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Divider(height: 1, color: AppTheme.grey100),
          ),
          _credentialRow(Icons.fmd_good_rounded, 'ASSIGNED HUB', 'Kozhikode Ops Center'),
        ],
      ),
    );
  }

  Widget _credentialRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.bgSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.grey100),
          ),
          child: Icon(icon, size: 20, color: AppTheme.grey400),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  color: AppTheme.grey400,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: GoogleFonts.plusJakartaSans(
                  color: AppTheme.grey900,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsModule() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: AppTheme.smoothShadow,
        border: Border.all(color: AppTheme.grey200.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          _settingTile(Icons.shield_moon_rounded, 'Security & Encryption'),
          _settingTile(Icons.notifications_active_rounded, 'Operational Alerts'),
          _settingTile(Icons.translate_rounded, 'Interface Language'),
          _settingTile(Icons.support_agent_rounded, 'Command Support', isLast: true),
        ],
      ),
    );
  }

  Widget _settingTile(IconData icon, String title, {bool isLast = false}) {
    return Container(
      decoration: isLast ? null : const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.grey100, width: 1)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.bgSurface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: AppTheme.grey600, size: 20),
        ),
        title: Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            color: AppTheme.grey900,
            fontWeight: FontWeight.w800,
            fontSize: 15,
            letterSpacing: -0.2,
          ),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, size: 22, color: AppTheme.grey300),
        onTap: () {},
      ),
    );
  }
}
