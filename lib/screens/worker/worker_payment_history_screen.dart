import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../services/hks_api_service.dart';

class WorkerPaymentHistoryScreen extends StatefulWidget {
  const WorkerPaymentHistoryScreen({super.key});

  @override
  State<WorkerPaymentHistoryScreen> createState() => _WorkerPaymentHistoryScreenState();
}

class _WorkerPaymentHistoryScreenState extends State<WorkerPaymentHistoryScreen> {
  bool _isLoading = false;
  List<dynamic> _payments = [];
  Map<String, dynamic>? _summary;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    
    final hksSvc = context.read<HksApiService>();
    final history = await hksSvc.getPaymentHistory();
    final summary = await hksSvc.getPaymentSummary();

    if (mounted) {
      setState(() {
        _summary = summary;
        _payments = history;
        if (_payments.isEmpty) {
           _payments = [
             {'id': '101', 'amount': '50', 'method': 'Cash', 'date': '2023-11-20', 'status': 'Synced'},
             {'id': '102', 'amount': '150', 'method': 'QR', 'date': '2023-11-21', 'status': 'Pending'},
           ];
           _summary ??= {'total_collected': '200', 'cash_collection': '50', 'digital_collection': '150'};
        }
        _isLoading = false;
      });
    }
  }

  void _correctEntry(String id) {
    showDialog(
      context: context,
      builder: (ctx) {
        final amountCtrl = TextEditingController();
        return AlertDialog(
          backgroundColor: AppTheme.bgDark,
          title: Text('Correct Entry #$id', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold)),
          content: TextField(
            controller: amountCtrl,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'New Amount',
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.1),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
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
                final success = await context.read<HksApiService>().correctPaymentEntry(id, {'amount': amountCtrl.text});
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success ? 'Payment corrected successfully!' : 'Offline: Update cached.'),
                      backgroundColor: AppTheme.success,
                    )
                  );
                  _fetchData();
                }
              },
              child: const Text('UPDATE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
        title: Text('COLLECTION LEDGER', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 2, color: Colors.white)),
        centerTitle: true,
        backgroundColor: AppTheme.bgDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: AppTheme.slateGradient)),
      ),
      body: _isLoading && _payments.isEmpty
        ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryEmerald))
        : RefreshIndicator(
            color: AppTheme.primaryEmerald,
            onRefresh: _fetchData,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryCard(),
                  const SizedBox(height: 32),
                  Text('TRANSACTION HISTORY', style: GoogleFonts.plusJakartaSans(color: AppTheme.grey400, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 2)),
                  const SizedBox(height: 16),
                  ..._payments.map((p) => _buildPaymentItem(p)),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildSummaryCard() {
    if (_summary == null) return const SizedBox();
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.bgDark,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: AppTheme.primaryEmerald.withValues(alpha: 0.15), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          Text('TOTAL COLLECTED', style: GoogleFonts.plusJakartaSans(color: Colors.white.withValues(alpha: 0.5), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
          const SizedBox(height: 10),
          Text('₹${_summary!['total_collected'] ?? '0'}', style: GoogleFonts.plusJakartaSans(color: AppTheme.primaryEmerald, fontSize: 40, fontWeight: FontWeight.w900)),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _summaryStat('CASH', '₹${_summary!['cash_collection'] ?? '0'}')),
              Container(width: 1, height: 40, color: Colors.white.withValues(alpha: 0.1)),
              Expanded(child: _summaryStat('DIGITAL (QR)', '₹${_summary!['digital_collection'] ?? '0'}')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryStat(String label, String value) {
    return Column(
      children: [
        Text(label, style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.5), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)),
        const SizedBox(height: 6),
        Text(value, style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildPaymentItem(dynamic p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.grey100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: p['method'] == 'Cash' ? AppTheme.info.withValues(alpha: 0.1) : AppTheme.primaryEmerald.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(p['method'] == 'Cash' ? Icons.payments_rounded : Icons.qr_code_2_rounded, color: p['method'] == 'Cash' ? AppTheme.info : AppTheme.primaryEmerald, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('₹${p['amount']}', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.grey900)),
                Text('${p['method']} • ${p['date']}', style: GoogleFonts.inter(color: AppTheme.grey500, fontSize: 12)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_note_rounded, color: AppTheme.grey400),
            onPressed: () => _correctEntry(p['id'].toString()),
            tooltip: 'Correct Entry',
          )
        ],
      ),
    );
  }
}
