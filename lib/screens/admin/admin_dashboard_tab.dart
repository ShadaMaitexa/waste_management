import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
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
          backgroundColor: AppTheme.bgSurface,
          body: RefreshIndicator(
            onRefresh: () => adminService.fetchDashboardStats(),
            edgeOffset: 100,
            child: CustomScrollView(
              slivers: [
                _buildSliverAppBar(context),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildWelcomeSection(constraints),
                            const SizedBox(height: 32),
                            _buildSectionHeader('System Overview', 'Real-time performance metrics'),
                            const SizedBox(height: 16),
                            adminService.isLoading
                                ? _buildLoadingMetrics(constraints)
                                : _buildKeyMetrics(stats, constraints),
                            const SizedBox(height: 32),
                            _buildSectionHeader('Management Console', 'Core operational controls'),
                            const SizedBox(height: 16),
                            _buildManagementHub(constraints),
                            const SizedBox(height: 32),
                            if (constraints.maxWidth < 800)
                              Column(
                                children: [
                                  _buildWardPerformance(stats),
                                  const SizedBox(height: 20),
                                  _buildRecentAlerts(adminService),
                                ],
                              )
                            else
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: _buildWardPerformance(stats)),
                                  const SizedBox(width: 20),
                                  Expanded(child: _buildRecentAlerts(adminService)),
                                ],
                              ),
                            const SizedBox(height: 100),
                          ],
                        );
                      },
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
            color: AppTheme.bgSurface,
          ),
        ),
        titlePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      title: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primaryEmerald.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lens_rounded, color: AppTheme.primaryEmerald, size: 6),
                  const SizedBox(width: 4),
                  Text(
                    'SYSTEM OPERATIONAL',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      color: AppTheme.primaryEmerald,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Command Center',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 24, 
                fontWeight: FontWeight.w900, 
                color: AppTheme.grey900,
                letterSpacing: -1.0,
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

  Widget _buildWelcomeSection(BoxConstraints constraints) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.grey900,
        borderRadius: BorderRadius.circular(32),
        image: const DecorationImage(
          image: NetworkImage('https://images.unsplash.com/photo-1557683316-973673baf926?q=80&w=2029&auto=format&fit=crop'), // Subtle abstract professional background
          fit: BoxFit.cover,
          opacity: 0.15,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryEmerald.withValues(alpha: 0.15),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            bottom: -30,
            child: Icon(Icons.hub_rounded, size: 180, color: AppTheme.primaryEmerald.withValues(alpha: 0.05)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryEmerald.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.primaryEmerald.withValues(alpha: 0.3)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.shield_rounded, color: AppTheme.primaryEmerald, size: 14),
                        SizedBox(width: 6),
                        Text('SYSTEM SECURE', style: TextStyle(color: AppTheme.primaryEmerald, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12)),
                    child: Text(
                      DateFormat('MMM dd, yyyy • HH:mm').format(DateTime.now()).toUpperCase(),
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Global Intelligence\n',
                      style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1.5, height: 1.2),
                    ),
                    TextSpan(
                      text: 'Overview Engine',
                      style: GoogleFonts.plusJakartaSans(color: AppTheme.primaryEmerald, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1.5, height: 1.2),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Monitoring 1,248 active service nodes across the Kozhikode district network in real-time.',
                style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.6), fontSize: 14, fontWeight: FontWeight.w500, height: 1.5),
              ),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildQuickStat('CORE UPTIME', '99.98%'),
                      _buildDivider(),
                      _buildQuickStat('AVG LATENCY', '18ms'),
                      _buildDivider(),
                      _buildQuickStat('DATA NODES', 'Healthy'),
                      _buildDivider(),
                      _buildQuickStat('SYNC STATUS', 'Active'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1, 
      height: 30, 
      color: Colors.white.withValues(alpha: 0.1), 
      margin: const EdgeInsets.symmetric(horizontal: 24)
    );
  }

  Widget _buildQuickStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.plusJakartaSans(color: Colors.white.withValues(alpha: 0.4), fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
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
            Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w900, color: AppTheme.grey900, letterSpacing: -0.8)),
            Text(subtitle, style: GoogleFonts.inter(fontSize: 13, color: AppTheme.grey500, fontWeight: FontWeight.w500)),
          ],
        ),
        TextButton(
          onPressed: () {},
          style: TextButton.styleFrom(
            foregroundColor: AppTheme.primaryEmerald,
            textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 0.5),
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

  Widget _buildLoadingMetrics(BoxConstraints constraints) {
    bool isSmall = constraints.maxWidth < 450;
    return Shimmer.fromColors(
      baseColor: AppTheme.grey100,
      highlightColor: AppTheme.grey50,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isSmall ? 1 : 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          mainAxisExtent: 140, // fixed height for proper content layout
        ),
        itemCount: 4,
        itemBuilder: (context, index) => Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
        ),
      ),
    );
  }

  Widget _buildKeyMetrics(Map<String, dynamic> stats, BoxConstraints constraints) {
    bool isSmall = constraints.maxWidth < 450;
    final metrics = [
      {'label': 'Total Revenue', 'value': '₹${stats['total_revenue'] ?? '5.2L'}', 'growth': '+14%', 'icon': Icons.account_balance_wallet_rounded, 'color': AppTheme.success},
      {'label': 'Active Pickups', 'value': '${stats['total_pickups'] ?? '1,842'}', 'growth': '+8%', 'icon': Icons.token_rounded, 'color': AppTheme.primaryEmerald},
      {'label': 'Deployed Force', 'value': '${stats['active_routes'] ?? '32'}', 'growth': '+3', 'icon': Icons.engineering_rounded, 'color': AppTheme.info},
      {'label': 'Pending Alerts', 'value': '${stats['complaints_count'] ?? '08'}', 'growth': '-12%', 'icon': Icons.emergency_share_rounded, 'color': AppTheme.error},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isSmall ? 1 : 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        mainAxisExtent: 150, // ensures cards have sufficient vertical space
      ),
      itemCount: metrics.length,
      itemBuilder: (context, index) {
        final m = metrics[index];
        return _buildMetricCard(m['label'] as String, m['value'] as String, m['growth'] as String, m['icon'] as IconData, m['color'] as Color);
      },
    );
  }

  Widget _buildMetricCard(String label, String value, String growth, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppTheme.grey200.withValues(alpha: 0.5), width: 1),
        boxShadow: AppTheme.smoothShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(16)),
                child: Icon(icon, color: color, size: 22),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: growth.contains('+') ? AppTheme.success.withValues(alpha: 0.1) : AppTheme.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(growth, style: GoogleFonts.plusJakartaSans(color: growth.contains('+') ? AppTheme.success : AppTheme.error, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 28, fontWeight: FontWeight.w900, color: AppTheme.grey900, letterSpacing: -1)),
              const SizedBox(height: 4),
              Text(label.toUpperCase(), style: GoogleFonts.plusJakartaSans(fontSize: 9, color: AppTheme.grey400, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildManagementHub(BoxConstraints constraints) {
    bool isSmall = constraints.maxWidth < 450;
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isSmall ? 1 : 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        mainAxisExtent: 156, // Fixed height to prevent overflow
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        switch (index) {
          case 0: return _buildHubCard('Incident Center', 'Manage grievances', Icons.report_problem_rounded, AppTheme.error, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminComplaintsScreen())));
          case 1: return _buildHubCard('Service Queue', 'Dispatch operations', Icons.auto_graph_rounded, AppTheme.accentIndigo, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminBookingsScreen())));
          case 2: return _buildHubCard('Field Force', 'User & Worker registry', Icons.supervised_user_circle_rounded, AppTheme.primaryEmerald, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminUserManagementScreen())));
          case 3: default: return _buildHubCard('Scheduling', 'Slot & route engine', Icons.timer_rounded, AppTheme.warning, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManagePickupSlotsScreen())));
        }
      },
    );
  }

  Widget _buildHubCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(32),
        splashColor: color.withValues(alpha: 0.1),
        highlightColor: color.withValues(alpha: 0.05),
        child: Ink(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: AppTheme.grey200.withValues(alpha: 0.5), width: 1),
            boxShadow: AppTheme.smoothShadow,
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
              Text(title, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, fontSize: 16, color: AppTheme.grey900, letterSpacing: -0.5)),
              const SizedBox(height: 4),
              Text(subtitle, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.grey500, fontWeight: FontWeight.w500, height: 1.2)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWardPerformance(Map<String, dynamic> stats) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppTheme.grey200.withValues(alpha: 0.5), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
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
                  Text('Ward Status', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, fontSize: 18, color: AppTheme.grey900, letterSpacing: -0.5)),
                  const SizedBox(height: 2),
                  Text('Real-time collection efficiency', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.grey500, fontWeight: FontWeight.w500)),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppTheme.primaryEmerald.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.map_rounded, color: AppTheme.primaryEmerald, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 32),
          _buildWardItem('Ward North-15', 0.98, AppTheme.success),
          const SizedBox(height: 20),
          _buildWardItem('Ward East-08', 0.82, AppTheme.warning),
          const SizedBox(height: 20),
          _buildWardItem('Industrial-12', 0.94, AppTheme.success),
          const SizedBox(height: 20),
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
             Text(ward, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 14, color: AppTheme.grey800)),
             Text('${(progress * 100).toInt()}%', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, fontSize: 14, color: color)),
           ],
        ),
        const SizedBox(height: 10),
        Stack(
          children: [
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: AppTheme.grey100,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 1000),
              curve: Curves.fastOutSlowIn,
              height: 8,
              width: MediaQuery.of(context).size.width * progress, // Abstract representation for mock
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
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
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppTheme.grey200.withValues(alpha: 0.5), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
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
                  Text('System Logs', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, fontSize: 18, color: AppTheme.grey900, letterSpacing: -0.5)),
                  const SizedBox(height: 2),
                  Text('Security & performance events', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.grey500, fontWeight: FontWeight.w500)),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppTheme.grey100, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.terminal_rounded, color: AppTheme.grey600, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 32),
          ...alerts.take(4).map((a) => _buildAlertRow(a)),
        ],
      ),
    );
  }

  Widget _buildAlertRow(Map<String, dynamic> alert) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: alert['type'] == 'warning' ? AppTheme.warning.withValues(alpha: 0.1) : AppTheme.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              alert['type'] == 'warning' ? Icons.warning_amber_rounded : Icons.info_outline_rounded, 
              size: 18, 
              color: alert['type'] == 'warning' ? AppTheme.warning : AppTheme.info
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(alert['message'], style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.grey800, height: 1.4)),
                const SizedBox(height: 4),
                Text(alert['time'].toUpperCase(), style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w800, color: AppTheme.grey400, letterSpacing: 1)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
