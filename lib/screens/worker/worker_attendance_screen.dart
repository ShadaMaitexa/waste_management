import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

  void _checkIn() {
    if (_isOnDuty) return;
    setState(() {
      _isOnDuty = true;
      _checkInTime = DateTime.now();
      _checkOutTime = null;
    });
    _showSuccessMessage('Checked in successfully!');
  }

  void _checkOut() {
    if (!_isOnDuty) return;
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
          'LOGISTICS REGISTRY',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800, 
            fontSize: 12,
            letterSpacing: 2,
            color: AppTheme.grey400,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded, size: 20),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: AppTheme.bgDark,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: const Icon(Icons.add_task_rounded, color: Colors.white, size: 20),
        label: Text(
          'LEAVE REQUEST',
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 12,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildDeploymentCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.bgCanvas,
        borderRadius: BorderRadius.circular(40),
        boxShadow: AppTheme.cardShadow,
        border: Border.all(color: AppTheme.grey100),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
            decoration: BoxDecoration(
              color: AppTheme.bgDark,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(39)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: (_isOnDuty ? AppTheme.primaryEmerald : AppTheme.grey800).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: (_isOnDuty ? AppTheme.primaryEmerald : AppTheme.grey800).withValues(alpha: 0.1)),
                  ),
                  child: Icon(
                    _isOnDuty ? Icons.radar_rounded : Icons.offline_bolt_rounded,
                    size: 48,
                    color: _isOnDuty ? AppTheme.primaryEmerald : AppTheme.grey400,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  _isOnDuty ? 'ACTIVE ON FIELD' : 'TERMINAL STANDBY',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  DateFormat('EEEE, MMMM d').format(DateTime.now()).toUpperCase(),
                  style: GoogleFonts.inter(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                    letterSpacing: 1.5,
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
                    Expanded(child: Container(height: 1, color: AppTheme.grey100, margin: const EdgeInsets.symmetric(horizontal: 16))),
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: Text(
                      _isOnDuty ? 'TERMINATE SESSION' : 'INITIALIZE SHIFT',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                        fontSize: 13,
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
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                color: AppTheme.grey400,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          time != null ? DateFormat('h:mm a').format(time) : '--:--',
          style: GoogleFonts.plusJakartaSans(
            color: time != null ? AppTheme.grey900 : AppTheme.grey300,
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
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
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppTheme.grey400,
              letterSpacing: 1.2,
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
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.bgCanvas,
        borderRadius: BorderRadius.circular(32),
        boxShadow: AppTheme.cardShadow,
        border: Border.all(color: AppTheme.grey100),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: AppTheme.grey900,
              letterSpacing: -1.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            label.toUpperCase(),
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 8,
              color: AppTheme.grey400,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
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
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppTheme.grey400,
              letterSpacing: 1.2,
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
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.bgCanvas,
                borderRadius: BorderRadius.circular(32),
                boxShadow: AppTheme.cardShadow,
                border: Border.all(color: AppTheme.grey100),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isPresent ? AppTheme.primaryEmerald.withValues(alpha: 0.1) : const Color(0xFFF43F5E).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      isPresent ? Icons.verified_user_rounded : Icons.report_gmailerrorred_rounded,
                      color: isPresent ? AppTheme.primaryEmerald : const Color(0xFFF43F5E),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('MMM d, yyyy').format(record['date']).toUpperCase(),
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            color: AppTheme.grey900,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isPresent 
                              ? '${record['checkIn']} — ${record['checkOut']}'
                              : 'OPERATIONAL LAPSE',
                          style: GoogleFonts.inter(
                            color: AppTheme.grey400,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isPresent)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.bgSurface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.grey100),
                      ),
                      child: Text(
                        '${record['hours']}H',
                        style: GoogleFonts.plusJakartaSans(
                          color: AppTheme.grey900,
                          fontWeight: FontWeight.w900,
                          fontSize: 10,
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
