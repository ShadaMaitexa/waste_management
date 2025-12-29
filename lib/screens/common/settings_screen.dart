import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _locationEnabled = true;
  bool _darkModeEnabled = false;
  String _selectedLanguage = 'English';
  String _selectedTheme = 'Light';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
        backgroundColor: AppTheme.primaryGreen,
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
            _buildSectionHeader('Profile'),
            _buildProfileCard(),
            const SizedBox(height: AppTheme.spacingL),

            // Preferences Section
            _buildSectionHeader('Preferences'),
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
                activeColor: AppTheme.primaryGreen,
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
                activeColor: AppTheme.primaryGreen,
              ),
            ),
            _buildDropdownTile(
              'Language',
              'Select app language',
              Icons.language,
              _selectedLanguage,
              ['English', 'Malayalam', 'Tamil'],
              (value) {
                setState(() {
                  _selectedLanguage = value!;
                });
              },
            ),
            _buildDropdownTile(
              'Theme',
              'Choose app theme',
              Icons.palette_outlined,
              _selectedTheme,
              ['Light', 'Dark', 'System'],
              (value) {
                setState(() {
                  _selectedTheme = value!;
                });
              },
            ),
            const SizedBox(height: AppTheme.spacingL),

            // Account Section
            _buildSectionHeader('Account'),
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
            _buildSectionHeader('Support'),
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
                label: const Text('Sign Out'),
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
              ),
              child: const Icon(
                Icons.person,
                size: 30,
                color: AppTheme.primaryGreen,
              ),
            ),
            const SizedBox(width: AppTheme.spacingM),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'John Doe',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'john.doe@email.com',
                    style: TextStyle(
                      color: AppTheme.grey600,
                    ),
                  ),
                  Text(
                    'Ward 15, Kozhikode',
                    style: TextStyle(
                      color: AppTheme.grey600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.edit_outlined),
              color: AppTheme.primaryGreen,
            ),
          ],
        ),
      ),
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
