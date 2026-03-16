import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
      backgroundColor: AppTheme.grey50,
      appBar: AppBar(
        title: const Text(
          'Collection History',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -0.5),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.grey900,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded, color: AppTheme.primaryGreen),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Summary Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'YOUR ACTIVITY',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.grey500,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard('Pickups', '24', AppTheme.primaryGreen, Icons.history_rounded),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildSummaryCard('Points', '340', AppTheme.warning, Icons.stars_rounded),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Filter Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: _filters.map((filter) {
                    final isSelected = _selectedFilter == filter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedFilter = filter),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? AppTheme.primaryGreen : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: isSelected 
                                  ? AppTheme.primaryGreen.withValues(alpha: 0.3)
                                  : Colors.black.withValues(alpha: 0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Text(
                            filter.toUpperCase(),
                            style: TextStyle(
                              color: isSelected ? Colors.white : AppTheme.grey600,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
          // List Section
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildPickupCard(_getMockPickup(index)),
                childCount: 8,
              ),
            ),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: AppTheme.grey900,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: AppTheme.grey500,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPickupCard(dynamic pickup) {
    Color statusColor;
    IconData statusIcon;

    switch (pickup['status']) {
      case 'completed':
        statusColor = AppTheme.success;
        statusIcon = Icons.check_circle_rounded;
        break;
      case 'scheduled':
        statusColor = AppTheme.info;
        statusIcon = Icons.schedule_rounded;
        break;
      case 'cancelled':
        statusColor = AppTheme.error;
        statusIcon = Icons.cancel_rounded;
        break;
      default:
        statusColor = AppTheme.grey600;
        statusIcon = Icons.help_outline_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(statusIcon, color: statusColor, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pickup['id'],
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          color: AppTheme.grey900,
                        ),
                      ),
                      Text(
                        DateFormat('EEE, MMM d • h:mm a').format(pickup['date']),
                        style: const TextStyle(
                          color: AppTheme.grey500,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.grey50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on_rounded, size: 16, color: AppTheme.primaryGreen),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      pickup['address'],
                      style: const TextStyle(
                        color: AppTheme.grey700,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (pickup['wasteTypes'] as List<String>).map((type) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.grey200),
                  ),
                  child: Text(
                    type,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.grey600,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                if (pickup['status'] == 'completed') ...[
                  const Icon(Icons.verified_rounded, size: 14, color: AppTheme.success),
                  const SizedBox(width: 6),
                  const Text(
                    'Collected by team',
                    style: TextStyle(color: AppTheme.success, fontSize: 11, fontWeight: FontWeight.w800),
                  ),
                ],
                const Spacer(),
                if (pickup['status'] == 'scheduled') ...[
                  TextButton(
                    onPressed: () => _reschedulePickup(pickup),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.primaryGreen,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: const Text('RESCHEDULE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.5)),
                  ),
                ] else if (pickup['status'] == 'completed') ...[
                  TextButton(
                    onPressed: () => _viewReceipt(pickup),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.primaryGreen,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: const Text('RECEIPT', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.5)),
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
      builder: (dialogContext) {
        String tempFilter = _selectedFilter;
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: const Text('Filter Pickups', style: TextStyle(fontWeight: FontWeight.w900)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: _filters.map((filter) {
                final isSelected = tempFilter == filter;
                return InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    setDialogState(() => tempFilter = filter);
                    setState(() => _selectedFilter = filter);
                    Navigator.pop(dialogContext);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    margin: const EdgeInsets.only(bottom: 4),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primaryEmerald.withValues(alpha: 0.08) : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppTheme.primaryEmerald.withValues(alpha: 0.3) : Colors.transparent,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
                          color: isSelected ? AppTheme.primaryEmerald : AppTheme.grey300,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          filter,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? AppTheme.primaryEmerald : AppTheme.grey700,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  void _reschedulePickup(Map<String, dynamic> pickup) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Reschedule Pickup', style: TextStyle(fontWeight: FontWeight.w900)),
        content: const Text('Feature coming soon! You will be able to reschedule your pickup in the next update.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(fontWeight: FontWeight.w900, color: AppTheme.primaryGreen)),
          ),
        ],
      ),
    );
  }

  void _viewReceipt(Map<String, dynamic> pickup) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Pickup Receipt', style: TextStyle(fontWeight: FontWeight.w900)),
        content: const Text('Receipt feature coming soon! You will be able to view and download receipts in the next update.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(fontWeight: FontWeight.w900, color: AppTheme.primaryGreen)),
          ),
        ],
      ),
    );
  }
}
