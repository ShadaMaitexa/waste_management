import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import '../../theme/app_theme.dart';
import 'package:intl/intl.dart';

class WorkerAttendanceScreen extends StatefulWidget {
  const WorkerAttendanceScreen({super.key});

  @override
  State<WorkerAttendanceScreen> createState() => _WorkerAttendanceScreenState();
}

class _WorkerAttendanceScreenState extends State<WorkerAttendanceScreen> {
  bool _isOnDuty = false;
  DateTime? _checkInTime;
  DateTime? _checkOutTime;
  final List<Map<String, dynamic>> _attendanceHistory = [];

  @override
  void initState() {
    super.initState();
    _attendanceHistory.addAll(_getMockAttendanceHistory());
  }

  Future<void> _checkIn() async {
    if (_isOnDuty) return;

    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera, preferredCameraDevice: CameraDevice.front);
    
    if (image == null) {
      _showSuccessMessage('Selfie with PPE is required for check-in');
      return;
    }

    try {
      final locPrefs = await Geolocator.checkPermission();
      if (locPrefs == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }
      await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      // location logic here pos.latitude, pos.longitude
    } catch (e) {
      // Handle gracefully
    }

    setState(() {
      _isOnDuty = true;
      _checkInTime = DateTime.now();
      _checkOutTime = null;
    });
    _showSuccessMessage('Checked in successfully with PPE verification!');
  }

  Future<void> _checkOut() async {
    if (!_isOnDuty) return;
    
    try {
      await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      // store check-out location
    } catch (e) {
      // Handle gracefully
    }

    setState(() {
      _isOnDuty = false;
      _checkOutTime = DateTime.now();
    });
    _showSuccessMessage('Checked out successfully!');
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgSurface,
      appBar: AppBar(
        title: Text(
          'Logistics Registry',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w900, 
            fontSize: 18,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppTheme.bgDark,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.slateGradient,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded, size: 20, color: Colors.white),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            _buildDeploymentCard(),
            const SizedBox(height: 32),
            _buildPerformanceSummary(),
            const SizedBox(height: 32),
            _buildLogHistory(),
            const SizedBox(height: 40),
          ],
        ),
      ),
      floatingActionButton: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: FloatingActionButton.extended(
          onPressed: () {},
          backgroundColor: AppTheme.bgDark,
          elevation: 12,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          icon: const Icon(Icons.add_task_rounded, color: AppTheme.primaryEmerald, size: 22),
          label: Text(
            'LEAVE REQUEST',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 12,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeploymentCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: AppTheme.smoothShadow,
        border: Border.all(color: AppTheme.grey200.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 24),
            decoration: BoxDecoration(
              gradient: AppTheme.slateGradient,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(39)),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.bgDark.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 2),
                  ),
                  child: Icon(
                    _isOnDuty ? Icons.radar_rounded : Icons.offline_bolt_rounded,
                    size: 56,
                    color: _isOnDuty ? AppTheme.primaryEmerald : Colors.white.withValues(alpha: 0.4),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  _isOnDuty ? 'ACTIVE ON FIELD' : 'TERMINAL STANDBY',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    DateFormat('EEEE, MMMM d').format(DateTime.now()).toUpperCase(),
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                Row(
                  children: [
                    _timeNode('DEPLOYMENT', _checkInTime, Icons.play_circle_filled_rounded, AppTheme.primaryEmerald),
                    Expanded(
                      child: Container(
                        height: 2,
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.primaryEmerald.withValues(alpha: 0.2),
                              const Color(0xFFF43F5E).withValues(alpha: 0.2),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                    _timeNode('RETRACTION', _checkOutTime, Icons.stop_circle_rounded, const Color(0xFFF43F5E)),
                  ],
                ),
                const SizedBox(height: 48),
                SizedBox(
                  height: 64,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isOnDuty ? _checkOut : _checkIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isOnDuty ? AppTheme.bgDark : AppTheme.primaryEmerald,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      elevation: 12,
                      shadowColor: (_isOnDuty ? AppTheme.bgDark : AppTheme.primaryEmerald).withValues(alpha: 0.4),
                      padding: EdgeInsets.zero,
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: _isOnDuty ? AppTheme.slateGradient : AppTheme.emeraldGradient,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        child: Text(
                          _isOnDuty ? 'END SHIFT' : 'INITIALIZE SHIFT',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _timeNode(String label, DateTime? time, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 12, color: color),
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                color: AppTheme.grey400,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          time != null ? DateFormat('h:mm a').format(time) : '--:--',
          style: GoogleFonts.plusJakartaSans(
            color: time != null ? AppTheme.grey900 : AppTheme.grey300,
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: -1,
          ),
        ),
      ],
    );
  }



  Widget _buildPerformanceSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            'QUARTERLY METRICS',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: AppTheme.grey400,
              letterSpacing: 2,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _metricTile('Compliance', '22', const Color(0xFF10B981))),
            const SizedBox(width: 12),
            Expanded(child: _metricTile('Incident Free', '2', const Color(0xFFF43F5E))),
            const SizedBox(width: 12),
            Expanded(child: _metricTile('Excellence', '1', const Color(0xFFF59E0B))),
          ],
        ),
      ],
    );
  }

  Widget _metricTile(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(36),
        boxShadow: AppTheme.smoothShadow,
        border: Border.all(color: AppTheme.grey200.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: color,
                letterSpacing: -1,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            label.toUpperCase(),
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 9,
              color: AppTheme.grey400,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            'LOGBOOK ARCHIVE',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: AppTheme.grey400,
              letterSpacing: 2,
            ),
          ),
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _attendanceHistory.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, index) {
            final record = _attendanceHistory[index];
            final isPresent = record['status'] == 'Present';
            
            return Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40),
                boxShadow: AppTheme.smoothShadow,
                border: Border.all(color: AppTheme.grey200.withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isPresent 
                        ? AppTheme.primaryEmerald.withValues(alpha: 0.1) 
                        : const Color(0xFFF43F5E).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      isPresent ? Icons.verified_user_rounded : Icons.report_gmailerrorred_rounded,
                      color: isPresent ? AppTheme.primaryEmerald : const Color(0xFFF43F5E),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('MMM d, yyyy').format(record['date']).toUpperCase(),
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                            color: AppTheme.grey900,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          isPresent 
                              ? '${record['checkIn']} — ${record['checkOut']}'
                              : 'OPERATIONAL LAPSE',
                          style: GoogleFonts.inter(
                            color: isPresent ? AppTheme.grey400 : const Color(0xFFF43F5E).withValues(alpha: 0.6),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isPresent)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.bgSurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.grey100),
                      ),
                      child: Text(
                        '${record['hours']}H',
                        style: GoogleFonts.plusJakartaSans(
                          color: AppTheme.grey900,
                          fontWeight: FontWeight.w900,
                          fontSize: 11,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _getMockAttendanceHistory() {
    final today = DateTime.now();
    return List.generate(5, (index) {
      final date = today.subtract(Duration(days: index + 1));
      return {
        'date': date,
        'checkIn': '08:00 AM',
        'checkOut': '05:30 PM',
        'hours': '9.5',
        'status': index == 2 ? 'Absent' : 'Present',
      };
    });
  }
}
