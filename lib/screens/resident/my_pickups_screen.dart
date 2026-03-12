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
        title: const Text(
          'My Appointments',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -0.5),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: AppTheme.grey900,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Container(
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: AppTheme.primaryGreen,
                borderRadius: BorderRadius.circular(14),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: AppTheme.grey500,
              labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 0.5),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: 'ACTIVE'),
                Tab(text: 'HISTORY'),
                Tab(text: 'CLOSED'),
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
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
           Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date Box
                Container(
                  width: 56,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('dd').format(pickup['date']),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.primaryGreen,
                          height: 1,
                        ),
                      ),
                      Text(
                        DateFormat('MMM').format(pickup['date']).toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.primaryGreen,
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
                               fontWeight: FontWeight.w900,
                               color: AppTheme.grey900,
                               letterSpacing: -0.5,
                             ),
                           ),
                           _buildStatusBadge(pickup['status'], statusColor),
                         ],
                       ),
                       const SizedBox(height: 6),
                       Text(
                         pickup['address'],
                         style: const TextStyle(color: AppTheme.grey500, fontSize: 13, fontWeight: FontWeight.w500),
                         maxLines: 1,
                         overflow: TextOverflow.ellipsis,
                       ),
                       const SizedBox(height: 12),
                       Wrap(
                         spacing: 8,
                         children: (pickup['wasteTypes'] as List<String>).map((type) {
                           return Container(
                             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                             decoration: BoxDecoration(
                               color: AppTheme.grey50,
                               borderRadius: BorderRadius.circular(8),
                             ),
                             child: Text(
                               type.toUpperCase(),
                               style: TextStyle(
                                 fontSize: 9,
                                 fontWeight: FontWeight.w900,
                                 color: AppTheme.grey700,
                                 letterSpacing: 0.5,
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
             Padding(
               padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
               child: Row(
                 children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          backgroundColor: AppTheme.grey50,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text(
                          'RESCHEDULE',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          backgroundColor: AppTheme.error.withOpacity(0.05),
                          foregroundColor: AppTheme.error,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text(
                          'CANCEL',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                        ),
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
    if (status == 'upcoming') label = 'CONFIRMED';
    if (status == 'completed') label = 'COMPLETED';
    if (status == 'cancelled') label = 'CANCELLED';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
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
