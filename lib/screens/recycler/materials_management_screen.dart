import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  String _selectedFilter = 'All';
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
      backgroundColor: AppTheme.grey50,
      appBar: AppBar(
        title: const Text(
          'Inventory Control',
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
            Tab(text: 'INCOMING'),
            Tab(text: 'PROCESSING'),
            Tab(text: 'CERTIFIED'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded),
            onPressed: _showAddMaterialDialog,
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
                _buildMaterialList('incoming'),
                _buildMaterialList('processing'),
                _buildMaterialList('certified'),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryGreen,
        onPressed: _showAddMaterialDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  // ---------------- SUMMARY ----------------

  Widget _buildSummarySection() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      child: Row(
        children: [
          _summaryCard(
            'TOTAL',
            '2.4t',
            Icons.recycling_rounded,
            const Color(0xFF6366F1),
          ),
          const SizedBox(width: AppTheme.spacingS),
          _summaryCard(
            'MONTH',
            '450k',
            Icons.event_available_rounded,
            AppTheme.info,
          ),
          const SizedBox(width: AppTheme.spacingS),
          _summaryCard(
            'REVENUE',
            '₹45k',
            Icons.account_balance_wallet_rounded,
            AppTheme.success,
          ),
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
              color: color.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(color: color.withOpacity(0.05), width: 1),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
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

  // ---------------- FILTER ----------------

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

  // ---------------- MATERIAL LIST ----------------

  Widget _buildMaterialList(String status) {
    final filtered = _materials.where((m) {
      final matchesStatus = m['status'] == status;
      final matchesFilter = _selectedFilter == 'All' ||
          (_selectedFilter == 'Pending' && status == 'incoming') ||
          (_selectedFilter == 'Processed' && status == 'processing') ||
          (_selectedFilter == 'Certified' && status == 'certified');
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
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    material['material'],
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: AppTheme.grey900,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: color,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _detail(Icons.scale_rounded, 'Qty: ${material['quantity']}'),
                _detail(Icons.location_on_rounded, 'Ward ${material['ward']}'),
                _detail(Icons.calendar_today_rounded, DateFormat('MMM d').format(material['receivedDate'])),
              ],
            ),
            const SizedBox(height: 20),
            _buildActionButtons(material),
          ],
        ),
      ),
    );
  }

  Widget _detail(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppTheme.grey600),
          const SizedBox(width: 6),
          Expanded(child: Text(text)),
        ],
      ),
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
            icon: const Icon(Icons.flash_on_rounded, size: 18),
            label: const Text('START PROCESSING'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        );
      case 'processing':
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _markProcessed(material),
            icon: const Icon(Icons.verified_rounded, size: 18),
            label: const Text('MARK CERTIFIED'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.success,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        );
      case 'certified':
        return SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _viewDetails(material),
            icon: const Icon(Icons.visibility_rounded, size: 18),
            label: const Text('VIEW DETAILS'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.grey700,
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: BorderSide(color: AppTheme.grey300),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
