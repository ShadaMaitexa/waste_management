import 'dart:async';
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
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminService>().fetchDashboardStats();
    });
    
    // Auto-refresh every 30 seconds for "live" feel
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        context.read<AdminService>().fetchDashboardStats();
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
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
                            if (adminService.getSystemAlerts().isNotEmpty)
                              _buildRecentAlerts(adminService),
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
      expandedHeight: 180,
      collapsedHeight: 80,
      pinned: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          color: AppTheme.bgSurface,
        ),
        titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primaryEmerald.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.primaryEmerald.withValues(alpha: 0.1), width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 5,
                    height: 5,
                    decoration: const BoxDecoration(color: AppTheme.primaryEmerald, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'SYSTEM OPERATIONAL',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 7, // Reduced from 8
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
              'Dashboard',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 24, // Reduced from 28
                fontWeight: FontWeight.w900, 
                color: AppTheme.grey900,
                letterSpacing: -1.2,
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.grey900),
        onPressed: () => Navigator.pushReplacementNamed(context, '/splash'),
      ),
      actions: [
        Container(
          height: 44,
          width: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.grey100),
            boxShadow: AppTheme.cardShadow,
          ),
          child: IconButton(
            icon: const Icon(Icons.notifications_active_rounded, color: AppTheme.grey900, size: 18),
            onPressed: () {},
            padding: EdgeInsets.zero,
          ),
        ),
        const SizedBox(width: 12),
        Container(
          height: 44,
          width: 44,
          margin: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: AppTheme.error.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(14),
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
      padding: const EdgeInsets.all(24), // Reduced from 32
      decoration: BoxDecoration(
        color: AppTheme.bgDark,
        borderRadius: BorderRadius.circular(28), // Reduced from 40
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.bgDark, Color(0xFF1E293B)],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.bgDark.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(Icons.hub_rounded, size: 160, color: Colors.white.withValues(alpha: 0.03)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryEmerald.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.primaryEmerald.withValues(alpha: 0.2), width: 1.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.shield_rounded, color: AppTheme.primaryEmerald, size: 12),
                        const SizedBox(width: 10),
                        Text(
                          'SYSTEM SECURE', 
                          style: GoogleFonts.plusJakartaSans(
                            color: AppTheme.primaryEmerald, 
                            fontSize: 10, 
                            fontWeight: FontWeight.w900, 
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    DateFormat('MMM dd, yyyy').format(DateTime.now()).toUpperCase(),
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white.withValues(alpha: 0.4), 
                      fontSize: 10, 
                      fontWeight: FontWeight.w900, 
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24), // Reduced from 36
              Text(
                'Waste Management',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white, 
                  fontSize: 28, 
                  fontWeight: FontWeight.w900, 
                  letterSpacing: -1.5, 
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'System dashboard for managing collections and grievances.',
                style: GoogleFonts.inter(
                  color: Colors.white.withValues(alpha: 0.5), 
                  fontSize: 13, 
                  fontWeight: FontWeight.w500, 
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28), // Reduced from 40

            ],
          ),
        ],
      ),
    );
  }



  Widget _buildSectionHeader(String title, String subtitle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.grey900, letterSpacing: -0.6)),
            Text(subtitle, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.grey500, fontWeight: FontWeight.w500)),
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
      {
        'label': 'Revenue', 
        'value': '₹${stats['total_revenue'] ?? '0'}', 
        'growth': stats['revenue_growth'] ?? '+0%', 
        'icon': Icons.account_balance_wallet_rounded, 
        'color': AppTheme.success
      },
      {
        'label': 'Pickups', 
        'value': '${stats['total_pickups'] ?? '0'}', 
        'growth': stats['pickup_growth'] ?? '+0%', 
        'icon': Icons.token_rounded, 
        'color': AppTheme.primaryEmerald
      },
      {
        'label': 'Routes', 
        'value': '${stats['active_routes'] ?? '0'}', 
        'growth': stats['route_growth'] ?? 'Active', 
        'icon': Icons.engineering_rounded, 
        'color': AppTheme.info
      },
      {
        'label': 'Complaints', 
        'value': '${stats['complaints_count'] ?? '0'}', 
        'growth': stats['complaints_growth'] ?? 'Pending', 
        'icon': Icons.emergency_share_rounded, 
        'color': AppTheme.error
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isSmall ? 1 : 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        mainAxisExtent: 160,
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
      padding: const EdgeInsets.all(20), // Reduced from 24
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24), // Reduced from 32
        border: Border.all(color: AppTheme.grey100, width: 1),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8), // Reduced from 10
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1), 
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), // Reduced
                decoration: BoxDecoration(
                  color: growth.contains('+') ? AppTheme.success.withValues(alpha: 0.1) : AppTheme.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  growth, 
                  style: GoogleFonts.plusJakartaSans(
                    color: growth.contains('+') ? AppTheme.success : AppTheme.error, 
                    fontSize: 9, // Reduced from 10
                    fontWeight: FontWeight.w900, 
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value, 
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24, // Reduced from 28
              fontWeight: FontWeight.w900, 
              color: AppTheme.grey900, 
              letterSpacing: -1.0,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label.toUpperCase(), 
            style: GoogleFonts.plusJakartaSans(
              fontSize: 8, // Reduced from 9
              color: AppTheme.grey400, 
              fontWeight: FontWeight.w900, 
              letterSpacing: 0.8,
            ),
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
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        mainAxisExtent: 165,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        switch (index) {
          case 0: return _buildHubCard('Complaints', 'Manage grievances', Icons.report_problem_rounded, AppTheme.error, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminComplaintsScreen())));
          case 1: return _buildHubCard('Bookings', 'Collection list', Icons.auto_graph_rounded, AppTheme.accentIndigo, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminBookingsScreen())));
          case 2: return _buildHubCard('Workers', 'Worker management', Icons.supervised_user_circle_rounded, AppTheme.primaryEmerald, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminUserManagementScreen())));
          case 3: return _buildHubCard('Slots', 'Manage timings', Icons.timer_rounded, AppTheme.warning, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManagePickupSlotsScreen())));
          case 4: return _buildHubCard('Live Map', 'Real-time tracking', Icons.map_rounded, AppTheme.info, () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Live Map integration in progress...'))));
          case 5: default: return _buildHubCard('Ward Stats', 'Performance by ward', Icons.area_chart_rounded, AppTheme.accentPurple, () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ward Monitoring integration in progress...'))));
        }
      },
    );
  }

  Widget _buildHubCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24), // Reduced from 32
        border: Border.all(color: AppTheme.grey100, width: 1),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20), // Reduced from 24
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10), // Reduced from 12
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1), 
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const Spacer(),
                Text(
                  title, 
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w900, 
                    fontSize: 15, // Reduced from 16
                    color: AppTheme.grey900, 
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle, 
                  style: GoogleFonts.inter(
                    fontSize: 11, // Reduced from 12
                    color: AppTheme.grey500, 
                    fontWeight: FontWeight.w500, 
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }



  Widget _buildRecentAlerts(AdminService adminService) {
    final alerts = adminService.getSystemAlerts();
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(36),
        border: Border.all(color: AppTheme.grey100, width: 1),
        boxShadow: AppTheme.cardShadow,
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
                  Text('Security events', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.grey500, fontWeight: FontWeight.w500)),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppTheme.grey50, borderRadius: BorderRadius.circular(12)),
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
              color: alert['type'] == 'warning' ? AppTheme.warning.withValues(alpha: 0.08) : AppTheme.info.withValues(alpha: 0.08),
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
                Text(
                  alert['message'], 
                  style: GoogleFonts.inter(
                    fontSize: 13, 
                    fontWeight: FontWeight.w600, 
                    color: AppTheme.grey900, 
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  alert['time'].toUpperCase(), 
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9, 
                    fontWeight: FontWeight.w900, 
                    color: AppTheme.grey400, 
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
