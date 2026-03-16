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
          'Collection Log',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w900, 
            fontSize: 18,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppTheme.bgDark,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.slateGradient,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded, size: 22, color: Colors.white),
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
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'NETWORK PERFORMANCE',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: AppTheme.grey400,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 24),
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
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.bgDark : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? AppTheme.bgDark : AppTheme.grey200.withValues(alpha: 0.5),
                          width: 1.5,
                        ),
                        boxShadow: isSelected ? [
                          BoxShadow(
                            color: AppTheme.bgDark.withValues(alpha: 0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          )
                        ] : AppTheme.smoothShadow,
                      ),
                      child: Text(
                        filter.toUpperCase(),
                        style: GoogleFonts.plusJakartaSans(
                          color: isSelected ? Colors.white : AppTheme.grey500,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
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
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: AppTheme.smoothShadow,
        border: Border.all(color: AppTheme.grey200.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 28),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              color: AppTheme.grey900,
              letterSpacing: -2,
            ),
          ),
          Text(
            title.toUpperCase(),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: AppTheme.grey400,
              letterSpacing: 1.5,
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
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: AppTheme.smoothShadow,
        border: Border.all(color: AppTheme.grey200.withValues(alpha: 0.5)),
      ),
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
                child: Icon(Icons.receipt_long_rounded, color: statusColor, size: 24),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pickup['id'],
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        color: AppTheme.grey900,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('EEE, MMM d — h:mm a').format(pickup['date']),
                      style: GoogleFonts.inter(
                        color: AppTheme.grey400,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: statusColor.withValues(alpha: 0.1)),
                ),
                child: Text(
                  statusLabel.toUpperCase(),
                  style: GoogleFonts.plusJakartaSans(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Icon(Icons.location_on_rounded, size: 16, color: statusColor.withValues(alpha: 0.5)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  pickup['address'],
                  style: GoogleFonts.inter(
                    color: AppTheme.grey600,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: (pickup['wasteTypes'] as List<String>).map((type) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.bgSurface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.grey100),
                    ),
                    child: Text(
                      type.toUpperCase(),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.grey700,
                        letterSpacing: 1,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const Spacer(),
              if (pickup['status'] == 'completed')
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.more_horiz_rounded, color: AppTheme.grey300),
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
