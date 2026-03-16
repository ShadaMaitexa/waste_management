import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../services/admin_service.dart';

class AnalyticsDashboardScreen extends StatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  State<AnalyticsDashboardScreen> createState() =>
      _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends State<AnalyticsDashboardScreen> {
  String _selectedPeriod = 'This Month';
  final List<String> _periods = [
    'Today',
    'This Week',
    'This Month',
    'This Year'
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminService>(
      builder: (context, adminService, child) {
        final stats = adminService.systemStats;

        return Scaffold(
          backgroundColor: AppTheme.bgSurface,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(100),
            child: Container(
              padding: const EdgeInsets.only(top: 20),
              decoration: const BoxDecoration(
                color: AppTheme.bgDark,
                gradient: AppTheme.slateGradient,
              ),
              child: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                scrolledUnderElevation: 0,
                title: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Strategic Analytics',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w900,
                          fontSize: 24,
                          color: Colors.white,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Real-time system insight dashboard',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                foregroundColor: Colors.white,
                actions: [
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      setState(() => _selectedPeriod = value);
                    },
                    offset: const Offset(0, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    itemBuilder: (_) => _periods
                        .map(
                          (p) => PopupMenuItem(
                            value: p,
                            child: Row(
                              children: [
                                Icon(Icons.calendar_today_rounded, size: 16, color: AppTheme.grey400),
                                const SizedBox(width: 12),
                                Text(
                                  p, 
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.w700, 
                                    fontSize: 14,
                                    color: AppTheme.grey900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      margin: const EdgeInsets.only(right: 16, top: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                      ),
                      child: Row(
                        children: [
                          Text(
                            _selectedPeriod.toUpperCase(),
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white, 
                              fontWeight: FontWeight.w900, 
                              fontSize: 10, 
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          body: RefreshIndicator(
            onRefresh: () => adminService.fetchDashboardStats(),
            color: AppTheme.primaryEmerald,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildKeyMetricsSection(stats),
                  const SizedBox(height: 32),
                  _buildChartsSection(),
                  const SizedBox(height: 32),
                  _buildWardPerformanceSection(stats),
                  const SizedBox(height: 32),
                  _buildRecentAlertsSection(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ---------------- METRICS ----------------

  Widget _buildKeyMetricsSection(Map<String, dynamic> stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryEmerald.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.analytics_rounded, color: AppTheme.primaryEmerald, size: 20),
                ),
                const SizedBox(width: 16),
                Text(
                  'Key Indicators',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18, 
                    fontWeight: FontWeight.w900, 
                    color: AppTheme.grey900, 
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.error.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.error.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppTheme.error, shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  Text(
                    'LIVE',
                    style: GoogleFonts.plusJakartaSans(
                      color: AppTheme.error, 
                      fontSize: 8, 
                      fontWeight: FontWeight.w900, 
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        GridView.count(
          primary: false,
          shrinkWrap: true,
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.1,
          children: [
            _MetricCard(
              title: 'TOTAL REVENUE',
              value: '₹${stats['total_revenue'] ?? '4.8L'}',
              change: '+18.2%',
              icon: Icons.account_balance_wallet_rounded,
              color: AppTheme.primaryEmerald,
            ),
            _MetricCard(
              title: 'LOAD VOLUME',
              value: '${stats['total_pickups'] ?? '2,456'}',
              change: '+12%',
              icon: Icons.local_shipping_rounded,
              color: AppTheme.accentIndigo,
            ),
            _MetricCard(
              title: 'ACTIVE FLEET',
              value: '${stats['active_routes'] ?? '24'}',
              change: 'Stable',
              icon: Icons.route_rounded,
              color: AppTheme.info,
            ),
            _MetricCard(
              title: 'RESOLUTION',
              value: '92%',
              change: '+4%',
              icon: Icons.verified_user_rounded,
              color: AppTheme.warning,
            ),
          ],
        ),
      ],
    );
  }

  // ---------------- CHARTS ----------------

  Widget _buildChartsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.accentIndigo.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.pie_chart_rounded, color: AppTheme.accentIndigo, size: 20),
            ),
            const SizedBox(width: 16),
            Text(
              'System Distribution',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18, 
                fontWeight: FontWeight.w900, 
                color: AppTheme.grey900, 
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildLineChart(),
        const SizedBox(height: 16),
        _buildPieChart(),
      ],
    );
  }

  Widget _buildLineChart() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: AppTheme.smoothShadow,
        border: Border.all(color: AppTheme.grey200.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Collection Velocity (Weekly)',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w900, 
                color: AppTheme.grey900, 
                fontSize: 14, 
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: AppTheme.grey100,
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                          if (value.toInt() >= 0 && value.toInt() < days.length) {
                            return Text(
                              days[value.toInt()], 
                              style: GoogleFonts.inter(
                                fontSize: 10, 
                                color: AppTheme.grey400, 
                                fontWeight: FontWeight.w700,
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      isCurved: true,
                      barWidth: 5,
                      color: AppTheme.primaryEmerald,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primaryEmerald.withValues(alpha: 0.15),
                            AppTheme.primaryEmerald.withValues(alpha: 0.0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      spots: const [
                        FlSpot(0, 3.2),
                        FlSpot(1, 2.8),
                        FlSpot(2, 4.5),
                        FlSpot(3, 3.5),
                        FlSpot(4, 5.2),
                        FlSpot(5, 4.8),
                        FlSpot(6, 6.0),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: AppTheme.smoothShadow,
        border: Border.all(color: AppTheme.grey200.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Waste Composition',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w900, 
                    color: AppTheme.grey900, 
                    fontSize: 14, 
                    letterSpacing: -0.5,
                  ),
                ),
                Icon(Icons.more_vert_rounded, color: AppTheme.grey300, size: 20),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                SizedBox(
                  height: 160,
                  width: 160,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 4,
                      centerSpaceRadius: 40,
                      sections: [
                        PieChartSectionData(value: 35, color: AppTheme.dryWaste, radius: 20, showTitle: false),
                        PieChartSectionData(value: 25, color: AppTheme.wetWaste, radius: 22, showTitle: false),
                        PieChartSectionData(value: 20, color: AppTheme.accentGreen, radius: 18, showTitle: false),
                        PieChartSectionData(value: 20, color: AppTheme.ewaste, radius: 20, showTitle: false),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    children: [
                      _buildChartLegend('Dry Waste', '35%', AppTheme.dryWaste),
                      _buildChartLegend('Wet Waste', '25%', AppTheme.wetWaste),
                      _buildChartLegend('Bio-Waste', '20%', AppTheme.accentGreen),
                      _buildChartLegend('E-Waste', '20%', AppTheme.ewaste),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartLegend(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 10, 
            height: 10, 
            decoration: BoxDecoration(
              color: color, 
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label, 
              style: GoogleFonts.inter(
                fontSize: 12, 
                fontWeight: FontWeight.w600, 
                color: AppTheme.grey600,
              ),
            ),
          ),
          Text(
            value, 
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12, 
              fontWeight: FontWeight.w900, 
              color: AppTheme.grey900,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- WARD PERFORMANCE ----------------

  Widget _buildWardPerformanceSection(Map<String, dynamic> stats) {
    final hasWardStats = stats['ward'] != null && stats['ward']['ward_wise_stats'] != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.warning.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.location_on_rounded, color: AppTheme.warning, size: 20),
            ),
            const SizedBox(width: 16),
            Text(
              'Ward Performance',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18, 
                fontWeight: FontWeight.w900, 
                color: AppTheme.grey900, 
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: AppTheme.smoothShadow,
            border: Border.all(color: AppTheme.grey200.withValues(alpha: 0.5)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasWardStats) ..._buildDynamicWards(stats['ward']['ward_wise_stats'] as List)
                else ...const [
                  _WardItem('Ward 15 (Corporate)', '98%', 'Optimal', AppTheme.primaryEmerald),
                  Divider(height: 32),
                  _WardItem('Ward 12 (Residential)', '94%', 'Stable', AppTheme.primaryEmerald),
                  Divider(height: 32),
                  _WardItem('Ward 8 (Industrial)', '89%', 'Threshold', AppTheme.warning),
                  Divider(height: 32),
                  _WardItem('Ward 5 (Market Area)', '85%', 'Critical', AppTheme.error),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildDynamicWards(List dynamicWards) {
    final widgets = <Widget>[];
    for (int i = 0; i < dynamicWards.length; i++) {
        final wardObj = dynamicWards[i];
        final String wardName = wardObj['ward'] ?? 'Ward ${i+1}';
        final int pickups = wardObj['total_pickups'] ?? 0;
        final int complaints = wardObj['total_complaints'] ?? 0;
        
        double perf = pickups == 0 ? 0 : 100.0 - (complaints / (pickups + complaints)) * 100.0;
        if (perf.isNaN) perf = 90.0;
        String status = 'Optimal';
        Color color = AppTheme.primaryEmerald;
        if (perf < 90 && perf >= 80) { status = 'Stable'; }
        else if (perf < 80 && perf >= 60) { status = 'Threshold'; color = AppTheme.warning; }
        else if (perf < 60) { status = 'Critical'; color = AppTheme.error; }
        
        widgets.add(_WardItem(wardName, '${perf.toStringAsFixed(0)}%', status, color));
        if (i < dynamicWards.length - 1) widgets.add(const Divider(height: 32));
    }
    return widgets;
  }

  // ---------------- ALERTS ----------------

  Widget _buildRecentAlertsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.error.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.emergency_rounded, color: AppTheme.error, size: 20),
            ),
            const SizedBox(width: 16),
            Text(
              'System Compliance',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18, 
                fontWeight: FontWeight.w900, 
                color: AppTheme.grey900, 
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: AppTheme.smoothShadow,
            border: Border.all(color: AppTheme.grey200.withValues(alpha: 0.5)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _AlertItem('Capacity limit reached in Central Hub', 'JUST NOW', Icons.error_rounded, AppTheme.error),
                Divider(height: 32),
                _AlertItem('Ward 12 collection volume exceeds forecast', '2H AGO', Icons.info_rounded, AppTheme.info),
                Divider(height: 32),
                _AlertItem('Low worker check-in rate in Zone 5', '4H AGO', Icons.warning_rounded, AppTheme.warning),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------- SMALL WIDGETS ----------------

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.change,
    required this.icon,
    required this.color,
  });

  final String title, value, change;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isPositive = change.startsWith('+');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
        border: Border.all(color: AppTheme.grey200.withValues(alpha: 0.5), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isPositive ? AppTheme.primaryEmerald.withValues(alpha: 0.1) : AppTheme.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    change,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: isPositive ? AppTheme.primaryEmerald : AppTheme.error,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: AppTheme.grey900,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 9,
                fontWeight: FontWeight.w900,
                color: AppTheme.grey400,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WardItem extends StatelessWidget {
  const _WardItem(this.ward, this.percent, this.status, this.color);

  final String ward, percent, status;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final value = double.tryParse(percent.replaceAll('%', '')) ?? 0;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ward,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800, 
                  fontSize: 16,
                  color: AppTheme.grey900,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                status.toUpperCase(), 
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 9, 
                  fontWeight: FontWeight.w900, 
                  color: color, 
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              percent,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w900,
                fontSize: 20,
                color: AppTheme.grey900,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 80,
              height: 6,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: value / 100,
                  backgroundColor: color.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AlertItem extends StatelessWidget {
  const _AlertItem(this.text, this.time, this.icon, this.color);

  final String text, time;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                text,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.grey800,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                time,
                style: GoogleFonts.plusJakartaSans(
                  color: AppTheme.grey400,
                  fontWeight: FontWeight.w900,
                  fontSize: 9,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
        Icon(Icons.chevron_right_rounded, color: AppTheme.grey200, size: 20),
      ],
    );
  }
}
