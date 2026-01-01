import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class RecyclerDashboardTab extends StatelessWidget {
  final Function(int) onNavigate;

  const RecyclerDashboardTab({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120.0,
            floating: true,
            pinned: true,
            backgroundColor: AppTheme.primaryGreen,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Recycler Portal'),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryGreen, AppTheme.secondaryGreen],
                    begin: Alignment.topLeft,
                    end: Alignment.centerRight,
                  ),
                ),
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
                  // Logout logic via provider if needed
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
                   _buildHeaderInfo(context),
                  const SizedBox(height: AppTheme.spacingM),
                  // Monthly Summary
                  _buildMonthlySummary(context),
                  const SizedBox(height: AppTheme.spacingM),
                  // Recent Transactions
                  _buildRecentTransactions(context),
                  const SizedBox(height: AppTheme.spacingM),
                  // Quick Actions
                  _buildQuickActions(context),
                  const SizedBox(height: 80),
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
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
         boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'EcoRecycle Solutions',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.grey900,
                ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.verified, color: AppTheme.primaryGreen, size: 16),
              const SizedBox(width: 8),
              Text(
                'Certified Partner • EPR Compliant',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.primaryGreen,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
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
          'Monthly Summary (Oct 2025)',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AppTheme.spacingM),
        Row(
          children: [
            Expanded(
              child: _summaryCard(
                context,
                'Processed',
                '24 Tons',
                Icons.recycling,
                AppTheme.primaryGreen,
              ),
            ),
            const SizedBox(width: AppTheme.spacingM),
            Expanded(
              child: _summaryCard(
                context,
                'Pending',
                '5.2 Tons',
                Icons.hourglass_empty,
                AppTheme.warning,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _summaryCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.grey600,
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
              'Recent Transactions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingS),
        Card(
          child: Column(
            children: [
              _transactionTile(
                context,
                'Material IN - Plastic',
                '250 kg • Ward 15',
                'Today, 10:30 AM',
                isIncoming: true,
              ),
              const Divider(height: 1),
              _transactionTile(
                context,
                'Processed - Paper',
                '500 kg • Batch #892',
                'Yesterday',
                isIncoming: false,
              ),
              const Divider(height: 1),
               _transactionTile(
                context,
                'Material IN - E-Waste',
                '120 kg • Ward 8',
                'Oct 24',
                isIncoming: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _transactionTile(BuildContext context, String title, String subtitle, String time, {required bool isIncoming}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isIncoming ? AppTheme.info.withOpacity(0.1) : AppTheme.success.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          isIncoming ? Icons.arrow_downward : Icons.arrow_upward,
          color: isIncoming ? AppTheme.info : AppTheme.success,
          size: 20,
        ),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.grey600)),
      trailing: Text(time, style: const TextStyle(fontSize: 12, color: AppTheme.grey500)),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AppTheme.spacingM),
        Row(
          children: [
            Expanded(
              child: _actionButton(
                context,
                'Add Material',
                Icons.add_circle_outline,
                () => onNavigate(1), // Go to Materials tab
              ),
            ),
            const SizedBox(width: AppTheme.spacingM),
            Expanded(
              child: _actionButton(
                context,
                'Get Certificate',
                Icons.card_membership,
                () => onNavigate(2), // Go to Certificates tab
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _actionButton(BuildContext context, String label, IconData icon, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.primaryGreen,
        padding: const EdgeInsets.symmetric(vertical: 12),
        elevation: 2,
      ),
    );
  }
}
