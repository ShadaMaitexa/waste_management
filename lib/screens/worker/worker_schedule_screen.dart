import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';

class WorkerScheduleScreen extends StatefulWidget {
  const WorkerScheduleScreen({super.key});

  @override
  State<WorkerScheduleScreen> createState() => _WorkerScheduleScreenState();
}

class _WorkerScheduleScreenState extends State<WorkerScheduleScreen> {
  DateTime _selectedDate = DateTime.now();
  final List<Map<String, dynamic>> _weeklySchedule = [];

  @override
  void initState() {
    super.initState();
    _weeklySchedule.addAll(_getMockWeeklySchedule());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Schedule'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _selectDate,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCurrentWeekHeader(),
            const SizedBox(height: AppTheme.spacingM),
            _buildWeekCalendar(),
            const SizedBox(height: AppTheme.spacingL),
            _buildTodaysSchedule(),
            const SizedBox(height: AppTheme.spacingL),
            _buildWeeklyOverview(),
            const SizedBox(height: AppTheme.spacingL),
            _buildUpcomingShifts(),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentWeekHeader() {
    final weekStart = _getWeekStart(_selectedDate);
    final weekEnd = weekStart.add(const Duration(days: 6));
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Row(
          children: [
            Icon(Icons.calendar_view_week, color: AppTheme.primaryGreen, size: 32),
            const SizedBox(width: AppTheme.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Week of ${DateFormat('MMM d').format(weekStart)}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${DateFormat('MMM d').format(weekStart)} - ${DateFormat('MMM d').format(weekEnd)}',
                    style: TextStyle(color: AppTheme.grey600),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: _previousWeek,
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: _nextWeek,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekCalendar() {
    final weekStart = _getWeekStart(_selectedDate);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weekly Schedule',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTheme.spacingM),
            Row(
              children: List.generate(7, (index) {
                final day = weekStart.add(Duration(days: index));
                final isToday = _isSameDay(day, DateTime.now());
                final isSelected = _isSameDay(day, _selectedDate);
                
                return Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _selectedDate = day),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingS),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? AppTheme.primaryGreen
                            : isToday 
                                ? AppTheme.secondaryGreen.withOpacity(0.2)
                                : null,
                        borderRadius: BorderRadius.circular(AppTheme.radiusS),
                      ),
                      child: Column(
                        children: [
                          Text(
                            DateFormat('EEE').format(day),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isSelected 
                                  ? Colors.white 
                                  : isToday 
                                      ? AppTheme.primaryGreen
                                      : AppTheme.grey700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${day.day}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isSelected 
                                  ? Colors.white 
                                  : isToday 
                                      ? AppTheme.primaryGreen
                                      : AppTheme.grey900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodaysSchedule() {
    final todaySchedule = _weeklySchedule
        .where((shift) => _isSameDay(shift['date'], _selectedDate))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Schedule for ${DateFormat('EEEE, MMM d').format(_selectedDate)}',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppTheme.spacingM),
        if (todaySchedule.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              child: Column(
                children: [
                  Icon(
                    Icons.schedule,
                    color: AppTheme.grey400,
                    size: 48,
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                  Text(
                    'No shifts scheduled',
                    style: TextStyle(
                      color: AppTheme.grey600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...todaySchedule.map((shift) => _buildShiftCard(shift)),
      ],
    );
  }

  Widget _buildShiftCard(Map<String, dynamic> shift) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: shift['type'] == 'Morning' 
                        ? AppTheme.info.withOpacity(0.1)
                        : shift['type'] == 'Evening'
                            ? AppTheme.warning.withOpacity(0.1)
                            : AppTheme.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusS),
                  ),
                  child: Icon(
                    shift['type'] == 'Morning' 
                        ? Icons.wb_sunny
                        : shift['type'] == 'Evening'
                            ? Icons.nights_stay
                            : Icons.schedule,
                    color: shift['type'] == 'Morning' 
                        ? AppTheme.info
                        : shift['type'] == 'Evening'
                            ? AppTheme.warning
                            : AppTheme.primaryGreen,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${shift['start']} - ${shift['end']}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        shift['type'],
                        style: TextStyle(
                          color: AppTheme.grey600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingS,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: shift['status'] == 'Confirmed' 
                        ? AppTheme.success.withOpacity(0.1)
                        : AppTheme.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusS),
                  ),
                  child: Text(
                    shift['status'],
                    style: TextStyle(
                      color: shift['status'] == 'Confirmed' 
                          ? AppTheme.success 
                          : AppTheme.warning,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingM),
            _detailRow(Icons.location_on, 'Ward ${shift['ward']}'),
            const SizedBox(height: AppTheme.spacingXS),
            _detailRow(Icons.people, '${shift['pickups']} pickups estimated'),
            const SizedBox(height: AppTheme.spacingXS),
            _detailRow(Icons.access_time, '${shift['duration']} hours'),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.grey600),
        const SizedBox(width: AppTheme.spacingS),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: AppTheme.grey700),
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyOverview() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This Week Overview',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTheme.spacingM),
            Row(
              children: [
                Expanded(
                  child: _overviewStat('Total Hours', '40', Icons.access_time, AppTheme.info),
                ),
                const SizedBox(width: AppTheme.spacingM),
                Expanded(
                  child: _overviewStat('Working Days', '5', Icons.calendar_today, AppTheme.success),
                ),
                const SizedBox(width: AppTheme.spacingM),
                Expanded(
                  child: _overviewStat('Est. Pickups', '60', Icons.recycling, AppTheme.primaryGreen),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _overviewStat(String title, String value, IconData icon, Color color) {
    return Column(
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
    );
  }

  Widget _buildUpcomingShifts() {
    final upcomingShifts = _weeklySchedule
        .where((shift) => shift['date'].isAfter(DateTime.now()))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upcoming Shifts',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppTheme.spacingM),
        Card(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: upcomingShifts.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, index) {
              final shift = upcomingShifts[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.primaryGreen.withOpacity(0.1),
                  child: Icon(Icons.schedule, color: AppTheme.primaryGreen),
                ),
                title: Text(
                  DateFormat('EEE, MMM d').format(shift['date']),
                ),
                subtitle: Text('${shift['start']} - ${shift['end']} • Ward ${shift['ward']}'),
                trailing: Text(
                  shift['status'],
                  style: TextStyle(
                    color: shift['status'] == 'Confirmed' ? AppTheme.success : AppTheme.warning,
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

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 60)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryGreen,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _previousWeek() {
    setState(() {
      _selectedDate = _selectedDate.subtract(const Duration(days: 7));
    });
  }

  void _nextWeek() {
    setState(() {
      _selectedDate = _selectedDate.add(const Duration(days: 7));
    });
  }

  DateTime _getWeekStart(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  List<Map<String, dynamic>> _getMockWeeklySchedule() {
    final today = DateTime.now();
    final weekStart = _getWeekStart(today);
    
    return [
      {
        'date': weekStart.add(const Duration(days: 0)),
        'start': '08:00 AM',
        'end': '05:30 PM',
        'type': 'Morning',
        'ward': '15',
        'pickups': 12,
        'duration': 8.5,
        'status': 'Confirmed',
      },
      {
        'date': weekStart.add(const Duration(days: 1)),
        'start': '08:00 AM',
        'end': '05:30 PM',
        'type': 'Morning',
        'ward': '12',
        'pickups': 10,
        'duration': 8.5,
        'status': 'Confirmed',
      },
      {
        'date': weekStart.add(const Duration(days: 2)),
        'start': '08:00 AM',
        'end': '05:30 PM',
        'type': 'Morning',
        'ward': '8',
        'pickups': 15,
        'duration': 8.5,
        'status': 'Confirmed',
      },
      {
        'date': weekStart.add(const Duration(days: 3)),
        'start': '10:00 AM',
        'end': '06:00 PM',
        'type': 'Day',
        'ward': '15',
        'pickups': 8,
        'duration': 8,
        'status': 'Pending',
      },
      {
        'date': weekStart.add(const Duration(days: 4)),
        'start': '08:00 AM',
        'end': '05:30 PM',
        'type': 'Morning',
        'ward': '12',
        'pickups': 14,
        'duration': 8.5,
        'status': 'Confirmed',
      },
    ];
  }
}
