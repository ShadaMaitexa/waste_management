import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../theme/app_theme.dart';

/// FR-H-030, FR-H-031: Fee Collection (Offline Support)
class WorkerFeeCollectionScreen extends StatefulWidget {
  const WorkerFeeCollectionScreen({super.key});

  @override
  State<WorkerFeeCollectionScreen> createState() => _WorkerFeeCollectionScreenState();
}

class _WorkerFeeCollectionScreenState extends State<WorkerFeeCollectionScreen> {
  final _amountController = TextEditingController(text: '50');
  String _paymentMethod = 'Cash'; // Cash or QR
  bool _isProcessing = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _recordPayment() async {
    if (_amountController.text.isEmpty) return;
    
    setState(() => _isProcessing = true);
    
    // Simulate offline save / backend sync delay
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() => _isProcessing = false);
      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: AppTheme.bgDark,
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.success.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded, color: AppTheme.success, size: 48),
              ),
              const SizedBox(height: 24),
              Text('Payment Recorded!', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
              const SizedBox(height: 12),
              Text(
                'Fee collection for ₹${_amountController.text} via $_paymentMethod saved successfully.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(color: Colors.white.withOpacity(0.5), fontSize: 13, height: 1.5),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryEmerald,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Navigator.of(context).pop();
                  },
                  child: Text('DONE', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, letterSpacing: 2)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: Text(
          'FEE COLLECTION',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, fontSize: 14, color: Colors.white, letterSpacing: 2),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: AppTheme.slateGradient)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildAmountInput(),
            const SizedBox(height: 32),
            _buildPaymentMethodSelector(),
            const SizedBox(height: 32),
            if (_paymentMethod == 'QR') _buildStaticQR(),
            const SizedBox(height: 48),
            _buildRecordButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountInput() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Text(
            'COLLECTION AMOUNT',
            style: GoogleFonts.plusJakartaSans(color: Colors.white.withOpacity(0.4), fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 2),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('₹', style: GoogleFonts.plusJakartaSans(color: AppTheme.primaryEmerald, fontSize: 24, fontWeight: FontWeight.w900)),
              ),
              const SizedBox(width: 8),
              IntrinsicWidth(
                child: TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 56, fontWeight: FontWeight.w900, height: 1),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text('PAYMENT METHOD', style: GoogleFonts.plusJakartaSans(color: Colors.white.withOpacity(0.4), fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 2)),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _methodCard('Cash', Icons.payments_rounded)),
            const SizedBox(width: 16),
            Expanded(child: _methodCard('QR', Icons.qr_code_2_rounded)),
          ],
        ),
      ],
    );
  }

  Widget _methodCard(String method, IconData icon) {
    final isSelected = _paymentMethod == method;
    return GestureDetector(
      onTap: () => setState(() => _paymentMethod = method),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryEmerald.withOpacity(0.1) : Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.primaryEmerald : Colors.white.withOpacity(0.05),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? AppTheme.primaryEmerald : Colors.white.withOpacity(0.4), size: 28),
            const SizedBox(height: 12),
            Text(
              method.toUpperCase(),
              style: GoogleFonts.plusJakartaSans(
                color: isSelected ? AppTheme.primaryEmerald : Colors.white.withOpacity(0.6),
                fontWeight: FontWeight.w900,
                fontSize: 12,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStaticQR() {
    final upiId = 'corporation@sbi';
    final amount = _amountController.text.isNotEmpty ? _amountController.text : '0';
    final upiUrl = 'upi://pay?pa=$upiId&pn=WasteManagement&am=$amount&cu=INR';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Text('SCAN TO PAY', style: GoogleFonts.plusJakartaSans(color: AppTheme.grey400, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
          const SizedBox(height: 16),
          QrImageView(
            data: upiUrl,
            version: QrVersions.auto,
            size: 200,
            eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: AppTheme.bgDark),
            dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: AppTheme.bgDark),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordButton() {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: ElevatedButton(
        onPressed: _isProcessing ? null : _recordPayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryEmerald,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
          padding: EdgeInsets.zero,
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: _isProcessing ? null : AppTheme.emeraldGradient,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            alignment: Alignment.center,
            child: _isProcessing
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.save_rounded, size: 20),
                      const SizedBox(width: 12),
                      Text('RECORD PAYMENT', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, letterSpacing: 1.2, fontSize: 13)),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
