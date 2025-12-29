import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & FAQ'),
        elevation: 0,
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for help...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                ),
                filled: true,
                fillColor: AppTheme.grey100,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          // Categories
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildCategoryChip('All', true),
                  const SizedBox(width: AppTheme.spacingS),
                  _buildCategoryChip('Pickup', false),
                  const SizedBox(width: AppTheme.spacingS),
                  _buildCategoryChip('Rewards', false),
                  const SizedBox(width: AppTheme.spacingS),
                  _buildCategoryChip('Account', false),
                  const SizedBox(width: AppTheme.spacingS),
                  _buildCategoryChip('Billing', false),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          // FAQ List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
              children: [
                _buildFAQItem(
                  'How do I schedule a pickup?',
                  'To schedule a pickup, go to the "Book Pickup" section, select your preferred date and time, choose the waste types, and confirm your request.',
                  Icons.schedule,
                ),
                _buildFAQItem(
                  'What waste types are accepted?',
                  'We accept dry waste, wet waste, recyclables, electronic waste, and hazardous materials. Please ensure proper segregation before pickup.',
                  Icons.recycling,
                ),
                _buildFAQItem(
                  'How do I earn rewards points?',
                  'You earn points by properly segregating waste, scheduling regular pickups, and participating in community clean-up events.',
                  Icons.stars,
                ),
                _buildFAQItem(
                  'What is the emergency pickup service?',
                  'Emergency pickup service is available for urgent waste collection needs. It typically arrives within 2 hours of booking.',
                  Icons.emergency,
                ),
                _buildFAQItem(
                  'How can I track my pickup?',
                  'You can track your pickup status in real-time through the "My Pickups" section in your dashboard.',
                  Icons.location_on,
                ),
                _buildFAQItem(
                  'What if I miss my pickup?',
                  'If you miss your scheduled pickup, you can reschedule through the app or contact our support team for assistance.',
                  Icons.schedule_send,
                ),
                _buildFAQItem(
                  'How do I update my profile information?',
                  'Go to the Profile section and tap "Edit Profile" to update your personal information, address, and preferences.',
                  Icons.person,
                ),
                _buildFAQItem(
                  'Is there a fee for pickup services?',
                  'Regular pickups are free for registered residents. Emergency and bulk pickups may have additional charges.',
                  Icons.payments,
                ),
              ],
            ),
          ),
          // Contact Support Button
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            child: ElevatedButton.icon(
              onPressed: _contactSupport,
              icon: const Icon(Icons.contact_support),
              label: const Text('Contact Support'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          // Handle category selection
        });
      },
      selectedColor: AppTheme.primaryGreen.withOpacity(0.2),
      checkmarkColor: AppTheme.primaryGreen,
    );
  }

  Widget _buildFAQItem(String question, String answer, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      child: ExpansionTile(
        leading: Icon(icon, color: AppTheme.primaryGreen),
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            child: Text(
              answer,
              style: TextStyle(color: AppTheme.grey700),
            ),
          ),
        ],
      ),
    );
  }

  void _contactSupport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Support'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Choose your preferred method:'),
            SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.email, color: AppTheme.primaryGreen),
                SizedBox(width: 8),
                Text('support@greenloop.in'),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.phone, color: AppTheme.primaryGreen),
                SizedBox(width: 8),
                Text('+91 8089 123 456'),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.chat, color: AppTheme.primaryGreen),
                SizedBox(width: 8),
                Text('Live Chat (9 AM - 6 PM)'),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
