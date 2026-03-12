import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../theme/app_theme.dart';

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
    return Scaffold(
      backgroundColor: AppTheme.grey50,
      appBar: AppBar(
        title: const Text(
          'Strategic Analytics',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: -0.5),
        ),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() => _selectedPeriod = value);
            },
            itemBuilder: (_) => _periods
                .map(
                  (p) => PopupMenuItem(
                    value: p,
                    child: Text(p, style: const TextStyle(fontWeight: FontWeight.w500)),
                  ),
                )
                .toList(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white24),
              ),
              child: Row(
                children: [
                  Text(
                    _selectedPeriod,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildKeyMetricsSection(),
            const SizedBox(height: AppTheme.spacingL),
            _buildChartsSection(),
            const SizedBox(height: AppTheme.spacingL),
            _buildWardPerformanceSection(),
            const SizedBox(height: AppTheme.spacingL),
            _buildRecentAlertsSection(),
          ],
        ),
      ),
    );
  }

  // ---------------- METRICS ----------------

  Widget _buildKeyMetricsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.insert_chart_outlined_rounded, color: AppTheme.primaryGreen, size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              'Key Performance Metrics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.grey900, letterSpacing: -0.5),
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
          childAspectRatio: 1.2,
          children: const [
            _MetricCard(
              title: 'TOTAL PICKUPS',
              value: '2,456',
              change: '+12%',
              icon: Icons.recycling_rounded,
              color: Color(0xFF6366F1),
            ),
            _MetricCard(
              title: 'COLLECTION RATE',
              value: '94.5%',
              change: '+2.1%',
              icon: Icons.trending_up_rounded,
              color: AppTheme.success,
            ),
            _MetricCard(
              title: 'ACTIVE ROUTES',
              value: '24',
              change: '+2',
              icon: Icons.route_rounded,
              color: AppTheme.info,
            ),
            _MetricCard(
              title: 'COMPLAINTS',
              value: '12',
              change: '-8',
              icon: Icons.report_problem_rounded,
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
        const Text(
          'Analytics Overview',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppTheme.spacingM),
        _buildLineChart(),
        const SizedBox(height: AppTheme.spacingM),
        _buildPieChart(),
      ],
    );
  }

  Widget _buildLineChart() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Weekly Collection Volume (kg)',
              style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.grey600, fontSize: 13),
            ),
            const SizedBox(height: 24),
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
                  titlesData: FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      isCurved: true,
                      barWidth: 4,
                      color: AppTheme.primaryGreen,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primaryGreen.withOpacity(0.2),
                            AppTheme.primaryGreen.withOpacity(0.0),
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
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.grey300.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sections: [
                PieChartSectionData(
                  value: 35,
                  title: '35%',
                  radius: 60,
                  color: AppTheme.dryWaste,
                ),
                PieChartSectionData(
                  value: 25,
                  title: '25%',
                  radius: 60,
                  color: AppTheme.wetWaste,
                ),
                PieChartSectionData(
                  value: 20,
                  title: '20%',
                  radius: 60,
                  color: AppTheme.accentGreen,
                ),
                PieChartSectionData(
                  value: 20,
                  title: '20%',
                  radius: 60,
                  color: AppTheme.ewaste,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- WARD PERFORMANCE ----------------

  Widget _buildWardPerformanceSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.grey300.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Ward-wise Performance',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: AppTheme.spacingM),
            _WardItem('Ward 15', '98%', 'Excellent', AppTheme.success),
            Divider(),
            _WardItem('Ward 12', '94%', 'Good', AppTheme.success),
            Divider(),
            _WardItem('Ward 8', '89%', 'Average', AppTheme.warning),
            Divider(),
            _WardItem('Ward 5', '85%', 'Needs Improvement', AppTheme.error),
          ],
        ),
      ),
    );
  }

  // ---------------- ALERTS ----------------

  Widget _buildRecentAlertsSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.grey300.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Recent Alerts',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: AppTheme.spacingM),
            _AlertItem(
              'High collection volume in Ward 12',
              '2 hours ago',
              Icons.info,
              AppTheme.info,
            ),
            Divider(),
            _AlertItem(
              'Worker attendance low in Ward 5',
              '4 hours ago',
              Icons.warning,
              AppTheme.warning,
            ),
          ],
        ),
      ),
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
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.05), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isPositive ? AppTheme.success.withOpacity(0.1) : AppTheme.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    change,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: isPositive ? AppTheme.success : AppTheme.error,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppTheme.grey900,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppTheme.grey500,
                letterSpacing: 0.5,
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
              Text(ward,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              Text(status, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              percent,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: 60,
              height: 4,
              child: LinearProgressIndicator(
                value: value / 100,
                backgroundColor: color.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation(color),
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
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: AppTheme.spacingM),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: AppTheme.grey800,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.grey100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            time,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppTheme.grey600,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ],
    );
  }
}
