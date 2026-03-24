import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';
import '../../models/pickup.dart';
import '../../services/qr_service.dart';
import '../../theme/app_theme.dart';

/// FR-R-013: Display QR encoding pickup_id + resident_id + ward_id + timestamp (SHA-256)
class PickupQRScreen extends StatelessWidget {
  final Pickup pickup;

  const PickupQRScreen({super.key, required this.pickup});

  @override
  Widget build(BuildContext context) {
    final qrHash = QRService.generatePickupHash(pickup);
    final qrData = 'greenloop:pickup:${pickup.id}:$qrHash';

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 80,
            pinned: true,
            backgroundColor: AppTheme.bgDark,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppTheme.slateGradient,
                ),
              ),
              titlePadding: const EdgeInsets.fromLTRB(60, 0, 20, 16),
              title: Text(
                'PICKUP QR CODE',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  // Status badge
                  _buildStatusBadge(pickup.status),
                  const SizedBox(height: 32),
                  // QR Card
                  _buildQRCard(qrData),
                  const SizedBox(height: 28),
                  // Pickup details card
                  _buildDetailsCard(context),
                  const SizedBox(height: 28),
                  // Hash info card
                  _buildHashCard(qrHash),
                  const SizedBox(height: 40),
                  // Instructions
                  _buildInstructions(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(PickupStatus status) {
    final colors = {
      PickupStatus.scheduled: AppTheme.primaryEmerald,
      PickupStatus.assigned: AppTheme.info,
      PickupStatus.inProgress: AppTheme.warning,
      PickupStatus.completed: AppTheme.success,
      PickupStatus.cancelled: AppTheme.error,
      PickupStatus.failed: AppTheme.error,
    };
    final color = colors[status] ?? AppTheme.primaryEmerald;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(
            status.name.toUpperCase(),
            style: GoogleFonts.plusJakartaSans(color: color, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildQRCard(String qrData) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(color: AppTheme.primaryEmerald.withOpacity(0.2), blurRadius: 40, offset: const Offset(0, 20)),
          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.qr_code_2_rounded, color: AppTheme.primaryEmerald, size: 18),
              const SizedBox(width: 8),
              Text(
                'SHOW TO HKS WORKER',
                style: GoogleFonts.plusJakartaSans(
                  color: AppTheme.grey500,
                  fontWeight: FontWeight.w900,
                  fontSize: 9,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          QrImageView(
            data: qrData,
            version: QrVersions.auto,
            size: 240,
            backgroundColor: Colors.white,
            eyeStyle: const QrEyeStyle(
              eyeShape: QrEyeShape.square,
              color: AppTheme.bgDark,
            ),
            dataModuleStyle: const QrDataModuleStyle(
              dataModuleShape: QrDataModuleShape.square,
              color: AppTheme.bgDark,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Pickup ID: #${pickup.id}',
            style: GoogleFonts.plusJakartaSans(
              color: AppTheme.grey400,
              fontWeight: FontWeight.w700,
              fontSize: 12,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          _detailRow(Icons.calendar_today_rounded, 'Scheduled Date',
              DateFormat('EEEE, MMM d, yyyy').format(pickup.scheduledDate)),
          const SizedBox(height: 16),
          _detailRow(Icons.access_time_rounded, 'Time Slot', pickup.slotDisplay.isNotEmpty ? pickup.slotDisplay : 'TBD'),
          const SizedBox(height: 16),
          _detailRow(Icons.location_on_rounded, 'Address', pickup.address),
          const SizedBox(height: 16),
          _detailRow(Icons.delete_outline_rounded, 'Waste Type', pickup.wasteType.toUpperCase()),
          if (pickup.assignedWorkerName != null) ...[
            const SizedBox(height: 16),
            _detailRow(Icons.engineering_rounded, 'Assigned Worker', pickup.assignedWorkerName!),
          ],
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryEmerald.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppTheme.primaryEmerald, size: 16),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.plusJakartaSans(color: Colors.white.withOpacity(0.4), fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1)),
              const SizedBox(height: 4),
              Text(value, style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHashCard(String hash) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.verified_user_rounded, color: AppTheme.primaryEmerald, size: 14),
              const SizedBox(width: 8),
              Text(
                'SHA-256 VERIFICATION HASH',
                style: GoogleFonts.plusJakartaSans(color: AppTheme.primaryEmerald, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.5),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            hash,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white.withOpacity(0.3),
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.warning.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.warning.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, color: AppTheme.warning, size: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'Show this QR code to your HKS worker when they arrive for collection. The code is cryptographically secured using SHA-256 and will be validated against your booking.',
              style: GoogleFonts.inter(color: Colors.white.withOpacity(0.6), fontSize: 12, fontWeight: FontWeight.w500, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
