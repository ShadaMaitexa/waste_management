import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class MaterialsManagementScreen extends StatefulWidget {
  const MaterialsManagementScreen({super.key});

  @override
  State<MaterialsManagementScreen> createState() =>
      _MaterialsManagementScreenState();
}

class _MaterialsManagementScreenState extends State<MaterialsManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  String _selectedType = 'All';
  final List<String> _filters = ['All', 'Pending', 'Processed', 'Certified'];

  final List<Map<String, dynamic>> _materials = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _materials.addAll(_getMockMaterials());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgSurface,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(110), // Reduced from 130
        child: Container(
          padding: const EdgeInsets.only(top: 10), // Reduced from 20
          decoration: const BoxDecoration(
            color: AppTheme.bgDark,
            gradient: AppTheme.slateGradient,
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18), // Reduced from 20
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Inventory Control',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w900, 
                color: Colors.white, 
                fontSize: 18, // Reduced from 22
                letterSpacing: -0.8, // Reduced
              ),
            ),
            centerTitle: true,
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: AppTheme.primaryEmerald,
              indicatorWeight: 3, // Reduced from 4
              indicatorSize: TabBarIndicatorSize.label,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white.withValues(alpha: 0.5),
              labelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.8), // Reduced
              tabs: const [
                Tab(text: 'INCOMING'),
                Tab(text: 'PROCESSING'),
                Tab(text: 'CERTIFIED'),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.tune_rounded, color: Colors.white, size: 20), // Reduced from 22
                onPressed: _showFilterDialog,
              ),
              const SizedBox(width: 4), // Reduced from 8
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
                _buildMaterialList('incoming'),
                _buildMaterialList('processing'),
                _buildMaterialList('certified'),
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
          onPressed: _showAddMaterialDialog,
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  // ---------------- SUMMARY ----------------

  Widget _buildSummarySection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16), // Reduced from 24
      child: Row(
        children: [
          _summaryCard(
            'TOTAL',
            '2.4t',
            Icons.recycling_rounded,
            AppTheme.accentIndigo,
          ),
          const SizedBox(width: 12), // Reduced from 16
          _summaryCard(
            'MONTH',
            '450k',
            Icons.event_available_rounded,
            AppTheme.info,
          ),
          const SizedBox(width: 12), // Reduced from 16
          _summaryCard(
            'REVENUE',
            '₹45k',
            Icons.account_balance_wallet_rounded,
            AppTheme.primaryEmerald,
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8), // Reduced from 24, 12
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24), // Reduced from 32
          boxShadow: AppTheme.smoothShadow,
          border: Border.all(color: AppTheme.grey200.withValues(alpha: 0.5), width: 1.2), // Reduced width
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8), // Reduced from 12
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12), // Reduced from 16
              ),
              child: Icon(icon, color: color, size: 18), // Reduced from 22
            ),
            const SizedBox(height: 12), // Reduced from 16
            Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16, // Reduced from 20
                fontWeight: FontWeight.w900,
                color: AppTheme.grey900,
                letterSpacing: -0.8, // Reduced from -1
              ),
            ),
            const SizedBox(height: 2), // Reduced from 4
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 8, // Reduced from 9
                fontWeight: FontWeight.w900,
                color: AppTheme.grey400,
                letterSpacing: 1.2, // Reduced from 1.5
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- FILTER ----------------

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20), // Reduced from 24
      child: Row(
        children: _filters.map((filter) {
          final isSelected = _selectedType == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 10), // Reduced from 12
            child: ChoiceChip(
              label: Text(filter.toUpperCase()),
              selected: isSelected,
              onSelected: (_) => setState(() => _selectedType = filter),
              backgroundColor: Colors.white,
              selectedColor: AppTheme.primaryEmerald,
              labelStyle: GoogleFonts.plusJakartaSans(
                color: isSelected ? Colors.white : AppTheme.grey500,
                fontWeight: FontWeight.w900,
                fontSize: 9, // Reduced from 10
                letterSpacing: 0.8, // Reduced from 1
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12), // Reduced from 16
                side: BorderSide(
                  color: isSelected ? AppTheme.primaryEmerald : AppTheme.grey200.withValues(alpha: 0.5),
                  width: 1.2, // Reduced from 1.5
                ),
              ),
              showCheckmark: false,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // Reduced from 16, 12
              elevation: isSelected ? 4 : 0, // Reduced from 8
              shadowColor: AppTheme.primaryEmerald.withValues(alpha: 0.2), // Reduced from 0.3
            ),
          );
        }).toList(),
      ),
    );
  }

  // ---------------- MATERIAL LIST ----------------

  Widget _buildMaterialList(String status) {
    final filtered = _materials.where((m) {
      final matchesStatus = m['status'] == status;
      final matchesFilter = _selectedType == 'All' ||
          (_selectedType == 'Pending' && status == 'incoming') ||
          (_selectedType == 'Processed' && status == 'processing') ||
          (_selectedType == 'Certified' && status == 'certified');
      return matchesStatus && matchesFilter;
    }).toList();

    if (filtered.isEmpty) {
      return const Center(child: Text('No materials found'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      itemCount: filtered.length,
      itemBuilder: (_, i) => _buildMaterialCard(filtered[i]),
    );
  }

  Widget _buildMaterialCard(Map<String, dynamic> material) {
    final status = material['status'];
    final color = status == 'certified'
        ? AppTheme.success
        : status == 'processing'
            ? AppTheme.warning
            : AppTheme.info;

    return Container(
      margin: const EdgeInsets.only(bottom: 20), // Reduced from 24
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28), // Reduced from 36
        boxShadow: AppTheme.smoothShadow,
        border: Border.all(color: AppTheme.grey200.withValues(alpha: 0.5), width: 1.2), // Reduced width
      ),
      child: Padding(
        padding: const EdgeInsets.all(16), // Reduced from 20
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    material['material'],
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w900,
                      fontSize: 15, // Reduced from 18
                      color: AppTheme.grey900,
                      letterSpacing: -0.5, // Reduced from -0.8
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: color.withValues(alpha: 0.2)),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: GoogleFonts.plusJakartaSans(
                      color: color,
                      fontSize: 8, // Reduced from 9
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8, // Reduced from 1
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12, // Reduced from 16
              runSpacing: 6, // Reduced from 8
              children: [
                _detail(Icons.scale_rounded, 'Qty: ${material['quantity']}'),
                _detail(Icons.location_on_rounded, 'Ward ${material['ward']}'),
                _detail(Icons.calendar_today_rounded, DateFormat('MMM d').format(material['receivedDate'])),
              ],
            ),
            const SizedBox(height: 16), // Reduced from 20
            _buildActionButtons(material),
          ],
        ),
      ),
    );
  }

  Widget _detail(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppTheme.grey400), // Reduced from 16
        const SizedBox(width: 6), // Reduced from 8
        Text(
          text, 
          style: GoogleFonts.inter(
            color: AppTheme.grey600, 
            fontSize: 12, // Reduced from 13
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ---------------- ACTIONS ----------------

  Widget _buildActionButtons(Map<String, dynamic> material) {
    switch (material['status']) {
      case 'incoming':
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _processMaterial(material),
            icon: const Icon(Icons.flash_on_rounded, size: 16), // Reduced from 18
            label: Text(
              'START PROCESSING',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, letterSpacing: 0.8, fontSize: 13), // Adjusted
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryEmerald,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14), // Reduced from 18
              elevation: 4, // Reduced from 8
              shadowColor: AppTheme.primaryEmerald.withValues(alpha: 0.2), // Reduced
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Reduced from 16
            ),
          ),
        );
      case 'processing':
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _markProcessed(material),
            icon: const Icon(Icons.verified_rounded, size: 16), // Reduced from 18
            label: Text(
              'MARK CERTIFIED',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, letterSpacing: 0.8, fontSize: 13), // Adjusted
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.success,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14), // Reduced from 18
              elevation: 4, // Reduced from 8
              shadowColor: AppTheme.success.withValues(alpha: 0.2), // Reduced
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Reduced from 16
            ),
          ),
        );
      case 'certified':
        return SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _viewDetails(material),
            icon: const Icon(Icons.visibility_rounded, size: 16), // Reduced from 18
            label: Text(
              'VIEW DETAILS',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, letterSpacing: 0.8, fontSize: 13), // Adjusted
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.grey700,
              padding: const EdgeInsets.symmetric(vertical: 14), // Reduced from 18
              side: BorderSide(color: AppTheme.grey200, width: 1.2), // Reduced from 1.5
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Reduced from 16
            ),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  // ---------------- DIALOGS ----------------

  void _showAddMaterialDialog() {
    showDialog(
      context: context,
      builder: (_) => const AlertDialog(
        title: Text('Add Material'),
        content: Text('Feature coming soon'),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Filters'),
        content: const Text('Advanced filters coming soon'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _viewDetails(Map<String, dynamic> material) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Material ${material['id']}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: material.entries
                .map((e) => Text('${e.key}: ${e.value}'))
                .toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // ---------------- STATE UPDATES ----------------

  void _processMaterial(Map<String, dynamic> material) {
    setState(() => material['status'] = 'processing');
  }

  void _markProcessed(Map<String, dynamic> material) {
    setState(() {
      material['status'] = 'certified';
      material['certificate'] =
          'CERT-${DateTime.now().millisecondsSinceEpoch}';
    });
  }

  // ---------------- MOCK DATA ----------------

  List<Map<String, dynamic>> _getMockMaterials() {
    return [
      {
        'id': 'MAT001',
        'material': 'Plastic Waste',
        'quantity': '250 kg',
        'ward': '15',
        'collector': 'Worker 001',
        'status': 'incoming',
        'receivedDate': DateTime.now(),
        'certificate': null,
      },
      {
        'id': 'MAT002',
        'material': 'Paper Waste',
        'quantity': '180 kg',
        'ward': '12',
        'collector': 'Worker 002',
        'status': 'processing',
        'receivedDate': DateTime.now().subtract(const Duration(days: 2)),
        'certificate': null,
      },
      {
        'id': 'MAT003',
        'material': 'Metal Scrap',
        'quantity': '95 kg',
        'ward': '8',
        'collector': 'Worker 003',
        'status': 'certified',
        'receivedDate': DateTime.now().subtract(const Duration(days: 5)),
        'certificate': 'CERT-2025-003',
      },
    ];
  }
}
