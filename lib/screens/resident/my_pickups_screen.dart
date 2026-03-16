import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
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
      backgroundColor: AppTheme.bgSurface,
      appBar: AppBar(
        title: Text(
          'Operational Schedule',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: AppTheme.grey900,
        elevation: 0,
        leading: Navigator.canPop(context) 
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Container(
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppTheme.bgCanvas,
              borderRadius: BorderRadius.circular(20),
              boxShadow: AppTheme.cardShadow,
              border: Border.all(color: AppTheme.grey200),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: AppTheme.primaryEmerald,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryEmerald.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              ),
              labelColor: Colors.white,
              unselectedLabelColor: AppTheme.grey500,
              labelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.5),
              unselectedLabelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 11),
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
        backgroundColor: AppTheme.primaryEmerald,
        icon: const Icon(Icons.add_task_rounded, color: Colors.white),
        label: Text('Schedule', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold)),
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
            Icon(Icons.inbox_rounded, size: 64, color: AppTheme.grey200),
            const SizedBox(height: 16),
            Text(
              'No $status schedules',
              style: GoogleFonts.plusJakartaSans(color: AppTheme.grey500, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.spacingL),
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
        color: AppTheme.bgCanvas,
        borderRadius: BorderRadius.circular(28),
        boxShadow: AppTheme.cardShadow,
        border: Border.all(color: AppTheme.grey200),
      ),
      child: Column(
        children: [
           Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56,
                  height: 64,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: statusColor.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('dd').format(pickup['date']),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: statusColor,
                          height: 1,
                        ),
                      ),
                      Text(
                        DateFormat('MMM').format(pickup['date']).toUpperCase(),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: statusColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       Row(
                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                         children: [
                           Text(
                             DateFormat('h:mm a').format(pickup['date']),
                             style: GoogleFonts.plusJakartaSans(
                               fontSize: 16,
                               fontWeight: FontWeight.w800,
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
                         style: GoogleFonts.plusJakartaSans(color: AppTheme.grey500, fontSize: 13, fontWeight: FontWeight.w600),
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
                               color: AppTheme.grey100,
                               borderRadius: BorderRadius.circular(8),
                             ),
                             child: Text(
                               type.toUpperCase(),
                               style: GoogleFonts.plusJakartaSans(
                                 fontSize: 9,
                                 fontWeight: FontWeight.w800,
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
             const Padding(
               padding: EdgeInsets.symmetric(horizontal: 24),
               child: Divider(height: 1, color: AppTheme.grey200),
             ),
             Padding(
               padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
               child: Row(
                 children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          backgroundColor: AppTheme.bgSurface,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          side: const BorderSide(color: AppTheme.grey200),
                        ),
                        child: Text(
                          'MODIFY',
                          style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.5, color: AppTheme.grey700),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          backgroundColor: AppTheme.error.withValues(alpha: 0.05),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text(
                          'ABORT',
                          style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.5, color: AppTheme.error),
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
    if (status == 'completed') label = 'RESOLVED';
    if (status == 'cancelled') label = 'ABORTED';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
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
      case 'upcoming': return AppTheme.primaryEmerald;
      case 'completed': return AppTheme.grey500;
      case 'cancelled': return AppTheme.error;
      default: return AppTheme.grey400;
    }
  }

  List<Map<String, dynamic>> _getMockPickups(String status) {
     final allPickups = [
      {
        'id': 'PK2025001',
        'date': DateTime.now().add(const Duration(hours: 2)),
        'status': 'upcoming',
        'wasteTypes': ['Dry', 'Wet'],
        'address': '123 Smart Residences, Ward 15',
      },
      {
        'id': 'PK2025005',
        'date': DateTime.now().add(const Duration(days: 2)),
        'status': 'upcoming',
        'wasteTypes': ['E-Waste'],
        'address': '123 Smart Residences, Ward 15',
      },
      {
        'id': 'PK2025002',
        'date': DateTime.now().subtract(const Duration(days: 1)),
        'status': 'completed',
        'wasteTypes': ['Plastic', 'Dry'],
        'address': '456 Coastal Road, Ward 15',
      },
      {
        'id': 'PK2025004',
        'date': DateTime.now().subtract(const Duration(days: 7)),
        'status': 'cancelled',
        'wasteTypes': ['Bulk'],
        'address': '321 Calicut Strip, Ward 15',
      },
    ];
    return allPickups.where((p) => p['status'] == status).toList();
  }
}
