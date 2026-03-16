import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
      expandedHeight: 140,
      collapsedHeight: 80,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: AppTheme.grey100, width: 1)),
          ),
        ),
        titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'COMMAND CENTER',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
                color: AppTheme.primaryEmerald,
              ),
            ),
            const Text(
              'Government Panel',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.grey900),
            ),
          ],
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(color: AppTheme.grey50, shape: BoxShape.circle),
          child: IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: AppTheme.grey700, size: 20),
            onPressed: () {},
          ),
        ),
        IconButton(
          icon: const Icon(Icons.logout_rounded, color: AppTheme.error, size: 20),
          onPressed: () {
            Provider.of<AuthService>(context, listen: false).logout();
            Navigator.of(context).pushReplacementNamed('/login');
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: AppTheme.emeraldGradient,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryEmerald.withValues(alpha: 0.3),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -30,
            child: Icon(Icons.shield_rounded, size: 160, color: Colors.white.withValues(alpha: 0.1)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                    child: const Text('SUPER ADMIN', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1)),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'System Secure',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 10, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Operational Intelligence',
                style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -1),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildQuickStat('Uptime', '99.9%'),
                  const SizedBox(width: 24),
                  _buildQuickStat('Latency', '24ms'),
                  const SizedBox(width: 24),
                  _buildQuickStat('Node Status', 'Healthy'),
                ],
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
        Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 10, fontWeight: FontWeight.bold)),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
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
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.grey900)),
            Text(subtitle, style: const TextStyle(fontSize: 13, color: AppTheme.grey500)),
          ],
        ),
        TextButton(
          onPressed: () {},
          child: const Text('View Full Analytics', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryEmerald)),
        ),
      ],
    );
  }

  Widget _buildLoadingMetrics() {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 4,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: List.generate(4, (index) => Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      )),
    );
  }

  Widget _buildKeyMetrics(Map<String, dynamic> stats) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 2.2,
      children: [
        _buildMetricCard('Total Revenue', '₹${stats['total_revenue'] ?? '4.8L'}', '+18%', Icons.payments_rounded, AppTheme.success),
        _buildMetricCard('Total Pickups', '${stats['total_pickups'] ?? '2,456'}', '+12%', Icons.recycling_rounded, AppTheme.primaryEmerald),
        _buildMetricCard('Active Routes', '${stats['active_routes'] ?? '24'}', '+2', Icons.route_rounded, AppTheme.info),
        _buildMetricCard('Open Issues', '${stats['complaints_count'] ?? '12'}', '-5%', Icons.report_problem_rounded, AppTheme.error),
      ],
    );
  }

  Widget _buildMetricCard(String label, String value, String growth, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.grey100, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(14)),
                child: Icon(icon, color: color, size: 18),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: growth.contains('+') ? AppTheme.success.withValues(alpha: 0.1) : AppTheme.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(growth, style: TextStyle(color: growth.contains('+') ? AppTheme.success : AppTheme.error, fontSize: 10, fontWeight: FontWeight.w900)),
              ),
            ],
          ),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppTheme.grey900, letterSpacing: -0.5)),
          Text(label.toUpperCase(), style: const TextStyle(fontSize: 9, color: AppTheme.grey400, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
        ],
      ),
    );
  }

  Widget _buildManagementHub() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.6,
      children: [
        _buildHubCard('Complaints', 'Resolve citizen issues', Icons.report_problem_rounded, AppTheme.error, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminComplaintsScreen()))),
        _buildHubCard('Bookings', 'Dispatch collections', Icons.local_shipping_rounded, AppTheme.accentIndigo, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminBookingsScreen()))),
        _buildHubCard('Workers', 'Field force management', Icons.people_alt_rounded, AppTheme.primaryEmerald, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminUserManagementScreen()))),
        _buildHubCard('Schedules', 'Optimization engine', Icons.calendar_month_rounded, AppTheme.warning, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManagePickupSlotsScreen()))),
      ],
    );
  }

  Widget _buildHubCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.grey100, width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.08), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 24),
            ),
            const Spacer(),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppTheme.grey900)),
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(fontSize: 10, color: AppTheme.grey400, fontWeight: FontWeight.w500, height: 1.1)),
          ],
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
