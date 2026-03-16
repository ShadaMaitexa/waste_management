import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
      backgroundColor: AppTheme.bgSurface,
      appBar: AppBar(
        title: Text(
          'LOGISTICS TIMELINE',
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
            icon: const Icon(Icons.calendar_month_rounded, size: 20, color: AppTheme.primaryEmerald),
            onPressed: _selectDate,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            _buildCurrentWeekHeader(),
            const SizedBox(height: 32),
            _buildWeekCalendar(),
            const SizedBox(height: 40),
            _buildTodaysSchedule(),
            const SizedBox(height: 48),
            _buildWeeklyOverview(),
            const SizedBox(height: 40),
            _buildUpcomingShifts(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentWeekHeader() {
    final weekStart = _getWeekStart(_selectedDate);
    final weekEnd = weekStart.add(const Duration(days: 6));
    
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
              color: AppTheme.primaryEmerald.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.display_settings_rounded, color: AppTheme.primaryEmerald, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ACTIVE TIMEFRAME',
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.grey400,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  '${DateFormat('MMM d').format(weekStart)} — ${DateFormat('MMM d').format(weekEnd)}',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: AppTheme.grey900,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
            onPressed: _previousWeek,
            style: IconButton.styleFrom(backgroundColor: AppTheme.bgSurface),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            onPressed: _nextWeek,
            style: IconButton.styleFrom(backgroundColor: AppTheme.bgSurface),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekCalendar() {
    final weekStart = _getWeekStart(_selectedDate);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            'WEEKLY GRID',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: AppTheme.grey400,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(7, (index) {
            final day = weekStart.add(Duration(days: index));
            final isToday = _isSameDay(day, DateTime.now());
            final isSelected = _isSameDay(day, _selectedDate);
            
            return GestureDetector(
              onTap: () => setState(() => _selectedDate = day),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 44,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.bgDark : (isToday ? AppTheme.primaryEmerald.withValues(alpha: 0.1) : AppTheme.bgCanvas),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: isSelected ? AppTheme.smoothShadow : null,
                  border: Border.all(
                    color: isSelected ? AppTheme.bgDark : AppTheme.grey100,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      DateFormat('E').format(day)[0],
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: isSelected ? Colors.white.withValues(alpha: 0.5) : AppTheme.grey400,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${day.day}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: isSelected ? Colors.white : (isToday ? AppTheme.primaryEmerald : AppTheme.grey800),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildTodaysSchedule() {
    final todaySchedule = _weeklySchedule
        .where((shift) => _isSameDay(shift['date'], _selectedDate))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(
                'COLLECTION LOG • ',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.grey400,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            Text(
              DateFormat('EEEE, MMM d').format(_selectedDate).toUpperCase(),
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: AppTheme.primaryEmerald,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (todaySchedule.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(48),
            decoration: BoxDecoration(
              color: AppTheme.bgCanvas,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: AppTheme.grey100),
            ),
            child: Column(
              children: [
                Icon(Icons.offline_pin_rounded, color: AppTheme.grey200, size: 48),
                const SizedBox(height: 16),
                Text(
                  'NO ACTIVE SHIFTS',
                  style: GoogleFonts.plusJakartaSans(
                    color: AppTheme.grey400,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          )
        else
          ...todaySchedule.map((shift) => _buildShiftCard(shift)),
      ],
    );
  }

  Widget _buildShiftCard(Map<String, dynamic> shift) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.bgCanvas,
        borderRadius: BorderRadius.circular(36),
        boxShadow: AppTheme.cardShadow,
        border: Border.all(color: AppTheme.grey100),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryEmerald.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  shift['type'] == 'Morning' ? Icons.wb_twilight_rounded : Icons.nights_stay_rounded,
                  color: AppTheme.primaryEmerald,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${shift['start']} — ${shift['end']}',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        color: AppTheme.grey900,
                      ),
                    ),
                    Text(
                      '${shift['type']} Operational Shift',
                      style: GoogleFonts.inter(
                        color: AppTheme.grey500,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: shift['status'] == 'Confirmed' ? AppTheme.primaryEmerald.withValues(alpha: 0.1) : const Color(0xFFF59E0B).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  shift['status'].toString().toUpperCase(),
                  style: GoogleFonts.inter(
                    color: shift['status'] == 'Confirmed' ? AppTheme.primaryEmerald : const Color(0xFFF59E0B),
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _shiftMetric(Icons.hub_rounded, 'UNIT', 'Ward ${shift['ward']}')),
              Expanded(child: _shiftMetric(Icons.playlist_add_check_rounded, 'TARGET', '${shift['pickups']} POINTS')),
              Expanded(child: _shiftMetric(Icons.timelapse_rounded, 'WINDOW', '${shift['duration']}H')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _shiftMetric(IconData icon, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: AppTheme.grey400),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: AppTheme.grey400,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: AppTheme.grey800,
          ),
        ),
      ],
    );
  }



  Widget _buildWeeklyOverview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            'WEEKLY PERFORMANCE',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: AppTheme.grey400,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _overviewItem('Est. Hours', '40', Icons.timelapse_rounded, const Color(0xFF6366F1)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _overviewItem('Ops Days', '5', Icons.calendar_today_rounded, AppTheme.primaryEmerald),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _overviewItem('Target', '60', Icons.radar_rounded, const Color(0xFFF59E0B)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _overviewItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: AppTheme.bgCanvas,
        borderRadius: BorderRadius.circular(32),
        boxShadow: AppTheme.cardShadow,
        border: Border.all(color: AppTheme.grey100),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppTheme.grey900,
              letterSpacing: -0.5,
            ),
          ),
          Text(
            label.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: AppTheme.grey400,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingShifts() {
    final upcomingShifts = _weeklySchedule
        .where((shift) => shift['date'].isAfter(DateTime.now()))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            'PIPELINE QUEUE',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: AppTheme.grey400,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.bgCanvas,
            borderRadius: BorderRadius.circular(32),
            boxShadow: AppTheme.cardShadow,
            border: Border.all(color: AppTheme.grey100),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: 8),
            physics: const NeverScrollableScrollPhysics(),
            itemCount: upcomingShifts.length,
            separatorBuilder: (_, __) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Divider(height: 1, color: AppTheme.grey100),
            ),
            itemBuilder: (_, index) {
              final shift = upcomingShifts[index];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.bgSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.grey100),
                  ),
                  child: const Icon(Icons.sensor_door_rounded, color: AppTheme.grey400, size: 20),
                ),
                title: Text(
                  DateFormat('EEE, MMM d').format(shift['date']),
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: AppTheme.grey900,
                  ),
                ),
                subtitle: Text(
                  '${shift['start']} • Ward ${shift['ward']}',
                  style: GoogleFonts.inter(
                    color: AppTheme.grey500,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.bgSurface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.grey100),
                  ),
                  child: Text(
                    shift['status'].toString().toUpperCase(),
                    style: GoogleFonts.inter(
                      color: AppTheme.grey400,
                      fontWeight: FontWeight.w900,
                      fontSize: 9,
                      letterSpacing: 0.5,
                    ),
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
              primary: AppTheme.primaryEmerald,
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
