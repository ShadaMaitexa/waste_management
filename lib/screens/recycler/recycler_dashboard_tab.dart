import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class RecyclerDashboardTab extends StatelessWidget {
  final Function(int) onNavigate;

  const RecyclerDashboardTab({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgSurface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            backgroundColor: AppTheme.bgDark,
            elevation: 0,
            scrolledUnderElevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: AppTheme.slateGradient,
                    ),
                  ),
                  Positioned(
                    right: -30,
                    top: -20,
                    child: Icon(
                      Icons.recycling_rounded,
                      size: 240,
                      color: Colors.white.withValues(alpha: 0.03),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20), // Reduced
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), // Reduced
                          decoration: BoxDecoration(
                            color: AppTheme.primaryEmerald.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6), // Reduced
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.verified_user_rounded, color: AppTheme.primaryEmerald, size: 9), // Reduced
                              const SizedBox(width: 4),
                              Text(
                                'LICENSED OPERATOR',
                                style: GoogleFonts.plusJakartaSans(
                                  color: AppTheme.primaryEmerald,
                                  fontSize: 7, // Reduced from 8
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.2, // Reduced
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8), // Reduced
                        Text(
                          'Sustainability Hub',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 14, // Reduced from 16
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'Recycler Portal',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 26, // Reduced from 32
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1.0, // Reduced
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 20),
                  onPressed: () {},
                ),
              ),
              Container(
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 20),
                  onPressed: () {},
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24), // Reduced
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   _buildHeaderInfo(context),
                  const SizedBox(height: 24), // Reduced from 32
                  _buildMonthlySummary(context),
                  const SizedBox(height: 24),
                  _buildRecentTransactions(context),
                  const SizedBox(height: 24),
                  _buildQuickActions(context),
                  const SizedBox(height: 80), // Adjusted
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderInfo(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20), // Reduced from 24
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24), // Reduced from 32
        boxShadow: AppTheme.smoothShadow,
        border: Border.all(color: AppTheme.grey200.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'EcoRecycle Solutions',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w900,
              color: AppTheme.grey900,
              fontSize: 18, // Reduced from 20
              letterSpacing: -0.4, // Reduced
            ),
          ),
          const SizedBox(height: 10), // Reduced from 12
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primaryEmerald.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.verified_rounded, color: AppTheme.primaryEmerald, size: 14),
                const SizedBox(width: 6),
                Text(
                  'Certified Partner • EPR Compliant',
                  style: GoogleFonts.inter(
                    color: AppTheme.primaryEmerald,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlySummary(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MONTHLY PERFORMANCE',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w900,
            fontSize: 11,
            color: AppTheme.grey400,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _summaryCard(
                context,
                'Processed',
                '24.2 Tons',
                Icons.analytics_rounded,
                AppTheme.info,
              ),
            ),
            const SizedBox(width: 16), // Reduced from 20
            Expanded(
              child: _summaryCard(
                context,
                'Collected',
                '₹18.5k',
                Icons.wallet_rounded,
                AppTheme.primaryEmerald,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _summaryCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20), // Reduced from 24
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24), // Reduced from 32
        boxShadow: AppTheme.smoothShadow,
        border: Border.all(color: AppTheme.grey200.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10), // Reduced from 12
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12), // Reduced from 16
            ),
            child: Icon(icon, color: color, size: 20), // Reduced from 24
          ),
          const SizedBox(height: 16), // Reduced from 24
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w900,
              color: AppTheme.grey900,
              fontSize: 18, // Reduced from 22
              letterSpacing: -0.8, // Reduced
            ),
          ),
          const SizedBox(height: 1),
          Text(
            title.toUpperCase(),
            style: GoogleFonts.inter(
              color: AppTheme.grey400,
              fontWeight: FontWeight.w800,
              fontSize: 8, // Reduced from 9
              letterSpacing: 0.8, // Reduced from 1
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'NETWORK LOGS',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w900,
                fontSize: 11,
                color: AppTheme.grey400,
                letterSpacing: 1.5,
              ),
            ),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primaryEmerald,
                textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 11),
              ),
              child: const Text('VIEW ALL'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24), // Reduced from 32
            boxShadow: AppTheme.smoothShadow,
            border: Border.all(color: AppTheme.grey200.withValues(alpha: 0.5)),
          ),
          child: Column(
            children: [
              _transactionTile(
                context,
                'Material IN - Plastic',
                '250 kg • Ward 15',
                'Today, 10:30 AM',
                isIncoming: true,
              ),
              const Divider(height: 1, indent: 64),
              _transactionTile(
                context,
                'Processed - Paper',
                '500 kg • Batch #892',
                'Yesterday',
                isIncoming: false,
              ),
              const Divider(height: 1, indent: 64),
               _transactionTile(
                context,
                'Material IN - E-Waste',
                '120 kg • Ward 8',
                'Oct 24',
                isIncoming: true,
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ],
    );
  }

  Widget _transactionTile(BuildContext context, String title, String subtitle, String time, {required bool isIncoming}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4), // Reduced
      leading: Container(
        padding: const EdgeInsets.all(8), // Reduced from 10
        decoration: BoxDecoration(
          color: isIncoming ? AppTheme.info.withValues(alpha: 0.08) : AppTheme.primaryEmerald.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10), // Reduced from 12
        ),
        child: Icon(
          isIncoming ? Icons.south_west_rounded : Icons.north_east_rounded,
          color: isIncoming ? AppTheme.info : AppTheme.primaryEmerald,
          size: 16, // Reduced from 18
        ),
      ),
      title: Text(title, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 13, color: AppTheme.grey800)), // Reduced from 14
      subtitle: Text(subtitle, style: GoogleFonts.inter(fontSize: 11, color: AppTheme.grey400, fontWeight: FontWeight.w500)), // Reduced from 12
      trailing: Text(time.toUpperCase(), style: GoogleFonts.plusJakartaSans(fontSize: 9, color: AppTheme.grey400, fontWeight: FontWeight.w900, letterSpacing: 0.5)), // Reduced from 10
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'QUICK START',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w900,
            fontSize: 11,
            color: AppTheme.grey400,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(child: _actionCard(context, 'Add Material', Icons.add_rounded, AppTheme.info, () => onNavigate(1))),
            const SizedBox(width: 16), // Reduced from 20
            Expanded(child: _actionCard(context, 'Get Certificate', Icons.workspace_premium_rounded, AppTheme.primaryEmerald, () => onNavigate(2))),
          ],
        ),
      ],
    );
  }

  Widget _actionCard(BuildContext context, String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20), // Reduced from 24
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24), // Reduced from 32
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20), // Reduced from 24
          border: Border.all(color: AppTheme.grey200.withValues(alpha: 0.5)),
          boxShadow: AppTheme.smoothShadow,
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10), // Reduced from 12
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24), // Reduced from 28
            ),
            const SizedBox(height: 12), // Reduced from 16
            Text(
              label.toUpperCase(),
              style: GoogleFonts.plusJakartaSans(
                color: AppTheme.grey800,
                fontWeight: FontWeight.w900,
                fontSize: 9, // Reduced from 10
                letterSpacing: 0.8, // Reduced from 1
              ),
            ),
          ],
        ),
      ),
    );
  }
}
