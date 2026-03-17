import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../services/admin_service.dart';
import '../../models/complaint.dart';
import '../../theme/app_theme.dart';

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
          backgroundColor: AppTheme.bgSurface,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(120),
            child: Container(
              padding: const EdgeInsets.only(top: 20),
              decoration: const BoxDecoration(
                color: AppTheme.bgSurface,
              ),
              child: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                scrolledUnderElevation: 0,
                centerTitle: false,
                title: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Resolution Center',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w900,
                          fontSize: 28,
                          color: AppTheme.grey900,
                          letterSpacing: -1.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'INCIDENT MONITORING & SYSTEM HEALTH',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 8,
                          color: AppTheme.grey400,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                foregroundColor: AppTheme.grey900,
                actions: [
                  Container(
                    margin: const EdgeInsets.only(right: 20, top: 12),
                    height: 44,
                    width: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.grey100),
                      boxShadow: AppTheme.cardShadow,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.tune_rounded, color: AppTheme.grey900, size: 18),
                      onPressed: () {},
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ),
          ),
          body: adminService.isLoading
              ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryEmerald))
              : RefreshIndicator(
                  onRefresh: () => adminService.fetchComplaints(),
                  color: AppTheme.primaryEmerald,
                  child: complaints.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
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
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: AppTheme.primaryEmerald.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(Icons.verified_user_rounded, size: 80, color: AppTheme.primaryEmerald.withValues(alpha: 0.2)),
          ),
          const SizedBox(height: 32),
          Text(
            'All systems clear', 
            style: GoogleFonts.plusJakartaSans(
              color: AppTheme.grey900, 
              fontWeight: FontWeight.w900,
              fontSize: 24,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No active incidents or grievances reported.', 
            style: GoogleFonts.inter(
              color: AppTheme.grey400, 
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComplaintCard(Complaint complaint) {
    final statusColor = _getStatusColor(complaint.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: AppTheme.cardShadow,
        border: Border.all(color: AppTheme.grey100, width: 1.5),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
          collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
          tilePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          childrenPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          leading: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(_getStatusIcon(complaint.status), color: statusColor, size: 24),
          ),
          title: Text(
            complaint.title,
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w900, 
              fontSize: 16, 
              color: AppTheme.grey900, 
              letterSpacing: -0.5,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Text(
                  'CASE #${complaint.id.hashCode.toString().toUpperCase().take(6)}', 
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 8, 
                    fontWeight: FontWeight.w900, 
                    color: AppTheme.grey400, 
                    letterSpacing: 1.5,
                  ),
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
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _buildDetailRow('REPORTED AT', DateFormat('MMM d, yyyy • HH:mm').format(complaint.createdAt))),
                const SizedBox(width: 16),
                Expanded(child: _buildDetailRow('WARD ASSIGNMENT', complaint.wardNumber ?? 'PENDING')),
              ],
            ),
            if (complaint.imageUrl != null) ...[
              const SizedBox(height: 32),
              Text(
                'EVIDENCE PHOTOGRAPHY', 
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 8, 
                  fontWeight: FontWeight.w900, 
                  color: AppTheme.grey400, 
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 16),
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
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      side: const BorderSide(color: AppTheme.grey200, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      foregroundColor: AppTheme.grey900,
                    ),
                    child: Text(
                      'UPDATE STATUS', 
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w900, 
                        letterSpacing: 1, 
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Confirm Deletion'),
                          content: const Text('Are you sure you want to permanently delete this complaint record?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('CANCEL')),
                            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('DELETE', style: TextStyle(color: AppTheme.error))),
                          ],
                        ),
                      );
                      if (confirm == true && mounted) {
                        final success = await context.read<AdminService>().deleteComplaint(complaint.id);
                        if (mounted && success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Complaint deleted successfully'), backgroundColor: AppTheme.bgDark),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.error.withValues(alpha: 0.1),
                      foregroundColor: AppTheme.error,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      side: BorderSide(color: AppTheme.error.withValues(alpha: 0.2), width: 1.5),
                    ),
                    child: Text(
                      'DELETE CASE', 
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w900, 
                        letterSpacing: 1, 
                        fontSize: 11,
                      ),
                    ),
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
        Text(
          label.toUpperCase(), 
          style: GoogleFonts.plusJakartaSans(
            fontSize: 8, 
            fontWeight: FontWeight.w900, 
            color: AppTheme.grey400, 
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value, 
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600, 
            fontSize: 13, 
            color: AppTheme.grey700,
            height: 1.5,
          ),
        ),
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
              Text(
                'Resolve Incident', 
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w900, 
                  fontSize: 26, 
                  letterSpacing: -1.5,
                  color: AppTheme.grey900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Determine the final state of this case and provide closure notes.', 
                style: GoogleFonts.inter(
                  color: AppTheme.grey500, 
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'SELECT RESOLUTION STATUS', 
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 8, 
                  fontWeight: FontWeight.w900, 
                  color: AppTheme.grey400, 
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: ComplaintStatus.values.map((status) {
                    final isSelected = selectedStatus == status.name;
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: GestureDetector(
                        onTap: () => setModalState(() => selectedStatus = status.name),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? _getStatusColor(status) : AppTheme.grey50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? _getStatusColor(status) : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            status.name.toUpperCase(),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: isSelected ? Colors.white : AppTheme.grey400,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'RESOLUTION CLOSURE NOTE', 
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 8, 
                  fontWeight: FontWeight.w900, 
                  color: AppTheme.grey400, 
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: responseController,
                maxLines: 4,
                style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500, color: AppTheme.grey900),
                decoration: InputDecoration(
                  hintText: 'Document the actions taken to resolve this case...',
                  hintStyle: GoogleFonts.inter(color: AppTheme.grey300, fontSize: 13),
                  filled: true,
                  fillColor: AppTheme.grey50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24), 
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24), 
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24), 
                    borderSide: const BorderSide(color: AppTheme.primaryEmerald, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.all(24),
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
                            content: Text(
                              'Case resolution updated successfully',
                              style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                            ),
                            backgroundColor: AppTheme.bgDark,
                            behavior: SnackBarBehavior.floating,
                            margin: const EdgeInsets.all(24),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          )
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryEmerald,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 22),
                    elevation: 8,
                    shadowColor: AppTheme.primaryEmerald.withValues(alpha: 0.3),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  child: Text(
                    'CONFIRM RESOLUTION', 
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w900, 
                      letterSpacing: 2,
                      fontSize: 13,
                    ),
                  ),
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
