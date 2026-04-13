import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../services/hks_api_service.dart';

class WorkerComplaintsScreen extends StatefulWidget {
  const WorkerComplaintsScreen({super.key});

  @override
  State<WorkerComplaintsScreen> createState() => _WorkerComplaintsScreenState();
}

class _WorkerComplaintsScreenState extends State<WorkerComplaintsScreen> {
  bool _isLoading = false;
  List<dynamic> _complaints = [];

  @override
  void initState() {
    super.initState();
    _fetchComplaints();
  }

  Future<void> _fetchComplaints() async {
    setState(() => _isLoading = true);
    final data = await context.read<HksApiService>().getComplaints();
    if (mounted) {
      setState(() {
        _complaints = data;
        if (_complaints.isEmpty) {
           _complaints = [
             {'id': '1', 'title': 'Overflowing Bin - Ward 15', 'status': 'Pending', 'desc': 'Citizen reported overflowing wet waste.'},
             {'id': '2', 'title': 'Missed Pickup', 'status': 'Resolved', 'desc': 'Resident reporting missed collection on Monday.'},
           ];
        }
        _isLoading = false;
      });
    }
  }

  void _resolveComplaint(String id) async {
    setState(() => _isLoading = true);
    final success = await context.read<HksApiService>().resolveComplaint(id, 'Resolved');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Complaint Resolved!' : 'Offline: Marked as Resolved locally.'),
          backgroundColor: AppTheme.success,
        ),
      );
      // Simulate local update
      setState(() {
        final index = _complaints.indexWhere((c) => c['id'] == id);
        if (index != -1) _complaints[index]['status'] = 'Resolved';
        _isLoading = false;
      });
    }
  }

  void _selfReportIssue() {
    // Show a dialog to create a new complaint
    showDialog(
      context: context,
      builder: (ctx) {
        final titleCtrl = TextEditingController();
        final descCtrl = TextEditingController();
        return AlertDialog(
          backgroundColor: AppTheme.bgDark,
          title: Text('Self-Report Issue', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Title',
                  hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.1),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Description',
                  hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.1),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('CANCEL', style: TextStyle(color: AppTheme.grey400)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryEmerald),
              onPressed: () async {
                Navigator.pop(ctx);
                setState(() => _isLoading = true);
                final success = await context.read<HksApiService>().selfReportComplaint({
                  'title': titleCtrl.text,
                  'description': descCtrl.text,
                  'status': 'Pending'
                });
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success ? 'Report submitted successfully!' : 'Offline: Report cached.'),
                      backgroundColor: AppTheme.success,
                    )
                  );
                  _fetchComplaints();
                }
              },
              child: const Text('SUBMIT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgSurface,
      appBar: AppBar(
        title: Text('CIVIC ALERTS & REPORTS', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1.5, color: Colors.white)),
        centerTitle: true,
        backgroundColor: AppTheme.bgDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: AppTheme.primaryEmerald),
            onPressed: _selfReportIssue,
            tooltip: 'Self-Report Issue',
          )
        ],
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: AppTheme.slateGradient)),
      ),
      body: _isLoading && _complaints.isEmpty
        ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryEmerald))
        : ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: _complaints.length,
            itemBuilder: (ctx, index) {
              final c = _complaints[index];
              final isResolved = c['status'] == 'Resolved';
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: AppTheme.cardShadow,
                  border: Border.all(color: AppTheme.grey100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isResolved ? AppTheme.primaryEmerald.withValues(alpha: 0.1) : const Color(0xFFF59E0B).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            c['status'].toString().toUpperCase(),
                            style: GoogleFonts.plusJakartaSans(
                              color: isResolved ? AppTheme.primaryEmerald : const Color(0xFFF59E0B),
                              fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1,
                            ),
                          ),
                        ),
                        if (!isResolved)
                          TextButton.icon(
                            style: TextButton.styleFrom(
                              foregroundColor: AppTheme.primaryEmerald,
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            icon: const Icon(Icons.check_circle_outline, size: 16),
                            label: Text('RESOLVE', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold)),
                            onPressed: () => _resolveComplaint(c['id']),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(c['title'], style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 16, color: AppTheme.grey900)),
                    const SizedBox(height: 6),
                    Text(c['desc'], style: GoogleFonts.inter(color: AppTheme.grey500, fontSize: 13, height: 1.5)),
                  ],
                ),
              );
            },
          ),
    );
  }
}
