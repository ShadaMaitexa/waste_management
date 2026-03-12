import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppTheme.spacingXL),
              _buildHeader(context),
              const SizedBox(height: AppTheme.spacingXL),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
                  child: Column(
                    children: [
                      _buildRoleCard(
                        context,
                        title: 'Resident',
                        subtitle: 'Dispose waste responsibly and earn rewards',
                        icon: Icons.home_rounded,
                        type: UserType.resident,
                        color: Colors.blue.shade400,
                      ),
                      const SizedBox(height: AppTheme.spacingM),
                      _buildRoleCard(
                        context,
                        title: 'Collection Worker',
                        subtitle: 'Manage waste collection routes and tasks',
                        icon: Icons.delivery_dining_rounded,
                        type: UserType.worker,
                        color: Colors.orange.shade400,
                      ),
                      const SizedBox(height: AppTheme.spacingM),
                      _buildRoleCard(
                        context,
                        title: 'Recycling Partner',
                        subtitle: 'Process waste and generate certificates',
                        icon: Icons.recycling_rounded,
                        type: UserType.recycler,
                        color: Colors.teal.shade400,
                      ),
                      const SizedBox(height: AppTheme.spacingM),
                      _buildRoleCard(
                        context,
                        title: 'Super Admin',
                        subtitle: 'Monitor cities and manage system resources',
                        icon: Icons.admin_panel_settings_rounded,
                        type: UserType.admin,
                        color: Colors.purple.shade400,
                      ),
                      const SizedBox(height: AppTheme.spacingXL),
                    ],
                  ),
                ),
              ),
              _buildFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
      child: Column(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.zero,
          ),
          const SizedBox(height: AppTheme.spacingM),
          const Text(
            'Choose Your Role',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacingS),
          const Text(
            'Select how you want to contribute to a cleaner city',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRoleCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required UserType type,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/register',
          arguments: type,
        );
      },
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppTheme.radiusXL),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(AppTheme.radiusL),
              ),
              child: Icon(
                icon,
                size: 32,
                color: color,
              ),
            ),
            const SizedBox(width: AppTheme.spacingL),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Colors.white30,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Already have an account? ',
            style: TextStyle(color: Colors.white70),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Sign In',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
