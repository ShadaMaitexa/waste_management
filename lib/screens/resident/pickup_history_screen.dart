import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
      backgroundColor: AppTheme.bgSurface,
      appBar: AppBar(
        title: Text(
          'COLLECTION LOG',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800, 
            fontSize: 12,
            letterSpacing: 2,
            color: AppTheme.grey400,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded, size: 22),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildActivityOverview(),
          _buildFilterModule(),
          _buildHistoryList(),
          const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
        ],
      ),
    );
  }

  Widget _buildActivityOverview() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'NETWORK PERFORMANCE',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: AppTheme.grey400,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryTile('Deployments', '24', AppTheme.primaryEmerald, Icons.history_rounded),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryTile('Impact Metric', '340', const Color(0xFFF59E0B), Icons.auto_awesome_rounded),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterModule() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _FilterHeaderDelegate(
        child: Container(
          color: AppTheme.bgSurface,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: _filters.map((filter) {
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedFilter = filter),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.bgDark : AppTheme.bgCanvas,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected ? AppTheme.bgDark : AppTheme.grey100,
                          ),
                          boxShadow: isSelected ? [
                            BoxShadow(
                              color: AppTheme.bgDark.withValues(alpha: 0.2),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            )
                          ] : null,
                        ),
                        child: Text(
                          filter.toUpperCase(),
                          style: GoogleFonts.plusJakartaSans(
                            color: isSelected ? Colors.white : AppTheme.grey500,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
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
    );
  }

  Widget _buildHistoryList() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => _buildHistoryCard(_getMockPickup(index)),
          childCount: 8,
        ),
      ),
    );
  }

  Widget _buildSummaryTile(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.bgCanvas,
        borderRadius: BorderRadius.circular(32),
        boxShadow: AppTheme.cardShadow,
        border: Border.all(color: AppTheme.grey100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 24),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: AppTheme.grey900,
              letterSpacing: -1.5,
            ),
          ),
          Text(
            title.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: AppTheme.grey400,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(dynamic pickup) {
    Color statusColor;
    String statusLabel;

    switch (pickup['status']) {
      case 'completed':
        statusColor = AppTheme.primaryEmerald;
        statusLabel = 'Recorded';
        break;
      case 'scheduled':
        statusColor = AppTheme.info;
        statusLabel = 'Pending';
        break;
      case 'cancelled':
        statusColor = AppTheme.error;
        statusLabel = 'Aborted';
        break;
      default:
        statusColor = AppTheme.grey500;
        statusLabel = 'Archive';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.bgCanvas,
        borderRadius: BorderRadius.circular(32),
        boxShadow: AppTheme.cardShadow,
        border: Border.all(color: AppTheme.grey100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.receipt_long_rounded, color: statusColor, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pickup['id'],
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: AppTheme.grey900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('EEE, MMM d — h:mm a').format(pickup['date']),
                      style: GoogleFonts.inter(
                        color: AppTheme.grey400,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusLabel,
                  style: GoogleFonts.inter(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 14, color: AppTheme.grey300),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  pickup['address'],
                  style: GoogleFonts.inter(
                    color: AppTheme.grey600,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Wrap(
                spacing: 6,
                children: (pickup['wasteTypes'] as List<String>).map((type) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.bgSurface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.grey100),
                    ),
                    child: Text(
                      type,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.grey700,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const Spacer(),
              if (pickup['status'] == 'completed')
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.more_horiz_rounded, color: AppTheme.grey400),
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
        ],
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
}

class _FilterHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  _FilterHeaderDelegate({required this.child});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => 64;
  @override
  double get minExtent => 64;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => true;
}
