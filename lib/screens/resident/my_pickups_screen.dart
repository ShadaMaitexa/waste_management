import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/pickup.dart';
import '../../services/pickup_service.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';

class MyPickupsScreen extends StatefulWidget {
  const MyPickupsScreen({super.key});

  @override
  State<MyPickupsScreen> createState() => _MyPickupsScreenState();
}

class _MyPickupsScreenState extends State<MyPickupsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Pickups'),
        elevation: 0,
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Completed'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search and Filter Bar
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search pickups...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusM),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingM,
                        vertical: 8,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.toLowerCase();
                      });
                    },
                  ),
                ),
                const SizedBox(width: AppTheme.spacingS),
                IconButton(
                  onPressed: _showFilterDialog,
                  icon: const Icon(Icons.filter_list),
                  style: IconButton.styleFrom(
                    backgroundColor: AppTheme.grey100,
                  ),
                ),
              ],
            ),
          ),
          // Pickup Statistics
          _buildStatisticsRow(),
          const SizedBox(height: AppTheme.spacingM),
          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPickupList('upcoming'),
                _buildPickupList('completed'),
                _buildPickupList('cancelled'),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/book-pickup');
        },
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatisticsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'This Month',
              '8',
              AppTheme.primaryGreen,
              Icons.calendar_today,
            ),
          ),
          const SizedBox(width: AppTheme.spacingS),
          Expanded(
            child: _buildStatCard(
              'Points Earned',
              '240',
              AppTheme.warning,
              Icons.stars,
            ),
          ),
          const SizedBox(width: AppTheme.spacingS),
          Expanded(
            child: _buildStatCard(
              'Avg Rating',
              '4.8',
              AppTheme.success,
              Icons.thumb_up,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                color: AppTheme.grey600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPickupList(String status) {
    final mockPickups = _getMockPickups(status);
    
    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      itemCount: mockPickups.length,
      itemBuilder: (context, index) {
        return _buildPickupCard(mockPickups[index]);
      },
    );
  }

  Widget _buildPickupCard(Map<String, dynamic> pickup) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (pickup['status']) {
      case 'completed':
        statusColor = AppTheme.success;
        statusIcon = Icons.check_circle;
        statusText = 'Completed';
        break;
      case 'upcoming':
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
            // Header Row
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
                        DateFormat('MMM d, yyyy • h:mm a').format(pickup['date']),
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
            // Waste Types
            Wrap(
              spacing: AppTheme.spacingS,
              children: (pickup['wasteTypes'] as List<String>).map((type) {
                return Chip(
                  label: Text(type),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  backgroundColor: AppTheme.primaryGreen.withOpacity(0.1),
                  labelStyle: const TextStyle(
                    color: AppTheme.primaryGreen,
                    fontWeight: FontWeight.w500,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppTheme.spacingM),
            // Address and Details
            _buildDetailRow(Icons.location_on, pickup['address']),
            const SizedBox(height: AppTheme.spacingS),
            _buildDetailRow(Icons.access_time, 
                'Duration: ${pickup['estimatedDuration']} mins'),
            if (pickup['specialInstructions'] != null) ...[
              const SizedBox(height: AppTheme.spacingS),
              _buildDetailRow(Icons.note, pickup['specialInstructions']),
            ],
            if (pickup['worker'] != null) ...[
              const SizedBox(height: AppTheme.spacingS),
              _buildDetailRow(Icons.person, 'Worker: ${pickup['worker']}'),
            ],
            const SizedBox(height: AppTheme.spacingM),
            // Action Buttons
            _buildActionButtons(pickup),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppTheme.grey600),
        const SizedBox(width: AppTheme.spacingS),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: AppTheme.grey700),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(Map<String, dynamic> pickup) {
    final List<Widget> buttons = [];

    if (pickup['status'] == 'upcoming') {
      buttons.addAll([
        Expanded(
          child: OutlinedButton(
            onPressed: () => _reschedulePickup(pickup),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primaryGreen,
              side: BorderSide(color: AppTheme.primaryGreen),
            ),
            child: const Text('Reschedule'),
          ),
        ),
        const SizedBox(width: AppTheme.spacingS),
        Expanded(
          child: ElevatedButton(
            onPressed: () => _cancelPickup(pickup),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Cancel'),
          ),
        ),
      ]);
    } else if (pickup['status'] == 'completed') {
      buttons.addAll([
        Expanded(
          child: OutlinedButton(
            onPressed: () => _viewReceipt(pickup),
            child: const Text('Receipt'),
          ),
        ),
        const SizedBox(width: AppTheme.spacingS),
        Expanded(
          child: ElevatedButton(
            onPressed: () => _ratePickup(pickup),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.white,
            ),
            child: const Text('Rate'),
          ),
        ),
      ]);
    } else if (pickup['status'] == 'cancelled') {
      buttons.add(
        Expanded(
          child: ElevatedButton(
            onPressed: () => _bookAgain(pickup),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.white,
            ),
            child: const Text('Book Again'),
          ),
        ),
      );
    }

    return Row(
      children: buttons,
    );
  }

  List<Map<String, dynamic>> _getMockPickups(String status) {
    final allPickups = [
      {
        'id': 'PK2025001',
        'date': DateTime.now().add(const Duration(hours: 2)),
        'status': 'upcoming',
        'wasteTypes': ['Dry', 'Wet'],
        'address': '123 Green Street, Ward 15',
        'estimatedDuration': 30,
        'specialInstructions': 'Please ring the bell twice',
        'worker': null,
      },
      {
        'id': 'PK2025002',
        'date': DateTime.now().subtract(const Duration(days: 1)),
        'status': 'completed',
        'wasteTypes': ['Electronic', 'Dry'],
        'address': '456 Beach Road, Ward 15',
        'estimatedDuration': 45,
        'worker': 'HKS Worker 001',
      },
      {
        'id': 'PK2025003',
        'date': DateTime.now().subtract(const Duration(days: 3)),
        'status': 'completed',
        'wasteTypes': ['Wet', 'Organic'],
        'address': '789 Marine Drive, Ward 15',
        'estimatedDuration': 25,
        'worker': 'HKS Worker 002',
      },
      {
        'id': 'PK2025004',
        'date': DateTime.now().subtract(const Duration(days: 7)),
        'status': 'cancelled',
        'wasteTypes': ['Bulk'],
        'address': '321 Calicut Beach, Ward 15',
        'estimatedDuration': 90,
        'specialInstructions': 'Large furniture items',
      },
      {
        'id': 'PK2025005',
        'date': DateTime.now().add(const Duration(days: 1, hours: 3)),
        'status': 'upcoming',
        'wasteTypes': ['Recyclable', 'Dry'],
        'address': '654 Palayam, Ward 15',
        'estimatedDuration': 35,
        'worker': null,
      },
    ];

    return allPickups.where((pickup) => pickup['status'] == status).toList();
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Pickups'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CheckboxListTile(
              title: const Text('Today'),
              value: false,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: const Text('This Week'),
              value: false,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: const Text('This Month'),
              value: false,
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _applyFilters();
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _applyFilters() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Filters applied'),
        backgroundColor: AppTheme.success,
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

  void _bookAgain(Map<String, dynamic> pickup) {
    Navigator.pushNamed(context, '/book-pickup');
  }
}
