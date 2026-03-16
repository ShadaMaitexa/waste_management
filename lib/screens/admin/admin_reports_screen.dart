import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/admin_service.dart';
import '../../theme/app_theme.dart';
import 'package:intl/intl.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  String _selectedType = 'All';
  final List<String> _reportTypes = ['All', 'Collection', 'Financial', 'Performance', 'Audit'];
  Map<String, dynamic> _revenueStats = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    setState(() => _isLoading = true);
    final stats = await context.read<AdminService>().fetchRevenueStats();
    if (mounted) {
      setState(() {
        _revenueStats = stats;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.grey50,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          padding: const EdgeInsets.only(top: 10),
          decoration: const BoxDecoration(
            gradient: AppTheme.slateGradient,
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            title: const Text(
              'Strategic Intelligence',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 22,
                color: Colors.white,
                letterSpacing: -0.8,
              ),
            ),
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.share_rounded, color: Colors.white70),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryEmerald))
          : Column(
              children: [
                if (_revenueStats.isNotEmpty) _buildRevenueOverview(),
                _buildFilters(),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _fetchStats,
                    color: AppTheme.primaryEmerald,
                    child: ListView.builder(
                      padding: const EdgeInsets.only(bottom: 100),
                      physics: const BouncingScrollPhysics(),
                      itemCount: 8,
                      itemBuilder: (context, index) {
                        return _buildReportCard(index);
                      },
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryEmerald.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: _showGenerateReportDialog,
          backgroundColor: AppTheme.primaryEmerald,
          elevation: 0,
          highlightElevation: 0,
          icon: const Icon(Icons.insights_rounded, color: Colors.white),
          label: const Text('GENERATE REPORT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1)),
        ),
      ),
    );
  }

  Widget _buildRevenueOverview() {
    final total = _revenueStats['total_revenue'] ?? _revenueStats['total_fees'] ?? '3,450.00';
    final growth = _revenueStats['revenue_growth'] ?? '+18.2%';

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: AppTheme.slateGradient,
        borderRadius: BorderRadius.circular(32),
        boxShadow: AppTheme.intenseShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'SYSTEM REVENUE (KMC)',
                style: TextStyle(color: Colors.white60, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.5),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryEmerald.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  growth,
                  style: const TextStyle(color: AppTheme.primaryEmerald, fontWeight: FontWeight.w900, fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '₹$total',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.5,
            ),
          ),
          const SizedBox(height: 24),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _revenueSubStat('Fees Collected', '₹${_revenueStats['fees_collected'] ?? '2,140'}'),
                const SizedBox(width: 24),
                _revenueSubStat('Pending Dues', '₹${_revenueStats['pending_dues'] ?? '430'}'),
                const SizedBox(width: 24),
                _revenueSubStat('Growth Index', growth),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _revenueSubStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: const TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.w900)),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
      ],
    );
  }

  Widget _buildFilters() {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _reportTypes.length,
        itemBuilder: (context, index) {
          final type = _reportTypes[index];
          final isSelected = _selectedType == type;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ChoiceChip(
              label: Text(type.toUpperCase()),
              selected: isSelected,
              onSelected: (_) => setState(() => _selectedType = type),
              backgroundColor: Colors.white,
              selectedColor: AppTheme.primaryEmerald,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppTheme.grey500,
                fontWeight: FontWeight.w900,
                fontSize: 11,
                letterSpacing: 0.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(
                  color: isSelected ? AppTheme.primaryEmerald : AppTheme.grey200,
                  width: 1.5,
                ),
              ),
              showCheckmark: false,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              elevation: isSelected ? 4 : 0,
              shadowColor: AppTheme.primaryEmerald.withValues(alpha: 0.3),
            ),
          );
        },
      ),
    );
  }

  Widget _buildReportCard(int index) {
    final titles = ['Daily Operations Log', 'Financial Quarter Summary', 'Ward Performance Audit', 'Waste Recovery Index'];
    final title = titles[index % titles.length];
    final date = DateFormat('MMM d, yyyy').format(DateTime.now().subtract(Duration(days: index)));
    final isFinancial = index % 2 != 0;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppTheme.grey100, width: 1),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(28),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (isFinancial ? AppTheme.accentIndigo : AppTheme.primaryEmerald).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    isFinancial ? Icons.analytics_rounded : Icons.summarize_rounded,
                    color: isFinancial ? AppTheme.accentIndigo : AppTheme.primaryEmerald,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title, 
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppTheme.grey900, letterSpacing: -0.3),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Icon(Icons.calendar_today_rounded, size: 12, color: AppTheme.grey400),
                          const SizedBox(width: 6),
                          Text(
                            date, 
                            style: const TextStyle(color: AppTheme.grey400, fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(width: 12),
                          Container(width: 4, height: 4, decoration: const BoxDecoration(color: AppTheme.grey200, shape: BoxShape.circle)),
                          const SizedBox(width: 12),
                          Text(
                            '2.4 MB', 
                            style: TextStyle(color: AppTheme.grey300, fontSize: 11, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.grey50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.download_for_offline_rounded, color: AppTheme.grey400, size: 22),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showGenerateReportDialog() {
    // Dialog implementation...
  }
}
