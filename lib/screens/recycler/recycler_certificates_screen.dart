import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
      appBar: AppBar(
        title: const Text('Certificates'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Processing'),
            Tab(text: 'Materials'),
            Tab(text: 'Compliance'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showGenerateCertificateDialog,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
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
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      child: Row(
        children: [
          _summaryCard('Total Certificates', '24', Icons.card_membership, AppTheme.primaryGreen),
          const SizedBox(width: AppTheme.spacingS),
          _summaryCard('This Month', '6', Icons.calendar_today, AppTheme.info),
          const SizedBox(width: AppTheme.spacingS),
          _summaryCard('Active', '18', Icons.check_circle, AppTheme.success),
          const SizedBox(width: AppTheme.spacingS),
          _summaryCard('Revenue', '₹1,25,000', Icons.currency_rupee, AppTheme.warning),
        ],
      ),
    );
  }

  Widget _summaryCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          child: Column(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  color: AppTheme.grey600,
                ),
              ),
            ],
          ),
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
              selectedColor: AppTheme.primaryGreen.withOpacity(0.2),
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

    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      child: InkWell(
        onTap: () => _viewCertificateDetails(cert),
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusS),
                    ),
                    child: Icon(
                      _getCertificateIcon(cert['type']),
                      color: color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cert['title'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          cert['certificateId'],
                          style: TextStyle(
                            color: AppTheme.grey600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingS,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusS),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingM),
              _detailRow(Icons.factory, 'Material: ${cert['material']}'),
              const SizedBox(height: AppTheme.spacingXS),
              _detailRow(Icons.scale, 'Quantity: ${cert['quantity']}'),
              const SizedBox(height: AppTheme.spacingXS),
              _detailRow(Icons.date_range, 'Issued: ${cert['issueDate']}'),
              const SizedBox(height: AppTheme.spacingXS),
              _detailRow(Icons.event, 'Valid Until: ${cert['expiryDate']}'),
              if (cert['authority'] != null) ...[
                const SizedBox(height: AppTheme.spacingXS),
                _detailRow(Icons.gavel, 'Authority: ${cert['authority']}'),
              ],
              const SizedBox(height: AppTheme.spacingM),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _downloadCertificate(cert),
                      child: const Text('Download'),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingS),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _shareCertificate(cert),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Share'),
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
