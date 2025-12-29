import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _markAllAsRead = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        elevation: 0,
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _markAllAsReadPressed,
            child: Text(
              'Mark All Read',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter tabs
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            child: Row(
              children: [
                _buildFilterChip('All', true),
                const SizedBox(width: AppTheme.spacingS),
                _buildFilterChip('Pickups', false),
                const SizedBox(width: AppTheme.spacingS),
                _buildFilterChip('Rewards', false),
                const SizedBox(width: AppTheme.spacingS),
                _buildFilterChip('System', false),
              ],
            ),
          ),
          // Notifications list
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
              children: [
                _buildNotificationItem(
                  'Pickup Scheduled',
                  'Your waste pickup has been scheduled for tomorrow at 8:00 AM',
                  DateTime.now().subtract(const Duration(hours: 1)),
                  Icons.schedule,
                  AppTheme.primaryGreen,
                  true,
                ),
                _buildNotificationItem(
                  'Points Earned',
                  'Congratulations! You earned 50 points for proper waste segregation',
                  DateTime.now().subtract(const Duration(hours: 3)),
                  Icons.stars,
                  AppTheme.warning,
                  false,
                ),
                _buildNotificationItem(
                  'Pickup Completed',
                  'Your pickup has been completed successfully. Thank you for your participation!',
                  DateTime.now().subtract(const Duration(days: 1)),
                  Icons.check_circle,
                  AppTheme.success,
                  true,
                ),
                _buildNotificationItem(
                  'New Feature Update',
                  'Check out the new waste segregation guide in the app!',
                  DateTime.now().subtract(const Duration(days: 2)),
                  Icons.new_releases,
                  AppTheme.info,
                  false,
                ),
                _buildNotificationItem(
                  'Reward Available',
                  'You have a new reward waiting to be claimed!',
                  DateTime.now().subtract(const Duration(days: 3)),
                  Icons.card_giftcard,
                  AppTheme.secondaryGreen,
                  false,
                ),
                _buildNotificationItem(
                  'Collection Reminder',
                  'Don\'t forget to place your segregated waste outside for collection',
                  DateTime.now().subtract(const Duration(days: 4)),
                  Icons.warning,
                  AppTheme.warning,
                  true,
                ),
                _buildNotificationItem(
                  'Profile Updated',
                  'Your profile information has been successfully updated',
                  DateTime.now().subtract(const Duration(days: 5)),
                  Icons.person,
                  AppTheme.grey600,
                  false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          // Handle filter selection
        });
      },
      selectedColor: AppTheme.primaryGreen.withOpacity(0.2),
      checkmarkColor: AppTheme.primaryGreen,
    );
  }

  Widget _buildNotificationItem(
    String title,
    String message,
    DateTime timestamp,
    IconData icon,
    Color color,
    bool isUnread,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingS),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusS),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (isUnread)
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            const SizedBox(height: 4),
            Text(
              _formatTimestamp(timestamp),
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.grey500,
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'mark_read':
                setState(() {
                  // Mark as read
                });
                break;
              case 'delete':
                setState(() {
                  // Delete notification
                });
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'mark_read',
              child: const Text('Mark as Read'),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Text('Delete'),
            ),
          ],
        ),
        onTap: () {
          // Handle notification tap
          if (isUnread) {
            setState(() {
              // Mark as read
            });
          }
        },
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d, yyyy').format(timestamp);
    }
  }

  void _markAllAsReadPressed() {
    setState(() {
      _markAllAsRead = !_markAllAsRead;
      // Logic to mark all notifications as read
    });
  }
}
