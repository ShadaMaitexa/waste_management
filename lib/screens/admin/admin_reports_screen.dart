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
      appBar: AppBar(
        title: const Text('Strategic Intelligence'),
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (_revenueStats.isNotEmpty) _buildRevenueOverview(),
                _buildFilters(),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _fetchStats,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: 8,
                      itemBuilder: (context, index) {
                        return _buildReportCard(index);
                      },
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showGenerateReportDialog,
        backgroundColor: AppTheme.primaryEmerald,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Generate Intelligence', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _revenueSubStat('Fees Collected', '₹${_revenueStats['fees_collected'] ?? '2,140'}'),
              _revenueSubStat('Pending Dues', '₹${_revenueStats['pending_dues'] ?? '430'}'),
              _revenueSubStat('Growth Index', growth),
            ],
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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: _reportTypes.map((type) {
          final isSelected = _selectedType == type;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ChoiceChip(
              label: Text(type),
              selected: isSelected,
              onSelected: (_) => setState(() => _selectedType = type),
              backgroundColor: Colors.white,
              selectedColor: AppTheme.primaryEmerald.withValues(alpha: 0.1),
              labelStyle: TextStyle(
                color: isSelected ? AppTheme.primaryEmerald : AppTheme.grey500,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                fontSize: 13,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: isSelected ? AppTheme.primaryEmerald : AppTheme.grey200)),
              showCheckmark: false,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildReportCard(int index) {
    final titles = ['Daily Operations Log', 'Financial Quarter Summary', 'Ward Performance Audit', 'Waste Recovery Index'];
    final title = titles[index % titles.length];
    final date = DateFormat('MMM d, yyyy').format(DateTime.now().subtract(Duration(days: index)));
    final isFinancial = index % 2 != 0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16, left: 20, right: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.grey100),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (isFinancial ? AppTheme.accentIndigo : AppTheme.primaryEmerald).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              isFinancial ? Icons.payments_rounded : Icons.analytics_rounded,
              color: isFinancial ? AppTheme.accentIndigo : AppTheme.primaryEmerald,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppTheme.grey900)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(date, style: const TextStyle(color: AppTheme.grey400, fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 8),
                    Container(width: 4, height: 4, decoration: const BoxDecoration(color: AppTheme.grey300, shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    Text('PDF • 2.4 MB', style: TextStyle(color: AppTheme.grey400, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.download_for_offline_rounded, color: AppTheme.grey300),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  void _showGenerateReportDialog() {
    // Dialog implementation...
  }
}
