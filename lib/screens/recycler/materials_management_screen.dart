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
      appBar: AppBar(
        title: const Text('Materials Management'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Incoming'),
            Tab(text: 'Processing'),
            Tab(text: 'Certified'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddMaterialDialog,
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
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      child: Row(
        children: [
          _summaryCard('Total Processed', '2.4 tons', Icons.recycling,
              AppTheme.secondaryGreen),
          const SizedBox(width: AppTheme.spacingS),
          _summaryCard(
              'This Month', '450 kg', Icons.calendar_today, AppTheme.info),
          const SizedBox(width: AppTheme.spacingS),
          _summaryCard(
              'Revenue', '₹45,000', Icons.currency_rupee, AppTheme.success),
        ],
      ),
    );
  }

  Widget _summaryCard(
      String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          child: Column(
            children: [
              Icon(icon, color: color),
              const SizedBox(height: 4),
              Text(value,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: color)),
              Text(title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 11, color: AppTheme.grey600)),
            ],
          ),
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

    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    material['material'],
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Chip(
                  label: Text(status.toUpperCase()),
                  backgroundColor: color.withOpacity(0.1),
                  labelStyle: TextStyle(color: color),
                ),
              ],
            ),
            const SizedBox(height: 6),
            _detail(Icons.scale, 'Quantity: ${material['quantity']}'),
            _detail(Icons.location_on, 'Ward: ${material['ward']}'),
            _detail(Icons.person, 'Collector: ${material['collector']}'),
            _detail(
              Icons.access_time,
              'Received: ${DateFormat('MMM d, yyyy').format(material['receivedDate'])}',
            ),
            if (material['certificate'] != null)
              _detail(Icons.card_membership,
                  'Certificate: ${material['certificate']}'),
            const SizedBox(height: 8),
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
        return ElevatedButton(
          onPressed: () => _processMaterial(material),
          child: const Text('Start Processing'),
        );
      case 'processing':
        return ElevatedButton(
          onPressed: () => _markProcessed(material),
          child: const Text('Mark Certified'),
        );
      case 'certified':
        return OutlinedButton(
          onPressed: () => _viewDetails(material),
          child: const Text('View Details'),
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
