import 'package:flutter/material.dart';
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
      appBar: AppBar(
        title: const Text('Attendance'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              // Show filter options
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          children: [
            _buildMainAttendanceCard(),
            const SizedBox(height: AppTheme.spacingL),
            _buildQuickStats(),
            const SizedBox(height: AppTheme.spacingL),
            _buildHistorySection(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Request leave or other actions
        },
        backgroundColor: AppTheme.primaryGreen,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildMainAttendanceCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingL),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _isOnDuty 
                    ? [AppTheme.success, AppTheme.success.withOpacity(0.8)]
                    : [AppTheme.grey700, AppTheme.grey600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(AppTheme.radiusL)),
            ),
            child: Column(
              children: [
                Icon(
                  _isOnDuty ? Icons.check_circle_outline : Icons.access_time,
                  size: 48,
                  color: Colors.white,
                ),
                const SizedBox(height: AppTheme.spacingM),
                Text(
                  _isOnDuty ? 'YOU ARE ON DUTY' : 'NOT CHECKED IN',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingS),
                Text(
                  DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now()),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacingL),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildTimeDisplay('Check In', _checkInTime),
                    Container(height: 40, width: 1, color: AppTheme.grey300),
                    _buildTimeDisplay('Check Out', _checkOutTime),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingL),
                _buildActionSlider(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeDisplay(String label, DateTime? time) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppTheme.grey500,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          time != null ? DateFormat('h:mm a').format(time) : '--:--',
          style: TextStyle(
            color: AppTheme.grey900,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildActionSlider() {
    return GestureDetector(
      onTap: _isOnDuty ? _checkOut : _checkIn,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          color: _isOnDuty ? Colors.red.shade50 : AppTheme.primaryGreen.withOpacity(0.1),
          border: Border.all(
            color: _isOnDuty ? Colors.red : AppTheme.primaryGreen,
            width: 1.5
          ),
        ),
        child: Center(
          child: Text(
            _isOnDuty ? 'Tap to Check Out' : 'Tap to Check In',
            style: TextStyle(
              color: _isOnDuty ? Colors.red : AppTheme.primaryGreen,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(child: _buildStatItem('Present', '22', Colors.green)),
        const SizedBox(width: AppTheme.spacingM),
        Expanded(child: _buildStatItem('Absent', '2', Colors.red)),
        const SizedBox(width: AppTheme.spacingM),
        Expanded(child: _buildStatItem('Late', '1', Colors.orange)),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent History',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.grey900,
          ),
        ),
        const SizedBox(height: AppTheme.spacingM),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _attendanceHistory.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppTheme.spacingS),
          itemBuilder: (_, index) {
            final record = _attendanceHistory[index];
            return _buildHistoryCard(record);
          },
        ),
      ],
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> record) {
    final isPresent = record['status'] == 'Present';
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        border: Border.all(color: AppTheme.grey200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isPresent ? Colors.green.shade50 : Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isPresent ? Icons.check : Icons.close,
              color: isPresent ? Colors.green : Colors.red,
              size: 20,
            ),
          ),
          const SizedBox(width: AppTheme.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('MMM d, yyyy').format(record['date']),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  isPresent 
                      ? '${record['checkIn']} - ${record['checkOut']}'
                      : 'Absent',
                  style: TextStyle(
                    color: AppTheme.grey600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          if (isPresent)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${record['hours']}h',
                style: TextStyle(
                  color: Colors.blue.shade800,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
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
