import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  String _selectedType = 'All';
  final List<String> _reportTypes = ['All', 'Collection', 'Financial', 'Performance', 'Audit'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.grey50,
      appBar: AppBar(
        title: const Text(
          'Strategic Reports',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: -0.5),
        ),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              itemCount: 10, // Mock count
              itemBuilder: (context, index) {
                return _buildReportCard(index);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showGenerateReportDialog,
        backgroundColor: AppTheme.primaryGreen,
        icon: const Icon(Icons.add),
        label: const Text('Generate Report'),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: _reportTypes.map((type) {
                final isSelected = _selectedType == type;
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: FilterChip(
                    label: Text(type),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _selectedType = type),
                    backgroundColor: Colors.white,
                    selectedColor: AppTheme.primaryGreen.withOpacity(0.1),
                    checkmarkColor: AppTheme.primaryGreen,
                    side: BorderSide(
                      color: isSelected ? AppTheme.primaryGreen : AppTheme.grey200,
                      width: 1,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    labelStyle: TextStyle(
                      color: isSelected ? AppTheme.primaryGreen : AppTheme.grey600,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(int index) {
    final title = index % 2 == 0 ? 'Weekly Collection Summary' : 'Monthly Financial Performance';
    final date = 'Oct ${20 - index}, 2025';
    final type = index % 2 == 0 ? 'COLLECTION' : 'FINANCIAL';
    final typeColor = index % 2 == 0 ? AppTheme.primaryGreen : const Color(0xFF6366F1);
    final size = '${(index + 1) * 1.5} MB';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: typeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                index % 2 == 0 ? Icons.analytics_rounded : Icons.summarize_rounded,
                color: typeColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: AppTheme.grey900,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: typeColor.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          type,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: typeColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        date,
                        style: TextStyle(color: AppTheme.grey500, fontSize: 12),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '• $size',
                        style: TextStyle(color: AppTheme.grey500, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert_rounded, color: AppTheme.grey400),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              itemBuilder: (context) => <PopupMenuEntry<String>>[
                const PopupMenuItem(value: 'download', child: Text('Download')),
                const PopupMenuItem(value: 'share', child: Text('Share')),
                const PopupMenuDivider(),
                const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: AppTheme.error))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showGenerateReportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Generate New Report'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
             DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Report Type'),
              items: _reportTypes
                  .where((t) => t != 'All')
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (v) {},
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Date Range',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              readOnly: true,
              initialValue: 'Last 7 Days',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
               Navigator.pop(context);
               
               // Show loading/success
               ScaffoldMessenger.of(context).showSnackBar(
                 const SnackBar(content: Text('Report generation started...')),
               );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.white,
            ),
            child: const Text('Generate'),
          ),
        ],
      ),
    );
  }
}
