import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../services/notification_service.dart';
import '../../models/notification.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationService>().fetchNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Notifications'),
        elevation: 0,
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => context.read<NotificationService>().fetchNotifications(),
          ),
          TextButton(
            onPressed: () => context.read<NotificationService>().markAllAsRead(),
            child: const Text('Mark All Read', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<NotificationService>(
        builder: (context, service, child) {
          if (service.isLoading && service.notifications.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen));
          }

          final notifications = service.notifications.where((n) {
            if (_selectedFilter == 'All') return true;
            return true;
          }).toList();

          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none_rounded, size: 64, color: AppTheme.grey300),
                  const SizedBox(height: 16),
                  Text('No notifications yet', style: TextStyle(color: AppTheme.grey50, fontSize: 16)),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => service.fetchNotifications(),
            color: AppTheme.primaryGreen,
            child: ListView.builder(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return _buildNotificationItem(notification, service);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationItem(AppNotification notification, NotificationService service) {
    IconData icon = Icons.notifications_active_rounded;
    Color color = AppTheme.primaryGreen;

    final title = notification.title.toLowerCase();
    if (title.contains('pickup')) {
      icon = Icons.local_shipping_rounded;
      color = AppTheme.primaryGreen;
    } else if (title.contains('reward') || title.contains('points')) {
      icon = Icons.stars_rounded;
      color = AppTheme.warning;
    } else if (title.contains('complaint')) {
      icon = Icons.error_outline_rounded;
      color = AppTheme.error;
    }

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: notification.isRead ? AppTheme.grey100 : AppTheme.primaryGreen.withOpacity(0.1), width: 1),
      ),
      color: notification.isRead ? Colors.white : AppTheme.primaryGreen.withOpacity(0.02),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                notification.title,
                style: TextStyle(fontWeight: notification.isRead ? FontWeight.w600 : FontWeight.w900, fontSize: 14, color: AppTheme.grey900),
              ),
            ),
            if (!notification.isRead)
              Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppTheme.primaryGreen, shape: BoxShape.circle)),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(notification.message, style: TextStyle(color: AppTheme.grey600, fontSize: 13, height: 1.4)),
            const SizedBox(height: 8),
            Text(_formatTimestamp(notification.createdAt), style: TextStyle(fontSize: 11, color: AppTheme.grey400, fontWeight: FontWeight.bold)),
          ],
        ),
        onTap: () {
          if (!notification.isRead) service.markAsRead(notification.id);
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
}
