import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';

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
    setState(() {
      _isOnDuty = true;
      _checkInTime = DateTime.now();
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Checked in successfully!'),
        backgroundColor: AppTheme.success,
      ),
    );
  }

  void _checkOut() {
    setState(() {
      _isOnDuty = false;
      _checkOutTime = DateTime.now();
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Checked out successfully!'),
        backgroundColor: AppTheme.success,
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAttendanceCard(),
            const SizedBox(height: AppTheme.spacingL),
            _buildTodayStats(),
            const SizedBox(height: AppTheme.spacingL),
            _buildAttendanceHistory(),
          ],
        ),
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildAttendanceCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              decoration: BoxDecoration(
                color: _isOnDuty ? AppTheme.success.withOpacity(0.1) : AppTheme.grey100,
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
              ),
              child: Row(
                children: [
                  Icon(
                    _isOnDuty ? Icons.check_circle : Icons.schedule,
                    color: _isOnDuty ? AppTheme.success : AppTheme.grey600,
                    size: 32,
                  ),
                  const SizedBox(width: AppTheme.spacingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isOnDuty ? 'Currently On Duty' : 'Not Checked In',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _isOnDuty ? AppTheme.success : AppTheme.grey700,
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacingXS),
                        Text(
                          _isOnDuty 
                              ? 'Started at ${_checkInTime != null ? DateFormat('h:mm a').format(_checkInTime!) : 'Unknown'}'
                              : 'Click check-in to start your shift',
                          style: TextStyle(
                            color: AppTheme.grey600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _isOnDuty,
                    onChanged: (value) {
                      if (value) {
                        _checkIn();
                      } else {
                        _checkOut();
                      }
                    },
                    activeColor: AppTheme.success,
                  ),
                ],
              ),
            ),
            if (_checkInTime != null) ...[
              const SizedBox(height: AppTheme.spacingM),
              Row(
                children: [
                  _timeInfo('Check In', _checkInTime!),
                  const SizedBox(width: AppTheme.spacingL),
                  if (_checkOutTime != null)
                    _timeInfo('Check Out', _checkOutTime!)
                  else
                    const Expanded(
                      child: Text(
                        'Still working...',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppTheme.warning,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _timeInfo(String label, DateTime time) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppTheme.grey600,
              fontSize: 12,
            ),
          ),
          Text(
            DateFormat('h:mm a').format(time),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Today\'s Summary',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppTheme.spacingM),
        Row(
          children: [
            Expanded(
              child: _statCard(
                'Hours Worked',
                '7.5',
                Icons.access_time,
                AppTheme.info,
              ),
            ),
            const SizedBox(width: AppTheme.spacingM),
            Expanded(
              child: _statCard(
                'Pickups Completed',
                '12',
                Icons.recycling,
                AppTheme.success,
              ),
            ),
            const SizedBox(width: AppTheme.spacingM),
            Expanded(
              child: _statCard(
                'Performance',
                '98%',
                Icons.trending_up,
                AppTheme.primaryGreen,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: AppTheme.spacingS),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: AppTheme.spacingXS),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.grey600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Attendance',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppTheme.spacingM),
        Card(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _attendanceHistory.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, index) {
              final record = _attendanceHistory[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: record['status'] == 'Present' 
                      ? AppTheme.success.withOpacity(0.1)
                      : AppTheme.error.withOpacity(0.1),
                  child: Icon(
                    record['status'] == 'Present' ? Icons.check : Icons.close,
                    color: record['status'] == 'Present' ? AppTheme.success : AppTheme.error,
                  ),
                ),
                title: Text(DateFormat('EEEE, MMM d').format(record['date'])),
                subtitle: Text(
                  '${record['checkIn']} - ${record['checkOut']} (${record['hours']} hours)',
                ),
                trailing: Text(
                  record['status'],
                  style: TextStyle(
                    color: record['status'] == 'Present' ? AppTheme.success : AppTheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Quick Actions'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text('Request Leave'),
                  onTap: () {
                    Navigator.pop(context);
                    _showLeaveRequestDialog();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.report_problem),
                  title: const Text('Report Issue'),
                  onTap: () {
                    Navigator.pop(context);
                    _showIssueReportDialog();
                  },
                ),
              ],
            ),
          ),
        );
      },
      backgroundColor: AppTheme.primaryGreen,
      foregroundColor: Colors.white,
      child: const Icon(Icons.more_horiz),
    );
  }

  void _showLeaveRequestDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Request Leave'),
        content: const Text('Leave request feature coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showIssueReportDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Report Issue'),
        content: const Text('Issue reporting feature coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getMockAttendanceHistory() {
    final today = DateTime.now();
    return List.generate(7, (index) {
      final date = today.subtract(Duration(days: index + 1));
      return {
        'date': date,
        'checkIn': '08:00 AM',
        'checkOut': index == 0 ? 'Not yet' : '05:30 PM',
        'hours': index == 0 ? 'In progress' : '8.5',
        'status': 'Present',
      };
    }).reversed.toList();
  }
}
