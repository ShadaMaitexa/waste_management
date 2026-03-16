import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class RecyclerCertificatesScreen extends StatefulWidget {
  const RecyclerCertificatesScreen({super.key});

  @override
  State<RecyclerCertificatesScreen> createState() => _RecyclerCertificatesScreenState();
}

class _RecyclerCertificatesScreenState extends State<RecyclerCertificatesScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Active', 'Expired', 'Pending'];

  final List<Map<String, dynamic>> _certificates = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _certificates.addAll(_getMockCertificates());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.grey50,
      appBar: AppBar(
        title: const Text(
          'Certificate Vault',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: -0.5),
        ),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(text: 'PROCESSING'),
            Tab(text: 'MATERIALS'),
            Tab(text: 'COMPLIANCE'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_moderator_rounded),
            onPressed: _showGenerateCertificateDialog,
          ),
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSummarySection(),
          const SizedBox(height: AppTheme.spacingM),
          _buildFilterChips(),
          const SizedBox(height: AppTheme.spacingM),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCertificateList('processing'),
                _buildCertificateList('materials'),
                _buildCertificateList('compliance'),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryGreen,
        onPressed: _showGenerateCertificateDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummarySection() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      child: Row(
        children: [
          _summaryCard('TOTAL', '24', Icons.card_membership_rounded, AppTheme.primaryGreen),
          const SizedBox(width: AppTheme.spacingS),
          _summaryCard('ACTIVE', '18', Icons.verified_user_rounded, AppTheme.success),
          const SizedBox(width: AppTheme.spacingS),
          _summaryCard('EARNINGS', '₹1.2L', Icons.monetization_on_rounded, AppTheme.warning),
        ],
      ),
    );
  }

  Widget _summaryCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(color: color.withValues(alpha: 0.05), width: 1),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: color,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppTheme.grey500,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
      child: Row(
        children: _filters.map((filter) {
          return Padding(
            padding: const EdgeInsets.only(right: AppTheme.spacingS),
            child: FilterChip(
              label: Text(filter),
              selected: _selectedFilter == filter,
              selectedColor: AppTheme.primaryGreen.withValues(alpha: 0.2),
              checkmarkColor: AppTheme.primaryGreen,
              onSelected: (_) {
                setState(() => _selectedFilter = filter);
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCertificateList(String type) {
    final filtered = _certificates.where((cert) {
      final matchesType = cert['type'] == type;
      final matchesFilter = _selectedFilter == 'All' ||
          (_selectedFilter == 'Active' && cert['status'] == 'Active') ||
          (_selectedFilter == 'Expired' && cert['status'] == 'Expired') ||
          (_selectedFilter == 'Pending' && cert['status'] == 'Pending');
      return matchesType && matchesFilter;
    }).toList();

    if (filtered.isEmpty) {
      return const Center(child: Text('No certificates found'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      itemCount: filtered.length,
      itemBuilder: (_, i) => _buildCertificateCard(filtered[i]),
    );
  }

  Widget _buildCertificateCard(Map<String, dynamic> cert) {
    final status = cert['status'];
    final color = status == 'Active'
        ? AppTheme.success
        : status == 'Expired'
            ? AppTheme.error
            : AppTheme.warning;

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _viewCertificateDetails(cert),
        borderRadius: BorderRadius.circular(28),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      _getCertificateIcon(cert['type']),
                      color: color,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cert['title'],
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: AppTheme.grey900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          cert['certificateId'],
                          style: TextStyle(
                            color: AppTheme.grey500,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.grey50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _detailRow(Icons.eco_rounded, 'Material: ${cert['material']}'),
                    const SizedBox(height: 10),
                    _detailRow(Icons.scale_rounded, 'Quantity: ${cert['quantity']}'),
                    const SizedBox(height: 10),
                    _detailRow(Icons.event_available_rounded, 'Valid Until: ${cert['expiryDate']}'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _downloadCertificate(cert),
                      icon: const Icon(Icons.download_rounded, size: 18),
                      label: const Text('DOWNLOAD'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        foregroundColor: AppTheme.grey700,
                        side: BorderSide(color: AppTheme.grey300),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _shareCertificate(cert),
                      icon: const Icon(Icons.share_rounded, size: 18),
                      label: const Text('SHARE'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.grey600),
        const SizedBox(width: AppTheme.spacingS),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: AppTheme.grey700),
          ),
        ),
      ],
    );
  }

  IconData _getCertificateIcon(String type) {
    switch (type) {
      case 'processing':
        return Icons.recycling;
      case 'materials':
        return Icons.inventory;
      case 'compliance':
        return Icons.verified;
      default:
        return Icons.card_membership;
    }
  }

  void _showGenerateCertificateDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Generate Certificate'),
        content: const Text('Certificate generation feature coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Filter Certificates'),
        content: const Text('Advanced filters coming soon'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _viewCertificateDetails(Map<String, dynamic> cert) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Certificate Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('ID: ${cert['certificateId']}', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Title: ${cert['title']}'),
              const SizedBox(height: 8),
              Text('Type: ${cert['type']}'),
              const SizedBox(height: 8),
              Text('Material: ${cert['material']}'),
              const SizedBox(height: 8),
              Text('Quantity: ${cert['quantity']}'),
              const SizedBox(height: 8),
              Text('Issue Date: ${cert['issueDate']}'),
              const SizedBox(height: 8),
              Text('Expiry Date: ${cert['expiryDate']}'),
              const SizedBox(height: 8),
              Text('Status: ${cert['status']}'),
              if (cert['authority'] != null) ...[
                const SizedBox(height: 8),
                Text('Authority: ${cert['authority']}'),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _downloadCertificate(Map<String, dynamic> cert) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloading ${cert['certificateId']}...'),
        backgroundColor: AppTheme.success,
      ),
    );
  }

  void _shareCertificate(Map<String, dynamic> cert) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing ${cert['certificateId']}...'),
        backgroundColor: AppTheme.info,
      ),
    );
  }

  List<Map<String, dynamic>> _getMockCertificates() {
    return [
      {
        'certificateId': 'CERT-2025-001',
        'title': 'Plastic Waste Processing Certificate',
        'type': 'processing',
        'material': 'Plastic Waste',
        'quantity': '250 kg',
        'issueDate': 'Dec 28, 2025',
        'expiryDate': 'Dec 28, 2026',
        'status': 'Active',
        'authority': 'Kozhikode Municipal Corporation',
      },
      {
        'certificateId': 'CERT-2025-002',
        'title': 'Paper & Cardboard Processing Certificate',
        'type': 'processing',
        'material': 'Paper & Cardboard',
        'quantity': '180 kg',
        'issueDate': 'Dec 27, 2025',
        'expiryDate': 'Dec 27, 2026',
        'status': 'Active',
        'authority': 'Kozhikode Municipal Corporation',
      },
      {
        'certificateId': 'CERT-2025-003',
        'title': 'Metal Scrap Processing Certificate',
        'type': 'processing',
        'material': 'Metal Scrap',
        'quantity': '95 kg',
        'issueDate': 'Dec 26, 2025',
        'expiryDate': 'Dec 26, 2026',
        'status': 'Active',
        'authority': 'Kozhikode Municipal Corporation',
      },
      {
        'certificateId': 'CERT-2025-004',
        'title': 'EPR Compliance Certificate',
        'type': 'compliance',
        'material': 'Electronic Waste',
        'quantity': '45 kg',
        'issueDate': 'Dec 25, 2025',
        'expiryDate': 'Dec 25, 2026',
        'status': 'Pending',
        'authority': 'CPCB',
      },
      {
        'certificateId': 'CERT-2025-005',
        'title': 'Materials Processing Certificate',
        'type': 'materials',
        'material': 'Glass',
        'quantity': '120 kg',
        'issueDate': 'Dec 24, 2025',
        'expiryDate': 'Dec 24, 2026',
        'status': 'Expired',
        'authority': 'Kerala State Pollution Control Board',
      },
      {
        'certificateId': 'CERT-2025-006',
        'title': 'Textile Waste Processing Certificate',
        'type': 'processing',
        'material': 'Textile',
        'quantity': '75 kg',
        'issueDate': 'Dec 23, 2025',
        'expiryDate': 'Dec 23, 2026',
        'status': 'Active',
        'authority': 'Kozhikode Municipal Corporation',
      },
    ];
  }
}
