import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';

class MyPickupsScreen extends StatefulWidget {
  const MyPickupsScreen({super.key});

  @override
  State<MyPickupsScreen> createState() => _MyPickupsScreenState();
}

class _MyPickupsScreenState extends State<MyPickupsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.grey50,
      appBar: AppBar(
        title: const Text('My Pickups'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.grey900,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppTheme.grey100,
              borderRadius: BorderRadius.circular(25),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              labelColor: AppTheme.primaryGreen,
              unselectedLabelColor: AppTheme.grey600,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: 'Upcoming'),
                Tab(text: 'History'),
                Tab(text: 'Cancelled'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPickupList('upcoming'),
          _buildPickupList('completed'),
          _buildPickupList('cancelled'),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/book-pickup'),
        backgroundColor: AppTheme.primaryGreen,
        icon: const Icon(Icons.add),
        label: const Text('Book New'),
      ),
    );
  }

  Widget _buildPickupList(String status) {
    final mockPickups = _getMockPickups(status);

    if (mockPickups.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: AppTheme.grey400),
            const SizedBox(height: 16),
            Text(
              'No $status pickups',
              style: const TextStyle(color: AppTheme.grey600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      itemCount: mockPickups.length,
      itemBuilder: (context, index) {
        return _buildPickupCard(mockPickups[index]);
      },
    );
  }

  Widget _buildPickupCard(Map<String, dynamic> pickup) {
    final isUpcoming = pickup['status'] == 'upcoming';
    final statusColor = _getStatusColor(pickup['status']);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
           Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date Box
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.grey100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.grey200),
                  ),
                  child: Column(
                    children: [
                      Text(
                        DateFormat('MMM').format(pickup['date']),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.grey600,
                        ),
                      ),
                      Text(
                        DateFormat('dd').format(pickup['date']),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.grey900,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       Row(
                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                         children: [
                           Text(
                            DateFormat('h:mm a').format(pickup['date']),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.grey900,
                            ),
                           ),
                           _buildStatusBadge(pickup['status'], statusColor),
                         ],
                       ),
                       const SizedBox(height: 8),
                       Text(
                         pickup['address'],
                         style: const TextStyle(color: AppTheme.grey600, fontSize: 14),
                         maxLines: 1,
                         overflow: TextOverflow.ellipsis,
                       ),
                       const SizedBox(height: 8),
                       Wrap(
                         spacing: 8,
                         children: (pickup['wasteTypes'] as List<String>).map((type) {
                           return Container(
                             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                             decoration: BoxDecoration(
                               color: AppTheme.primaryGreen.withOpacity(0.05),
                               borderRadius: BorderRadius.circular(4),
                               border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.2)),
                             ),
                             child: Text(
                               type,
                               style: const TextStyle(
                                 fontSize: 10,
                                 fontWeight: FontWeight.w600,
                                 color: AppTheme.primaryGreen,
                               ),
                             ),
                           );
                         }).toList(),
                       ),
                    ],
                  ),
                ),
              ],
            ),
           ),
           if (isUpcoming) ...[
             const Divider(height: 1, indent: 16, endIndent: 16),
             Padding(
               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
               child: Row(
                 children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {},
                        child: const Text('Reschedule'),
                      ),
                    ),
                    Expanded(
                      child: TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(foregroundColor: AppTheme.error),
                        child: const Text('Cancel'),
                      ),
                    ),
                 ],
               ),
             )
           ]
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status, Color color) {
    String label = status.toUpperCase();
    if (status == 'upcoming') label = 'SCHEDULED';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'upcoming': return AppTheme.primaryGreen;
      case 'completed': return AppTheme.grey600; // Muted for completed
      case 'cancelled': return AppTheme.error;
      default: return AppTheme.grey500;
    }
  }

  List<Map<String, dynamic>> _getMockPickups(String status) {
     final allPickups = [
      {
        'id': 'PK2025001',
        'date': DateTime.now().add(const Duration(hours: 2)),
        'status': 'upcoming',
        'wasteTypes': ['Dry', 'Wet'],
        'address': '123 Green Street, Ward 15',
      },
      {
        'id': 'PK2025005',
        'date': DateTime.now().add(const Duration(days: 2)),
        'status': 'upcoming',
        'wasteTypes': ['E-Waste'],
        'address': '123 Green Street, Ward 15',
      },
      {
        'id': 'PK2025002',
        'date': DateTime.now().subtract(const Duration(days: 1)),
        'status': 'completed',
        'wasteTypes': ['Plastic', 'Dry'],
        'address': '456 Beach Road, Ward 15',
      },
      {
        'id': 'PK2025004',
        'date': DateTime.now().subtract(const Duration(days: 7)),
        'status': 'cancelled',
        'wasteTypes': ['Bulk'],
        'address': '321 Calicut Beach, Ward 15',
      },
    ];
    return allPickups.where((p) => p['status'] == status).toList();
  }
}
