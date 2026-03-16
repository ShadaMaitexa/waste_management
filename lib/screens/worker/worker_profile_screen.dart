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
  
  // Profile data
  final String _workerName = 'Mohammed Rafi';
  final String _employeeId = 'HKS-2024-001';
  final String _phoneNumber = '+91 9876543210';
  final String _email = 'rafi.mohammed@hks.gov.in';
  final String _ward = 'Ward 15';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgSurface,
      appBar: AppBar(
        title: Text(
          'IDENTITY & ACCESS',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800, 
            fontSize: 12,
            letterSpacing: 2,
            color: AppTheme.grey400,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
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
            _buildProfileHeader(),
            const SizedBox(height: 40),
            _buildPerformanceGrid(),
            const SizedBox(height: 48),
            _buildSectionHeader('CORE CREDENTIALS'),
            const SizedBox(height: 16),
            _buildCredentialCard(),
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
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: AppTheme.grey400,
            letterSpacing: 1.5,
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
          foregroundColor: const Color(0xFFF43F5E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.power_settings_new_rounded, size: 18),
            const SizedBox(width: 12),
            Text(
              'TERMINATE SESSION',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
                fontSize: 12,
              ),
            ),
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
                border: Border.all(color: AppTheme.primaryEmerald.withValues(alpha: 0.1), width: 1.5),
              ),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.bgCanvas,
                ),
                child: const CircleAvatar(
                  radius: 56,
                  backgroundColor: AppTheme.grey100,
                  child: Icon(Icons.person_rounded, size: 64, color: AppTheme.grey300),
                ),
              ),
            ),
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.bgDark,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.bgSurface, width: 3),
                  boxShadow: AppTheme.cardShadow,
                ),
                child: const Icon(Icons.camera_enhance_rounded, color: Colors.white, size: 14),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Text(
          _workerName,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: AppTheme.grey900,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Logistics Specialist • $_ward',
          style: GoogleFonts.inter(
            color: AppTheme.grey400,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: AppTheme.bgDark,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppTheme.smoothShadow,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.verified_rounded, color: AppTheme.primaryEmerald, size: 14),
              const SizedBox(width: 10),
              Text(
                'UNIT ID: ${_employeeId.toUpperCase()}',
                style: GoogleFonts.inter(
                  color: Colors.white,
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
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: BoxDecoration(
        color: AppTheme.bgCanvas,
        borderRadius: BorderRadius.circular(32),
        boxShadow: AppTheme.cardShadow,
        border: Border.all(color: AppTheme.grey100),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 20),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppTheme.grey900,
              letterSpacing: -1,
            ),
          ),
          Text(
            label.toUpperCase(),
            style: GoogleFonts.inter(
              color: AppTheme.grey400,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCredentialCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.bgCanvas,
        borderRadius: BorderRadius.circular(32),
        boxShadow: AppTheme.cardShadow,
        border: Border.all(color: AppTheme.grey100),
      ),
      child: Column(
        children: [
          _credentialRow(Icons.phone_iphone_rounded, 'CONTACT', _phoneNumber),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, color: AppTheme.grey100),
          ),
          _credentialRow(Icons.alternate_email_rounded, 'SECURE EMAIL', _email),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, color: AppTheme.grey100),
          ),
          _credentialRow(Icons.fmd_good_rounded, 'ASSIGNED HUB', 'Kozhikode Operational Center'),
        ],
      ),
    );
  }

  Widget _credentialRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.bgSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.grey100),
          ),
          child: Icon(icon, size: 18, color: AppTheme.grey400),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  color: AppTheme.grey400,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.plusJakartaSans(
                  color: AppTheme.grey900,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
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
        color: AppTheme.bgCanvas,
        borderRadius: BorderRadius.circular(32),
        boxShadow: AppTheme.cardShadow,
        border: Border.all(color: AppTheme.grey100),
      ),
      child: Column(
        children: [
          _settingTile(Icons.shield_moon_rounded, 'Cryptographic Security'),
          _settingTile(Icons.notifications_active_rounded, 'Deployment Alerts'),
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.bgSurface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppTheme.grey600, size: 18),
        ),
        title: Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            color: AppTheme.grey900,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, size: 20, color: AppTheme.grey300),
        onTap: () {},
      ),
    );
  }
}
