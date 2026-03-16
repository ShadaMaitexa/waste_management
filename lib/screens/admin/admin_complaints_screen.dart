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
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(80),
            child: Container(
              padding: const EdgeInsets.only(top: 10),
              decoration: const BoxDecoration(
                gradient: AppTheme.slateGradient,
              ),
              child: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                scrolledUnderElevation: 0,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Incident Resolution',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                        color: Colors.white,
                        letterSpacing: -0.8,
                      ),
                    ),
                    Text(
                      'Citizen grievance and system health monitoring',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                foregroundColor: Colors.white,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.tune_rounded, color: Colors.white70),
                    onPressed: () {},
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),
          body: adminService.isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: () => adminService.fetchComplaints(),
                  color: AppTheme.primaryEmerald,
                  child: complaints.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                          physics: const BouncingScrollPhysics(),
                          itemCount: complaints.length,
                          itemBuilder: (context, index) => _buildComplaintCard(complaints[index]),
                        ),
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
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
        border: Border.all(color: statusColor.withValues(alpha: 0.15), width: 1.5),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: statusColor.withValues(alpha: 0.05),
          highlightColor: statusColor.withValues(alpha: 0.02),
        ),
        child: ExpansionTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
          collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
          tilePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          childrenPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          leading: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(_getStatusIcon(complaint.status), color: statusColor, size: 24),
          ),
          title: Text(
            complaint.title,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: AppTheme.grey900, letterSpacing: -0.5),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Row(
              children: [
                Text(
                  'CASE #${complaint.id.hashCode.toString().toUpperCase().take(6)}', 
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppTheme.grey400, letterSpacing: 1),
                ),
                const SizedBox(width: 12),
                AppTheme.statusTag(complaint.status.toString().split('.').last, statusColor),
              ],
            ),
          ),
          children: [
            Container(
              height: 1,
              width: double.infinity,
              color: AppTheme.grey100,
              margin: const EdgeInsets.only(bottom: 24),
            ),
            _buildDetailRow('DESCRIPTION', complaint.description),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: _buildDetailRow('REPORTED AT', DateFormat('MMM d, yyyy • HH:mm').format(complaint.createdAt))),
                Expanded(child: _buildDetailRow('WARD ASSIGNMENT', complaint.wardNumber ?? 'PENDING')),
              ],
            ),
            if (complaint.imageUrl != null) ...[
              const SizedBox(height: 24),
              const Text('EVIDENCE PHOTOGRAPHY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppTheme.grey400, letterSpacing: 0.5)),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  complaint.imageUrl!, 
                  height: 200, 
                  width: double.infinity, 
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 150,
                    color: AppTheme.grey50,
                    child: const Icon(Icons.broken_image_rounded, color: AppTheme.grey300),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showActionDialog(complaint),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      side: const BorderSide(color: AppTheme.grey200, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      foregroundColor: AppTheme.grey900,
                    ),
                    child: const Text('UPDATE STATUS', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5, fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.grey900,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    icon: const Icon(Icons.support_agent_rounded, size: 18),
                    label: const Text('ENGAGE AGENT', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5, fontSize: 12)),
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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(36))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 32, right: 32, top: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(color: AppTheme.grey200, borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 32),
              const Text('Resolve Incident', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: -0.5)),
              const Text('Determine the final state of this case and provide closure notes.', style: TextStyle(color: AppTheme.grey400, fontSize: 14)),
              const SizedBox(height: 32),
              const Text('SELECT RESOLUTION STATUS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppTheme.grey400, letterSpacing: 0.5)),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ComplaintStatus.values.map((status) {
                    final isSelected = selectedStatus == status.name;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(status.name.toUpperCase()),
                        selected: isSelected,
                        onSelected: (_) => setModalState(() => selectedStatus = status.name),
                        backgroundColor: AppTheme.grey50,
                        selectedColor: _getStatusColor(status),
                        labelStyle: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: isSelected ? Colors.white : AppTheme.grey400,
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide.none),
                        showCheckmark: false,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 32),
              const Text('RESOLUTION CLOSURE NOTE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppTheme.grey400, letterSpacing: 0.5)),
              const SizedBox(height: 12),
              TextField(
                controller: responseController,
                maxLines: 4,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.grey900),
                decoration: InputDecoration(
                  hintText: 'Document the actions taken to resolve this case...',
                  hintStyle: const TextStyle(color: AppTheme.grey300),
                  filled: true,
                  fillColor: AppTheme.grey50,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.all(20),
                ),
              ),
              const SizedBox(height: 40),
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
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Case resolution updated successfully'),
                            backgroundColor: AppTheme.primaryEmerald,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          )
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryEmerald,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text('CONFIRM RESOLUTION', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String take(int n) => length > n ? substring(0, n) : this;
}
