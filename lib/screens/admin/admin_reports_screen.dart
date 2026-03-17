import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
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
      backgroundColor: AppTheme.bgSurface,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: Container(
          padding: const EdgeInsets.only(top: 20),
          decoration: const BoxDecoration(
            color: AppTheme.bgSurface,
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            centerTitle: false,
            title: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Reports Engine',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w900,
                  fontSize: 28,
                  color: AppTheme.grey900,
                  letterSpacing: -1.5,
                ),
              ),
            ),
            foregroundColor: AppTheme.grey900,
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 20, top: 12),
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.grey100),
                  boxShadow: AppTheme.cardShadow,
                ),
                child: IconButton(
                  icon: const Icon(Icons.share_rounded, color: AppTheme.grey900, size: 18),
                  onPressed: () {},
                  padding: EdgeInsets.zero,
                ),
              ),
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
                      padding: const EdgeInsets.only(bottom: 120),
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
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryEmerald.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: _showGenerateReportDialog,
          backgroundColor: AppTheme.primaryEmerald,
          elevation: 0,
          highlightElevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          icon: const Icon(Icons.insights_rounded, color: Colors.white),
          label: Text(
            'GENERATE REPORT', 
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white, 
              fontWeight: FontWeight.w900, 
              letterSpacing: 1.5,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRevenueOverview() {
    final total = _revenueStats['total_revenue'] ?? _revenueStats['total_fees'] ?? '3,450.00';
    final growth = _revenueStats['revenue_growth'] ?? '+18.2%';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.bgDark,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.bgDark, Color(0xFF1E293B)],
        ),
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: AppTheme.bgDark.withValues(alpha: 0.3),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: Text(
                  'SYSTEM REVENUE',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white.withValues(alpha: 0.4), 
                    fontWeight: FontWeight.w900, 
                    fontSize: 8, 
                    letterSpacing: 2,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryEmerald.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  growth,
                  style: GoogleFonts.plusJakartaSans(
                    color: AppTheme.primaryEmerald, 
                    fontWeight: FontWeight.w900, 
                    fontSize: 10,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            '₹$total',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 44,
              fontWeight: FontWeight.w900,
              letterSpacing: -2.5,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 36),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05), width: 1.5),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _revenueSubStat('Fees Collected', '₹${_revenueStats['fees_collected'] ?? '2,140'}'),
                  _buildSubStatDivider(),
                  _revenueSubStat('Pending Dues', '₹${_revenueStats['pending_dues'] ?? '430'}'),
                  _buildSubStatDivider(),
                  _revenueSubStat('Growth Index', growth),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubStatDivider() {
    return Container(
      width: 1.5,
      height: 32,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      color: Colors.white.withValues(alpha: 0.08),
    );
  }

  Widget _revenueSubStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(), 
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white.withValues(alpha: 0.4), 
            fontSize: 8, 
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value, 
          style: GoogleFonts.inter(
            color: Colors.white, 
            fontWeight: FontWeight.w800, 
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    return Container(
      height: 48,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: _reportTypes.length,
        itemBuilder: (context, index) {
          final type = _reportTypes[index];
          final isSelected = _selectedType == type;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => setState(() => _selectedType = type),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primaryEmerald : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? AppTheme.primaryEmerald : AppTheme.grey200,
                    width: 1.5,
                  ),
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: AppTheme.primaryEmerald.withValues(alpha: 0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ] : null,
                ),
                child: Center(
                  child: Text(
                    type.toUpperCase(),
                    style: GoogleFonts.plusJakartaSans(
                      color: isSelected ? Colors.white : AppTheme.grey500,
                      fontWeight: FontWeight.w900,
                      fontSize: 10,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
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
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppTheme.grey100, width: 1.5),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(32),
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
                    size: 24,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title, 
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w900, 
                          fontSize: 15, 
                          color: AppTheme.grey900, 
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.calendar_today_rounded, size: 10, color: AppTheme.grey400),
                          const SizedBox(width: 6),
                          Text(
                            date, 
                            style: GoogleFonts.inter(
                              color: AppTheme.grey400, 
                              fontSize: 11, 
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(width: 3, height: 3, decoration: BoxDecoration(color: AppTheme.grey200, shape: BoxShape.circle)),
                          const SizedBox(width: 12),
                          Text(
                            '2.4 MB', 
                            style: GoogleFonts.inter(
                              color: AppTheme.grey300, 
                              fontSize: 11, 
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.grey50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.arrow_forward_ios_rounded, color: AppTheme.grey400, size: 14),
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
