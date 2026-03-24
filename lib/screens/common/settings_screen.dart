import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:waste_management/l10n/app_localizations.dart';
import '../../services/auth_service.dart';
import '../../services/locale_provider.dart';
import '../../services/theme_service.dart';
import '../../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _locationEnabled = true;

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final themeProvider = Provider.of<ThemeService>(context);
    final l10n = AppLocalizations.of(context)!;

    String currentLangName = localeProvider.locale.languageCode == 'ml' ? l10n.malayalam : l10n.english;
    String currentThemeName = themeProvider.themeMode == ThemeMode.light ? l10n.light : (themeProvider.themeMode == ThemeMode.dark ? l10n.dark : l10n.system);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        elevation: 0,
        backgroundColor: AppTheme.primaryEmerald,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Section
            _buildSectionHeader(l10n.profile),
            _buildProfileCard(),
            const SizedBox(height: AppTheme.spacingL),

            // Preferences Section
            _buildSectionHeader(l10n.preferences),
            _buildSettingTile(
              'Notifications',
              'Receive updates about pickups and rewards',
              Icons.notifications_outlined,
              Icons.notifications,
              Switch(
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                },
                activeThumbColor: AppTheme.primaryGreen,
                activeTrackColor: AppTheme.primaryGreen.withOpacity(0.5),
              ),
            ),
            _buildSettingTile(
              'Location Services',
              'Allow location access for pickup services',
              Icons.location_off_outlined,
              Icons.location_on,
              Switch(
                value: _locationEnabled,
                onChanged: (value) {
                  setState(() {
                    _locationEnabled = value;
                  });
                },
                activeThumbColor: AppTheme.primaryGreen,
                activeTrackColor: AppTheme.primaryGreen.withOpacity(0.5),
              ),
            ),
            _buildDropdownTile(
              l10n.language,
              l10n.selectLanguage,
              Icons.language,
              currentLangName,
              [l10n.english, l10n.malayalam],
              (value) {
                if (value == l10n.english) {
                  localeProvider.setLocale(const Locale('en'));
                } else {
                  localeProvider.setLocale(const Locale('ml'));
                }
              },
            ),
            _buildDropdownTile(
              l10n.theme,
              'Choose app theme', // Add to l10n if needed
              Icons.palette_outlined,
              currentThemeName,
              [l10n.light, l10n.dark, l10n.system],
              (value) {
                if (value == l10n.light) themeProvider.setThemeMode(ThemeMode.light);
                else if (value == l10n.dark) themeProvider.setThemeMode(ThemeMode.dark);
                else themeProvider.setThemeMode(ThemeMode.system);
              },
            ),
            const SizedBox(height: AppTheme.spacingL),

            // Account Section
            _buildSectionHeader(l10n.account),
            _buildActionTile(
              'Change Password',
              'Update your account password',
              Icons.lock_outline,
              () => _showChangePasswordDialog(),
            ),
            _buildActionTile(
              'Privacy Policy',
              'View our privacy policy',
              Icons.privacy_tip_outlined,
              () => _showInfoDialog('Privacy Policy', 'Our privacy policy ensures your data is protected and used responsibly.'),
            ),
            _buildActionTile(
              'Terms of Service',
              'Read terms and conditions',
              Icons.description_outlined,
              () => _showInfoDialog('Terms of Service', 'By using GreenLoop, you agree to our terms of service for sustainable waste management.'),
            ),
            const SizedBox(height: AppTheme.spacingL),

            // Support Section
            _buildSectionHeader(l10n.support),
            _buildActionTile(
              'Help & FAQ',
              'Get help and find answers',
              Icons.help_outline,
              () => _showInfoDialog('Help & FAQ', 'Visit our FAQ section for common questions about waste management and app usage.'),
            ),
            _buildActionTile(
              'Contact Support',
              'Reach out to our support team',
              Icons.contact_support_outlined,
              () => _showContactDialog(),
            ),
            _buildActionTile(
              'Rate App',
              'Rate GreenLoop on the app store',
              Icons.star_outline,
              () => _showInfoDialog('Rate App', 'Thank you for using GreenLoop! Your feedback helps us improve.'),
            ),
            const SizedBox(height: AppTheme.spacingXL),

            // Logout Button
            Center(
              child: ElevatedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout),
                label: Text(l10n.signOut),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.error,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingXL,
                    vertical: AppTheme.spacingM,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusM),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spacingM),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.grey800,
            ),
      ),
    );
  }

  Widget _buildProfileCard() {
    final user = Provider.of<AuthService>(context).currentUser;
    if (user == null || user.userType == UserType.admin) return const SizedBox.shrink();

    return Card(
      elevation: 0,
       shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: AppTheme.grey100, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: AppTheme.emeraldGradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryEmerald.withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.person_rounded,
                size: 32,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.grey900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: GoogleFonts.inter(
                      color: AppTheme.grey500,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryEmerald.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'WARD ${user.wardNumber} • ${user.userType.toString().split('.').last.toUpperCase()}',
                      style: GoogleFonts.plusJakartaSans(
                        color: AppTheme.primaryEmerald,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => _showEditProfileDialog(user.name, user.ward),
              icon: const Icon(Icons.edit_note_rounded),
              color: AppTheme.primaryEmerald,
              iconSize: 28,
            ),
          ],
        ),
      ),
    );
  }

  void _showEditProfileDialog(String currentName, String currentWard) {
    final nameController = TextEditingController(text: currentName);
    final wardController = TextEditingController(text: currentWard);

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
            Text('Update Profile', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, fontSize: 26, letterSpacing: -1.5)),
            const SizedBox(height: 36),
            _buildDialogField('NAME', nameController, Icons.person_rounded),
            const SizedBox(height: 20),
            _buildDialogField('WARD NUMBER', wardController, Icons.location_on_rounded),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final success = await context.read<AuthService>().updateProfile(
                    name: nameController.text.trim(),
                    ward: wardController.text.trim(),
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Profile updated successfully'), backgroundColor: AppTheme.bgDark),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryEmerald,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 22),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                child: const Text('SAVE CHANGES', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5)),
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
          style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15, color: AppTheme.grey900),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 20, color: AppTheme.grey400),
            filled: true,
            fillColor: AppTheme.grey50,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingTile(
    String title,
    String subtitle,
    IconData icon,
    IconData activeIcon,
    Widget trailing,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: AppTheme.grey600),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: trailing,
      ),
    );
  }

  Widget _buildDropdownTile(
    String title,
    String subtitle,
    IconData icon,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: AppTheme.grey600),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: DropdownButton<String>(
          value: value,
          underline: const SizedBox(),
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: AppTheme.grey600),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: const Text('Feature coming soon! Password change will be available in the next update.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showContactDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Support'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: support@greenloop.in'),
            SizedBox(height: 8),
            Text('Phone: +91 8089 123 456'),
            SizedBox(height: 8),
            Text('Hours: Mon-Fri, 9 AM - 6 PM'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Provider.of<AuthService>(context, listen: false).logout();
              Navigator.of(context).pushReplacementNamed('/login');
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
