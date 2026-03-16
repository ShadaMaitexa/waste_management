import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class RecyclerCertificatesScreen extends StatefulWidget {
  const RecyclerCertificatesScreen({super.key});

  @override
  State<RecyclerCertificatesScreen> createState() => _RecyclerCertificatesScreenState();
}

class _RecyclerCertificatesScreenState extends State<RecyclerCertificatesScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedType = 'All';
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
      backgroundColor: AppTheme.bgSurface,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(130),
        child: Container(
          padding: const EdgeInsets.only(top: 20),
          decoration: const BoxDecoration(
            color: AppTheme.bgDark,
            gradient: AppTheme.slateGradient,
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Certificate Vault',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w900, 
                color: Colors.white, 
                fontSize: 22,
                letterSpacing: -1,
              ),
            ),
            centerTitle: true,
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: AppTheme.primaryEmerald,
              indicatorWeight: 4,
              indicatorSize: TabBarIndicatorSize.label,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white.withValues(alpha: 0.5),
              labelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1),
              tabs: const [
                Tab(text: 'PROCESSING'),
                Tab(text: 'MATERIALS'),
                Tab(text: 'COMPLIANCE'),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.tune_rounded, color: Colors.white, size: 22),
                onPressed: _showFilterDialog,
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
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
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryEmerald.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton(
          backgroundColor: AppTheme.primaryEmerald,
          elevation: 0,
          highlightElevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          onPressed: _showGenerateCertificateDialog,
          child: const Icon(Icons.add_moderator_rounded, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  Widget _buildSummarySection() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          _summaryCard('TOTAL', '24', Icons.card_membership_rounded, AppTheme.accentIndigo),
          const SizedBox(width: 16),
          _summaryCard('ACTIVE', '18', Icons.verified_user_rounded, AppTheme.success),
          const SizedBox(width: 16),
          _summaryCard('EARNINGS', '₹1.2L', Icons.monetization_on_rounded, AppTheme.warning),
        ],
      ),
    );
  }

  Widget _summaryCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: AppTheme.smoothShadow,
          border: Border.all(color: AppTheme.grey200.withValues(alpha: 0.5), width: 1.5),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: AppTheme.grey900,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 9, 
                fontWeight: FontWeight.w900, 
                color: AppTheme.grey400, 
                letterSpacing: 1.5,
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
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: _filters.map((filter) {
          final isSelected = _selectedType == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ChoiceChip(
              label: Text(filter.toUpperCase()),
              selected: isSelected,
              onSelected: (_) => setState(() => _selectedType = filter),
              backgroundColor: Colors.white,
              selectedColor: AppTheme.primaryEmerald,
              labelStyle: GoogleFonts.plusJakartaSans(
                color: isSelected ? Colors.white : AppTheme.grey500,
                fontWeight: FontWeight.w900,
                fontSize: 10,
                letterSpacing: 1,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isSelected ? AppTheme.primaryEmerald : AppTheme.grey200.withValues(alpha: 0.5),
                  width: 1.5,
                ),
              ),
              showCheckmark: false,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              elevation: isSelected ? 8 : 0,
              shadowColor: AppTheme.primaryEmerald.withValues(alpha: 0.3),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCertificateList(String type) {
    final filtered = _certificates.where((cert) {
      final matchesType = cert['type'] == type;
      final matchesFilter = _selectedType == 'All' ||
          (_selectedType == 'Active' && cert['status'] == 'Active') ||
          (_selectedType == 'Expired' && cert['status'] == 'Expired') ||
          (_selectedType == 'Pending' && cert['status'] == 'Pending');
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
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(36),
        boxShadow: AppTheme.smoothShadow,
        border: Border.all(color: AppTheme.grey200.withValues(alpha: 0.5), width: 1.5),
      ),
      child: InkWell(
        onTap: () => _viewCertificateDetails(cert),
        borderRadius: BorderRadius.circular(36),
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
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            color: AppTheme.grey900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          cert['certificateId'],
                          style: GoogleFonts.inter(
                            color: AppTheme.grey400,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
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
                    const SizedBox(height: 12),
                    _detailRow(Icons.scale_rounded, 'Quantity: ${cert['quantity']}'),
                    const SizedBox(height: 12),
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
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        foregroundColor: AppTheme.grey700,
                        side: BorderSide(color: AppTheme.grey200, width: 1.5),
                        textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, fontSize: 13),
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
                        backgroundColor: AppTheme.primaryEmerald,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 8,
                        shadowColor: AppTheme.primaryEmerald.withValues(alpha: 0.3),
                        textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, fontSize: 13),
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
        Icon(icon, size: 16, color: AppTheme.grey400),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              color: AppTheme.grey600, 
              fontWeight: FontWeight.w600, 
              fontSize: 13,
            ),
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
