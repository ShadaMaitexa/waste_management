import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/referral_service.dart';
import '../../theme/app_theme.dart';

class ReferralScreen extends StatelessWidget {
  const ReferralScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgSurface,
      appBar: AppBar(
        title: Text(
          'Ambassador Portal',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w900, 
            fontSize: 18,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppTheme.bgDark,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.slateGradient,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      extendBodyBehindAppBar: false,
      body: Consumer<ReferralService>(
        builder: (context, referralService, child) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeroSection(context),
                Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingL),
                  child: Column(
                    children: [
                      _buildReferralCodeCard(context, referralService),
                      const SizedBox(height: AppTheme.spacingL),
                      _buildStatsSection(referralService),
                      const SizedBox(height: AppTheme.spacingXL),
                      _buildHowItWorks(),
                      const SizedBox(height: AppTheme.spacingXL),
                      _buildHistorySection(referralService),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: _buildShareButton(context),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: AppTheme.smoothShadow,
              border: Border.all(color: AppTheme.primaryEmerald.withValues(alpha: 0.1)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.verified_rounded, color: AppTheme.primaryEmerald, size: 16),
                const SizedBox(width: 10),
                Text(
                  'CERTIFIED ADVOCATE',
                  style: GoogleFonts.plusJakartaSans(
                    color: AppTheme.primaryEmerald,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Propagate\nSustainable\nImpact.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 52,
              fontWeight: FontWeight.w900,
              color: AppTheme.grey900,
              letterSpacing: -3,
              height: 0.95,
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Text(
              'Expand the network and receive dividends for every verified deployment.',
              style: GoogleFonts.plusJakartaSans(
                color: AppTheme.grey500,
                fontSize: 16,
                height: 1.6,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReferralCodeCard(BuildContext context, ReferralService service) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.bgDark,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: AppTheme.bgDark.withValues(alpha: 0.4),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: Stack(
          children: [
            Positioned(
              right: -40,
              top: -40,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  Text(
                    'PERSONAL ACCESS TOKEN',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: Colors.white.withValues(alpha: 0.5),
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          service.referralCode,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 10,
                          ),
                        ),
                        const SizedBox(width: 24),
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: service.referralCode));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Token added to clipboard',
                                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                                ),
                                backgroundColor: AppTheme.bgDark,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              gradient: AppTheme.emeraldGradient,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryEmerald.withValues(alpha: 0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                )
                              ],
                            ),
                            child: const Icon(Icons.copy_rounded, color: Colors.white, size: 20),
                          ),
                        ),
                      ],
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

  Widget _buildStatsSection(ReferralService service) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Acquisitions',
            service.referralCount.toString(),
            Icons.group_add_rounded,
            AppTheme.accentIndigo,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Revenue',
            '₹${service.totalEarned.toStringAsFixed(0)}',
            Icons.account_balance_wallet_rounded,
            const Color(0xFFF59E0B),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: AppTheme.smoothShadow,
        border: Border.all(color: AppTheme.grey200.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 28),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              color: AppTheme.grey900,
              letterSpacing: -2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: AppTheme.grey400,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHowItWorks() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: AppTheme.smoothShadow,
        border: Border.all(color: AppTheme.grey200.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'OPERATIONAL PROTOCOL',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: AppTheme.grey400,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 40),
          _buildHowItWorksStep(
            '01',
            'Distribute Token',
            'Transmit your exclusive identifier to your peer network.',
            Icons.share_rounded,
            AppTheme.accentIndigo,
          ),
          _buildHowItWorksStep(
            '02',
            'Network Conversion',
            'Peers register and schedule their initial collection.',
            Icons.verified_user_rounded,
            const Color(0xFF8B5CF6),
          ),
          _buildHowItWorksStep(
            '03',
            'Mutual Dividend',
            'You receive ₹50. They receive an onboarding discount.',
            Icons.redeem_rounded,
            AppTheme.primaryEmerald,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildHowItWorksStep(String step, String title, String desc, IconData icon, Color color, {bool isLast = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 48,
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      color.withValues(alpha: 0.3),
                      color.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
          ],
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      step,
                      style: GoogleFonts.plusJakartaSans(
                        color: color,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      title.toUpperCase(),
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        color: AppTheme.grey900,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  desc,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppTheme.grey500,
                    height: 1.6,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHistorySection(ReferralService service) {
    final history = service.getReferralHistory();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ACQUISITION LOG',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: AppTheme.grey400,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(40),
            boxShadow: AppTheme.smoothShadow,
            border: Border.all(color: AppTheme.grey200.withValues(alpha: 0.5)),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: 8),
            physics: const NeverScrollableScrollPhysics(),
            itemCount: history.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: AppTheme.grey100,
              indent: 80,
              endIndent: 24,
            ),
            itemBuilder: (context, index) {
              final item = history[index];
              final bool isPaid = item.amount > 0;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryEmerald.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          item.name[0],
                          style: GoogleFonts.plusJakartaSans(
                            color: AppTheme.primaryEmerald,
                            fontWeight: FontWeight.w900,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              color: AppTheme.grey900,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.date,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppTheme.grey400,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          isPaid ? '+₹${item.amount.toStringAsFixed(0)}' : 'Pending',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                            color: isPaid ? AppTheme.success : AppTheme.grey400,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: (isPaid ? AppTheme.success : AppTheme.grey400).withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: (isPaid ? AppTheme.success : AppTheme.grey400).withValues(alpha: 0.1)),
                          ),
                          child: Text(
                            item.status.toUpperCase(),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: isPaid ? AppTheme.success : AppTheme.grey500,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildShareButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 48),
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: SizedBox(
        height: 64,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            Provider.of<ReferralService>(context, listen: false).shareReferral();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.bgDark,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            elevation: 12,
            shadowColor: AppTheme.bgDark.withValues(alpha: 0.4),
            padding: EdgeInsets.zero,
          ),
          child: Ink(
            decoration: BoxDecoration(
              gradient: AppTheme.slateGradient,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Container(
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'BROADCAST TOKEN',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.bolt_rounded, size: 20, color: AppTheme.primaryEmerald),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
