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
        title: const Text('Reports Center'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {},
          ),
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
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: AppTheme.spacingM),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _reportTypes.map((type) {
            final isSelected = _selectedType == type;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(type),
                selected: isSelected,
                selectedColor: AppTheme.primaryGreen.withOpacity(0.1),
                checkmarkColor: AppTheme.primaryGreen,
                labelStyle: TextStyle(
                  color: isSelected ? AppTheme.primaryGreen : AppTheme.grey700,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                onSelected: (selected) {
                  setState(() => _selectedType = type);
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildReportCard(int index) {
    // Mock data based on index
    final title = index % 2 == 0 ? 'Weekly Collection Summary' : 'Monthly Financial Report';
    final date = 'Oct ${20 - index}, 2025';
    final type = index % 2 == 0 ? 'Collection' : 'Financial';
    final size = '${(index + 1) * 1.5} MB';
    
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
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
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: (index % 2 == 0 ? Colors.blue : Colors.orange).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            index % 2 == 0 ? Icons.description : Icons.pie_chart,
            color: index % 2 == 0 ? Colors.blue : Colors.orange,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.grey100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(type, style: const TextStyle(fontSize: 10, color: AppTheme.grey700)),
                ),
                const SizedBox(width: 8),
                Text(date, style: const TextStyle(fontSize: 12)),
                const SizedBox(width: 8),
                Text('• $size', style: const TextStyle(fontSize: 12)),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'download', child: Text('Download')),
            const PopupMenuItem(value: 'share', child: Text('Share')),
            const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
          ],
          onSelected: (value) {
            // TODO: Implement actions
          },
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
