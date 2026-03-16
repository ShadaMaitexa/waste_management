import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../../services/auth_service.dart';
import '../../services/admin_service.dart';
import '../../theme/app_theme.dart';
import 'admin_complaints_screen.dart';
import 'admin_bookings_screen.dart';
import 'admin_user_management_screen.dart';
import 'manage_pickup_slots_screen.dart';

class AdminDashboardTab extends StatefulWidget {
  final Function(int) onNavigate;

  const AdminDashboardTab({super.key, required this.onNavigate});

  @override
  State<AdminDashboardTab> createState() => _AdminDashboardTabState();
}

class _AdminDashboardTabState extends State<AdminDashboardTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminService>().fetchDashboardStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminService>(
      builder: (context, adminService, child) {
        final stats = adminService.systemStats;

        return Scaffold(
          backgroundColor: AppTheme.grey50,
          body: RefreshIndicator(
            onRefresh: () => adminService.fetchDashboardStats(),
            edgeOffset: 100,
            child: CustomScrollView(
              slivers: [
                _buildSliverAppBar(context),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildWelcomeSection(),
                        const SizedBox(height: 32),
                        _buildSectionHeader('System Overview', 'Real-time performance metrics'),
                        const SizedBox(height: 16),
                        adminService.isLoading
                            ? _buildLoadingMetrics()
                            : _buildKeyMetrics(stats),
                        const SizedBox(height: 32),
                        _buildSectionHeader('Management Console', 'Core operational controls'),
                        const SizedBox(height: 16),
                        _buildManagementHub(),
                        const SizedBox(height: 32),
                        Row(
                          children: [
                            Expanded(child: _buildWardPerformance(stats)),
                            const SizedBox(width: 20),
                            Expanded(child: _buildRecentAlerts(adminService)),
                          ],
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 160,
      collapsedHeight: 80,
      pinned: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: AppTheme.grey100, width: 1.5)),
          ),
        ),
        titlePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primaryEmerald.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'SYSTEM OPERATIONAL',
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                  color: AppTheme.primaryEmerald,
                ),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Command Center',
              style: TextStyle(
                fontSize: 20, 
                fontWeight: FontWeight.w900, 
                color: AppTheme.grey900,
                letterSpacing: -0.8,
              ),
            ),
          ],
        ),
      ),
      actions: [
        Container(
          height: 40,
          width: 40,
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            color: AppTheme.grey50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.grey200),
          ),
          child: IconButton(
            icon: const Icon(Icons.notifications_active_rounded, color: AppTheme.primaryEmerald, size: 18),
            onPressed: () {},
            padding: EdgeInsets.zero,
          ),
        ),
        Container(
          height: 40,
          width: 40,
          margin: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: AppTheme.error.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.error.withValues(alpha: 0.1)),
          ),
          child: IconButton(
            icon: const Icon(Icons.power_settings_new_rounded, color: AppTheme.error, size: 18),
            onPressed: () {
              Provider.of<AuthService>(context, listen: false).logout();
              Navigator.of(context).pushReplacementNamed('/login');
            },
            padding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: AppTheme.slateGradient,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppTheme.grey900.withValues(alpha: 0.2),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(Icons.show_chart_rounded, size: 140, color: Colors.white.withValues(alpha: 0.05)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: AppTheme.primaryEmerald, borderRadius: BorderRadius.circular(8)),
                    child: const Text('SYSTEM SECURE', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                  ),
                  const Spacer(),
                  Text(
                    DateFormat('EEEE, MMM d').format(DateTime.now()).toUpperCase(),
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Intelligence Overview',
                style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -1),
              ),
              Text(
                'Monitoring 1,248 active service nodes across the district.',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildQuickStat('CORE UPTIME', '99.98%'),
                    Container(width: 1, height: 24, color: Colors.white.withValues(alpha: 0.1)),
                    _buildQuickStat('AVG LATENCY', '18ms'),
                    Container(width: 1, height: 24, color: Colors.white.withValues(alpha: 0.1)),
                    _buildQuickStat('DATA NODES', 'Healthy'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
      ],
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.grey900, letterSpacing: -0.5)),
            Text(subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.grey400, fontWeight: FontWeight.w500)),
          ],
        ),
        TextButton(
          onPressed: () {},
          style: TextButton.styleFrom(
            foregroundColor: AppTheme.primaryEmerald,
            textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 0.5),
          ),
          child: const Row(
            children: [
              Text('ANALYTICS'),
              SizedBox(width: 4),
              Icon(Icons.arrow_forward_ios_rounded, size: 10),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingMetrics() {
    return Shimmer.fromColors(
      baseColor: AppTheme.grey100,
      highlightColor: AppTheme.grey50,
      child: GridView.count(
        shrinkWrap: true,
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 2.2,
        children: List.generate(4, (index) => Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
        )),
      ),
    );
  }

  Widget _buildKeyMetrics(Map<String, dynamic> stats) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 20,
      mainAxisSpacing: 20,
      childAspectRatio: 2.0,
      children: [
        _buildMetricCard('Total Revenue', '₹${stats['total_revenue'] ?? '5.2L'}', '+14%', Icons.account_balance_wallet_rounded, AppTheme.success),
        _buildMetricCard('Active Pickups', '${stats['total_pickups'] ?? '1,842'}', '+8%', Icons.token_rounded, AppTheme.primaryEmerald),
        _buildMetricCard('Deployed Force', '${stats['active_routes'] ?? '32'}', '+3', Icons.engineering_rounded, AppTheme.info),
        _buildMetricCard('Pending Alerts', '${stats['complaints_count'] ?? '08'}', '-12%', Icons.emergency_share_rounded, AppTheme.error),
      ],
    );
  }

  Widget _buildMetricCard(String label, String value, String growth, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppTheme.grey100, width: 1.5),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: color, size: 20),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: growth.contains('+') ? AppTheme.success.withValues(alpha: 0.1) : AppTheme.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(growth, style: TextStyle(color: growth.contains('+') ? AppTheme.success : AppTheme.error, fontSize: 9, fontWeight: FontWeight.w900)),
              ),
            ],
          ),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.grey900, letterSpacing: -1)),
          Text(label.toUpperCase(), style: const TextStyle(fontSize: 9, color: AppTheme.grey400, fontWeight: FontWeight.w900, letterSpacing: 0.8)),
        ],
      ),
    );
  }

  Widget _buildManagementHub() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 20,
      mainAxisSpacing: 20,
      childAspectRatio: 1.4,
      children: [
        _buildHubCard('Incident Center', 'Manage grievances', Icons.report_problem_rounded, AppTheme.error, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminComplaintsScreen()))),
        _buildHubCard('Service Queue', 'Dispatch operations', Icons.auto_graph_rounded, AppTheme.accentIndigo, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminBookingsScreen()))),
        _buildHubCard('Field Force', 'User & Worker registry', Icons.supervised_user_circle_rounded, AppTheme.primaryEmerald, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminUserManagementScreen()))),
        _buildHubCard('Scheduling', 'Slot & route engine', Icons.timer_rounded, AppTheme.warning, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManagePickupSlotsScreen()))),
      ],
    );
  }

  Widget _buildHubCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Ink(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppTheme.grey100, width: 1.5),
            boxShadow: AppTheme.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(16)),
                child: Icon(icon, color: color, size: 26),
              ),
              const Spacer(),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppTheme.grey900, letterSpacing: -0.5)),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(fontSize: 11, color: AppTheme.grey400, fontWeight: FontWeight.w500, height: 1.2)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWardPerformance(Map<String, dynamic> stats) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppTheme.grey100, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Ward-level Status', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const Text('Real-time collection efficiency', style: TextStyle(fontSize: 11, color: AppTheme.grey400)),
          const SizedBox(height: 24),
          _buildWardItem('Ward North-15', 0.98, AppTheme.success),
          const SizedBox(height: 16),
          _buildWardItem('Ward East-08', 0.82, AppTheme.warning),
          const SizedBox(height: 16),
          _buildWardItem('Industrial-12', 0.94, AppTheme.success),
          const SizedBox(height: 16),
          _buildWardItem('Central-05', 0.45, AppTheme.error),
        ],
      ),
    );
  }

  Widget _buildWardItem(String ward, double progress, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(ward, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppTheme.grey700)),
            Text('${(progress * 100).toInt()}%', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: color)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: color.withValues(alpha: 0.08),
            color: color,
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentAlerts(AdminService adminService) {
    final alerts = adminService.getSystemAlerts();
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppTheme.grey100, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('System Logs', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  const Text('Security & performance events', style: TextStyle(fontSize: 11, color: AppTheme.grey400)),
                ],
              ),
              Icon(Icons.terminal_rounded, color: AppTheme.grey300, size: 20),
            ],
          ),
          const SizedBox(height: 20),
          ...alerts.take(4).map((a) => _buildAlertRow(a)),
        ],
      ),
    );
  }

  Widget _buildAlertRow(Map<String, dynamic> alert) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.grey50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              alert['type'] == 'warning' ? Icons.warning_amber_rounded : Icons.info_outline_rounded, 
              size: 16, 
              color: alert['type'] == 'warning' ? AppTheme.warning : AppTheme.info
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(alert['message'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.grey800, height: 1.3)),
                const SizedBox(height: 2),
                Text(alert['time'].toUpperCase(), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppTheme.grey400, letterSpacing: 0.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
