import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/pickup.dart';
import '../../theme/app_theme.dart';

class PickupHistoryScreen extends StatefulWidget {
  const PickupHistoryScreen({super.key});

  @override
  State<PickupHistoryScreen> createState() => _PickupHistoryScreenState();
}

class _PickupHistoryScreenState extends State<PickupHistoryScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Completed', 'Scheduled', 'Cancelled'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pickup History'),
        elevation: 0,
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary cards
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            child: Row(
              children: [
                Expanded(
                  child: _buildSummaryCard('Total Pickups', '24', AppTheme.primaryGreen),
                ),
                const SizedBox(width: AppTheme.spacingM),
                Expanded(
                  child: _buildSummaryCard('This Month', '6', AppTheme.success),
                ),
                const SizedBox(width: AppTheme.spacingM),
                Expanded(
                  child: _buildSummaryCard('Points Earned', '340', AppTheme.warning),
                ),
              ],
            ),
          ),
          // Filter chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filters.map((filter) {
                  return Padding(
                    padding: const EdgeInsets.only(right: AppTheme.spacingS),
                    child: FilterChip(
                      label: Text(filter),
                      selected: _selectedFilter == filter,
                      onSelected: (selected) {
                        setState(() {
                          _selectedFilter = filter;
                        });
                      },
                      selectedColor: AppTheme.primaryGreen.withOpacity(0.2),
                      checkmarkColor: AppTheme.primaryGreen,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          // Pickup list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
              itemCount: 8,
              itemBuilder: (context, index) {
                return _buildPickupCard(_getMockPickup(index));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.grey600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPickupCard(dynamic pickup) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (pickup['status']) {
      case 'completed':
        statusColor = AppTheme.success;
        statusIcon = Icons.check_circle;
        statusText = 'Completed';
        break;
      case 'scheduled':
        statusColor = AppTheme.info;
        statusIcon = Icons.schedule;
        statusText = 'Scheduled';
        break;
      case 'cancelled':
        statusColor = AppTheme.error;
        statusIcon = Icons.cancel;
        statusText = 'Cancelled';
        break;
      default:
        statusColor = AppTheme.grey600;
        statusIcon = Icons.help;
        statusText = 'Unknown';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusS),
                  ),
                  child: Icon(statusIcon, color: statusColor, size: 20),
                ),
                const SizedBox(width: AppTheme.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pickup #${pickup['id']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        DateFormat('MMM d, yyyy - h:mm a').format(pickup['date']),
                        style: TextStyle(
                          color: AppTheme.grey600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingS,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusS),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingM),
            // Waste types
            Wrap(
              spacing: AppTheme.spacingS,
              children: (pickup['wasteTypes'] as List<String>).map((type) {
                return Chip(
                  label: Text(type),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                );
              }).toList(),
            ),
            const SizedBox(height: AppTheme.spacingM),
            // Address
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: AppTheme.grey600),
                const SizedBox(width: AppTheme.spacingS),
                Expanded(
                  child: Text(
                    pickup['address'],
                    style: TextStyle(color: AppTheme.grey700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingS),
            // Worker info (if completed)
            if (pickup['status'] == 'completed' && pickup['worker'] != null)
              Row(
                children: [
                  Icon(Icons.person, size: 16, color: AppTheme.grey600),
                  const SizedBox(width: AppTheme.spacingS),
                  Text(
                    'Collected by: ${pickup['worker']}',
                    style: TextStyle(color: AppTheme.grey700),
                  ),
                ],
              ),
            const SizedBox(height: AppTheme.spacingS),
            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (pickup['status'] == 'scheduled') ...[
                  TextButton(
                    onPressed: () => _reschedulePickup(pickup),
                    child: const Text('Reschedule'),
                  ),
                  const SizedBox(width: AppTheme.spacingS),
                  TextButton(
                    onPressed: () => _cancelPickup(pickup),
                    child: const Text('Cancel'),
                  ),
                ] else if (pickup['status'] == 'completed') ...[
                  TextButton(
                    onPressed: () => _viewReceipt(pickup),
                    child: const Text('View Receipt'),
                  ),
                  const SizedBox(width: AppTheme.spacingS),
                  TextButton(
                    onPressed: () => _ratePickup(pickup),
                    child: const Text('Rate Service'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _getMockPickup(int index) {
    final pickups = [
      {
        'id': 'PK2025001',
        'date': DateTime.now().subtract(const Duration(days: 1)),
        'status': 'completed',
        'wasteTypes': ['Dry', 'Wet'],
        'address': '123 Green Street, Ward 15',
        'worker': 'HKS Worker 001',
      },
      {
        'id': 'PK2025002',
        'date': DateTime.now().subtract(const Duration(days: 3)),
        'status': 'completed',
        'wasteTypes': ['Electronic'],
        'address': '456 Beach Road, Ward 15',
        'worker': 'HKS Worker 002',
      },
      {
        'id': 'PK2025003',
        'date': DateTime.now().add(const Duration(days: 1)),
        'status': 'scheduled',
        'wasteTypes': ['Dry', 'Wet', 'Recyclable'],
        'address': '789 Marine Drive, Ward 15',
        'worker': null,
      },
      {
        'id': 'PK2025004',
        'date': DateTime.now().subtract(const Duration(days: 7)),
        'status': 'cancelled',
        'wasteTypes': ['Bulk'],
        'address': '321 Calicut Beach, Ward 15',
        'worker': null,
      },
    ];
    return pickups[index % pickups.length];
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Pickups'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _filters.map((filter) {
            return RadioListTile<String>(
              title: Text(filter),
              value: filter,
              groupValue: _selectedFilter,
              onChanged: (value) {
                setState(() {
                  _selectedFilter = value!;
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _reschedulePickup(Map<String, dynamic> pickup) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reschedule Pickup'),
        content: const Text('Feature coming soon! You will be able to reschedule your pickup in the next update.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _cancelPickup(Map<String, dynamic> pickup) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Pickup'),
        content: const Text('Are you sure you want to cancel this pickup?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Pickup cancelled successfully'),
                  backgroundColor: AppTheme.success,
                ),
              );
            },
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  void _viewReceipt(Map<String, dynamic> pickup) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pickup Receipt'),
        content: const Text('Receipt feature coming soon! You will be able to view and download receipts in the next update.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _ratePickup(Map<String, dynamic> pickup) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rate Pickup Service'),
        content: const Text('Rating feature coming soon! You will be able to rate our pickup service in the next update.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
