import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/admin_service.dart';
import '../../models/complaint.dart';
import '../../theme/app_theme.dart';
import 'package:intl/intl.dart';

class AdminComplaintsScreen extends StatefulWidget {
  const AdminComplaintsScreen({super.key});

  @override
  State<AdminComplaintsScreen> createState() => _AdminComplaintsScreenState();
}

class _AdminComplaintsScreenState extends State<AdminComplaintsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminService>().fetchComplaints();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminService>(
      builder: (context, adminService, child) {
        final complaints = adminService.complaints;

        return Scaffold(
          backgroundColor: AppTheme.grey50,
          appBar: AppBar(
            title: const Text('Incident Resolution'),
            actions: [
              IconButton(icon: const Icon(Icons.filter_list_rounded), onPressed: () {}),
              const SizedBox(width: 8),
            ],
          ),
          body: adminService.isLoading
              ? const Center(child: CircularProgressIndicator())
              : complaints.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: complaints.length,
                      itemBuilder: (context, index) => _buildComplaintCard(complaints[index]),
                    ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.verified_user_rounded, size: 64, color: AppTheme.success.withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          const Text('All systems clear. No active incidents.', 
            style: TextStyle(color: AppTheme.grey500, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildComplaintCard(Complaint complaint) {
    final statusColor = _getStatusColor(complaint.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.grey100),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(24))),
          collapsedShape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(24))),
          tilePadding: const EdgeInsets.all(20),
          childrenPadding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
          leading: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(_getStatusIcon(complaint.status), color: statusColor, size: 20),
          ),
          title: Text(
            complaint.title,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppTheme.grey900),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                Text('INC-${complaint.id.hashCode.toString().toUpperCase().take(6)}', 
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppTheme.grey400, letterSpacing: 1)),
                const SizedBox(width: 12),
                AppTheme.statusTag(complaint.status.toString().split('.').last, statusColor),
              ],
            ),
          ),
          children: [
            const Divider(color: AppTheme.grey100, height: 1),
            const SizedBox(height: 20),
            _buildDetailRow('Description', complaint.description),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildDetailRow('Reported At', DateFormat('MMM d, yyyy • HH:mm').format(complaint.createdAt))),
                Expanded(child: _buildDetailRow('Ward', complaint.wardNumber ?? 'Unassigned')),
              ],
            ),
            if (complaint.imageUrl != null) ...[
              const SizedBox(height: 20),
              const Text('EVIDENCE ATTACHMENT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppTheme.grey400)),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(complaint.imageUrl!, height: 180, width: double.infinity, fit: BoxFit.cover),
              ),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showActionDialog(complaint),
                    child: const Text('Update Status'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Text('Direct Action'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppTheme.grey400)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.grey700)),
      ],
    );
  }

  IconData _getStatusIcon(ComplaintStatus status) {
    switch (status) {
      case ComplaintStatus.pending: return Icons.priority_high_rounded;
      case ComplaintStatus.inProgress: return Icons.sync_rounded;
      case ComplaintStatus.resolved: return Icons.check_circle_rounded;
      case ComplaintStatus.closed: return Icons.inventory_2_rounded;
    }
  }

  Color _getStatusColor(ComplaintStatus status) {
    switch (status) {
      case ComplaintStatus.pending: return AppTheme.error;
      case ComplaintStatus.inProgress: return AppTheme.warning;
      case ComplaintStatus.resolved: return AppTheme.success;
      case ComplaintStatus.closed: return AppTheme.grey500;
    }
  }

  void _showActionDialog(Complaint complaint) {
    String selectedStatus = complaint.status.name;
    final responseController = TextEditingController(text: complaint.response);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 32, right: 32, top: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Resolve Incident', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
            const Text('Update the status of this complaint and provide a resolution note.', style: TextStyle(color: AppTheme.grey400, fontSize: 13)),
            const SizedBox(height: 24),
            const Text('INCIDENT STATUS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppTheme.grey400)),
            const SizedBox(height: 8),
            Row(
              children: ComplaintStatus.values.map((status) {
                final isSelected = selectedStatus == status.name;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => selectedStatus = status.name),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? _getStatusColor(status) : AppTheme.grey50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        status.name.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: isSelected ? Colors.white : AppTheme.grey400,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            const Text('RESOLUTION NOTE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppTheme.grey400)),
            const SizedBox(height: 8),
            TextField(
              controller: responseController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Describe the action taken...',
                filled: true,
                fillColor: AppTheme.grey50,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final success = await context.read<AdminService>().updateComplaintStatus(
                    complaint.id,
                    selectedStatus,
                    responseText: responseController.text,
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Complaint updated successfully')));
                    }
                  }
                },
                child: const Text('Confirm Resolution'),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String take(int n) => length > n ? substring(0, n) : this;
}
