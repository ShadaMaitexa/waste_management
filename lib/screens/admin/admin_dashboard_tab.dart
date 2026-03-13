import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/admin_service.dart';
import '../../theme/app_theme.dart';

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
          body: RefreshIndicator(
            onRefresh: () => adminService.fetchDashboardStats(),
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 180.0,
                  floating: false,
                  pinned: true,
                  backgroundColor: AppTheme.primaryGreen,
                  elevation: 0,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        Container(
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
                            gradient: LinearGradient(
                              colors: [AppTheme.primaryGreen, AppTheme.secondaryGreen],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ),
                        Positioned(
                          right: -30,
                          top: -20,
                          child: Icon(
                            Icons.admin_panel_settings_rounded,
                            size: 180,
                            color: Colors.white.withOpacity(0.08),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 20, bottom: 20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'GreenLoop Control Center',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              ),
                              const Text(
                                'KMC Admin Portal',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout, color: Colors.white),
                      onPressed: () {
                        Provider.of<AuthService>(context, listen: false).logout();
                        Navigator.of(context).pushReplacementNamed('/login');
                      },
                    ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spacingM),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeaderInfo(),
                        const SizedBox(height: AppTheme.spacingM),
                        if (adminService.isLoading)
                          const Center(child: CircularProgressIndicator())
                        else
                          _buildKeyMetrics(stats),
                        const SizedBox(height: AppTheme.spacingM),
                        _buildWardPerformance(stats),
                        const SizedBox(height: AppTheme.spacingM),
                        _buildRecentAlerts(adminService),
                        const SizedBox(height: AppTheme.spacingM),
                        _buildQuickActions(),
                        const SizedBox(height: 80),
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

  Widget _buildHeaderInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL, vertical: AppTheme.spacingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
         boxShadow: [
          BoxShadow(
            color: AppTheme.grey300.withOpacity(0.5),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kozhikode Municipal Corporation',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.grey900,
                  letterSpacing: -0.5,
                ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_rounded, color: AppTheme.success, size: 16),
                const SizedBox(width: 6),
                Text(
                  'System Status: All Operations Normal',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppTheme.success,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyMetrics(Map<String, dynamic> stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Key Performance Metrics',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AppTheme.spacingM),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: AppTheme.spacingM,
          mainAxisSpacing: AppTheme.spacingM,
          childAspectRatio: 1.2,
          children: [
            _buildMetricCard(
              'Total Pickups',
              '${stats['total_pickups'] ?? '2,456'}',
              '+12%',
              Icons.recycling,
              AppTheme.secondaryGreen,
            ),
            _buildMetricCard(
              'Active Routes',
              '${stats['active_routes'] ?? '24'}',
              '+2',
              Icons.route,
              AppTheme.info,
            ),
            _buildMetricCard(
              'Collection Rate',
              '${stats['collection_rate'] ?? '94.5%'}',
              '+2.1%',
              Icons.trending_up,
              AppTheme.success,
            ),
            _buildMetricCard(
              'Complaints',
              '${stats['complaints_count'] ?? '12'}',
              '-8',
              Icons.report_problem,
              AppTheme.warning,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, String change, IconData icon, Color color) {
    bool isPositive = change.startsWith('+');
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned(
              right: -10,
              top: -10,
              child: Icon(
                icon,
                size: 80,
                color: color.withOpacity(0.05),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(icon, color: color, size: 20),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isPositive ? AppTheme.success.withOpacity(0.1) : AppTheme.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          change,
                          style: TextStyle(
                            fontSize: 10,
                            color: isPositive ? AppTheme.success : AppTheme.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.grey900,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.grey600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWardPerformance(Map<String, dynamic> stats) {
    // If stats['ward'] is available, it might have ward_wise_stats etc.
    final hasWardStats = stats['ward'] != null && stats['ward']['ward_wise_stats'] != null;
    
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
          children: [
            Text(
              'Ward-wise Performance',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
            ),
            const SizedBox(height: AppTheme.spacingM),
            if (hasWardStats) ..._buildDynamicWards(stats['ward']['ward_wise_stats'] as List)
            else ...[
              _buildWardItem('Ward 15', '98%', 'Excellent', AppTheme.success),
              const Divider(),
              _buildWardItem('Ward 12', '94%', 'Good', AppTheme.success),
              const Divider(),
              _buildWardItem('Ward 8', '89%', 'Average', AppTheme.warning),
              const Divider(),
              _buildWardItem('Ward 5', '85%', 'Needs Improvement', AppTheme.error),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDynamicWards(List dynamicWards) {
    final widgets = <Widget>[];
    for (int i = 0; i < dynamicWards.length; i++) {
        final wardObj = dynamicWards[i];
        final String wardName = wardObj['ward'] ?? 'Ward ${i+1}';
        final int pickups = wardObj['total_pickups'] ?? 0;
        final int complaints = wardObj['total_complaints'] ?? 0;
        
        // Compute pseudo performance
        double perf = pickups == 0 ? 0 : 100.0 - (complaints / (pickups + complaints)) * 100.0;
        if (perf.isNaN) perf = 90.0;
        String status = 'Excellent';
        Color color = AppTheme.success;
        if (perf < 90 && perf >= 80) { status = 'Good'; }
        else if (perf < 80 && perf >= 60) { status = 'Average'; color = AppTheme.warning; }
        else if (perf < 60) { status = 'Needs Improvement'; color = AppTheme.error; }
        
        widgets.add(_buildWardItem(wardName, '${perf.toStringAsFixed(0)}%', status, color));
        if (i < dynamicWards.length - 1) widgets.add(const Divider());
    }
    return widgets;
  }

  Widget _buildWardItem(String ward, String percentage, String status, Color color) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ward,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: AppTheme.spacingXS),
              Text(
                status,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.grey600,
                    ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              percentage,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
            ),
            const SizedBox(height: 6),
            Container(
              width: 80,
              height: 6,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(3),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: double.parse(percentage.replaceAll('%', '')) / 100,
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentAlerts(AdminService adminService) {
    final alerts = adminService.getSystemAlerts();

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
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'System Alerts',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                ),
                if (alerts.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${alerts.length} NEW',
                      style: const TextStyle(
                        color: AppTheme.error,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingM),
            if (alerts.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text('No active alerts', style: TextStyle(color: AppTheme.grey400)),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: alerts.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final alert = alerts[index];
                  return _buildAlertItem(
                    alert['message'],
                    alert['time'],
                    _getAlertIcon(alert['type']),
                    _getAlertColor(alert['type']),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  IconData _getAlertIcon(String type) {
    switch (type) {
      case 'warning': return Icons.warning_amber_rounded;
      case 'success': return Icons.check_circle_outline_rounded;
      default: return Icons.info_outline_rounded;
    }
  }

  Color _getAlertColor(String type) {
    switch (type) {
      case 'warning': return AppTheme.warning;
      case 'success': return AppTheme.success;
      default: return AppTheme.info;
    }
  }

  Widget _buildAlertItem(String message, String time, IconData icon, Color color) {
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
            message,
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

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
        ),
        const SizedBox(height: AppTheme.spacingM),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppTheme.spacingM,
          crossAxisSpacing: AppTheme.spacingM,
          childAspectRatio: 1.6,
          children: [
            _buildQuickActionCard(
              'Generate Reports',
              Icons.analytics_rounded,
              AppTheme.info,
              () => widget.onNavigate(2),
            ),
            _buildQuickActionCard(
              'Route Planning',
              Icons.map_rounded,
              AppTheme.primaryGreen,
              () {},
            ),
            _buildQuickActionCard(
              'User Control',
              Icons.people_alt_rounded,
              AppTheme.warning,
              () => widget.onNavigate(1),
            ),
            _buildQuickActionCard(
              'System Settings',
              Icons.settings_rounded,
              AppTheme.secondaryGreen,
              () {},
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.12),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppTheme.grey800,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
