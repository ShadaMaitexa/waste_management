import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/pickup_slot.dart';
import '../../services/pickup_service.dart';
import '../../theme/app_theme.dart';

class ManagePickupSlotsScreen extends StatefulWidget {
  const ManagePickupSlotsScreen({super.key});

  @override
  State<ManagePickupSlotsScreen> createState() => _ManagePickupSlotsScreenState();
}

class _ManagePickupSlotsScreenState extends State<ManagePickupSlotsScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PickupService>(context, listen: false).fetchAvailableSlots();
    });
  }

  void _showAddSlotDialog() {
    TimeOfDay startTime = const TimeOfDay(hour: 8, minute: 0);
    TimeOfDay endTime = const TimeOfDay(hour: 10, minute: 0);
    int capacity = 10;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(36))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 32,
            top: 20,
            left: 32,
            right: 32,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(color: AppTheme.grey200, borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Create Time Slot',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 26, 
                  fontWeight: FontWeight.w900, 
                  color: AppTheme.grey900, 
                  letterSpacing: -1.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Set how many houses can book this slot.', 
                style: GoogleFonts.inter(color: AppTheme.grey500, fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 36),
              
              _buildTimeSelector('START TIME', startTime, (picked) => setModalState(() => startTime = picked)),
              const SizedBox(height: 20),
              _buildTimeSelector('END TIME', endTime, (picked) => setModalState(() => endTime = picked)),
              
              const SizedBox(height: 32),
              Text(
                'MAXIMUM HOUSEHOLDS', 
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 8, 
                  fontWeight: FontWeight.w900, 
                  color: AppTheme.grey400, 
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.grey50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.grey100),
                        boxShadow: AppTheme.cardShadow,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.remove_rounded, color: AppTheme.grey700, size: 20),
                        onPressed: capacity > 1 ? () => setModalState(() => capacity--) : null,
                      ),
                    ),
                    Text(
                      '$capacity Households', 
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16, 
                        fontWeight: FontWeight.w900, 
                        color: AppTheme.grey900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.primaryEmerald,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryEmerald.withValues(alpha: 0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
                        onPressed: () => setModalState(() => capacity++),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final newSlot = PickupSlot(
                      id: 'slot_${DateTime.now().millisecondsSinceEpoch}',
                      date: _selectedDate,
                      startTime: startTime,
                      endTime: endTime,
                      capacity: capacity,
                    );
                    Provider.of<PickupService>(context, listen: false).createPickupSlot(newSlot);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryEmerald,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 22),
                    elevation: 8,
                    shadowColor: AppTheme.primaryEmerald.withValues(alpha: 0.3),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  child: Text(
                    'CREATE SLOT',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeSelector(String label, TimeOfDay time, Function(TimeOfDay) onPicked) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label, 
          style: GoogleFonts.plusJakartaSans(
            fontSize: 8, 
            fontWeight: FontWeight.w900, 
            color: AppTheme.grey400, 
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 10),
        InkWell(
          onTap: () async {
            final picked = await showTimePicker(context: context, initialTime: time);
            if (picked != null) onPicked(picked);
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              color: AppTheme.grey50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  time.format(context), 
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800, 
                    fontSize: 16, 
                    color: AppTheme.grey900,
                  ),
                ),
                Icon(Icons.access_time_filled_rounded, color: AppTheme.primaryEmerald, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgSurface,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: Container(
          padding: const EdgeInsets.only(top: 20),
          decoration: const BoxDecoration(
            color: AppTheme.bgSurface,
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            centerTitle: true,
            title: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Manage Pickup Slots',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w900, 
                  color: AppTheme.grey900, 
                  fontSize: 22,
                  letterSpacing: -1.2,
                ),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.grey900, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.grey100),
                  boxShadow: AppTheme.cardShadow,
                ),
                child: IconButton(
                  icon: Icon(Icons.analytics_outlined, color: AppTheme.grey900, size: 20),
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          _buildCalendarStrip(),
          Expanded(
            child: _buildSlotsList(),
          ),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryEmerald.withValues(alpha: 0.3),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: _showAddSlotDialog,
          backgroundColor: AppTheme.primaryEmerald,
          elevation: 0,
          highlightElevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          icon: const Icon(Icons.add_task_rounded, color: Colors.white, size: 20),
          label: Text(
            'NEW SLOT', 
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white, 
              fontWeight: FontWeight.w900, 
              letterSpacing: 2,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarStrip() {
    return Container(
      height: 130,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppTheme.grey100, width: 1.5)),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        itemCount: 14,
        itemBuilder: (context, index) {
          final date = DateTime.now().add(Duration(days: index));
          final isSelected = DateUtils.isSameDay(date, _selectedDate);
          final isToday = DateUtils.isSameDay(date, DateTime.now());
          
          return GestureDetector(
            onTap: () => setState(() => _selectedDate = date),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              width: 72,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryEmerald : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isSelected ? AppTheme.primaryEmerald : AppTheme.grey100,
                  width: 1.5,
                ),
                boxShadow: isSelected 
                  ? [BoxShadow(color: AppTheme.primaryEmerald.withValues(alpha: 0.2), blurRadius: 16, offset: const Offset(0, 8))] 
                  : [],
              ),
              child: Stack(
                children: [
                  if (isToday && !isSelected)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(color: AppTheme.primaryEmerald, shape: BoxShape.circle),
                      ),
                    ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('EEE').format(date).toUpperCase(),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                            color: isSelected ? Colors.white.withValues(alpha: 0.7) : AppTheme.grey400,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          DateFormat('d').format(date),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: isSelected ? Colors.white : AppTheme.grey900,
                            letterSpacing: -1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSlotsList() {
    return Consumer<PickupService>(
      builder: (context, pickupService, child) {
        final slots = pickupService.availableSlots
            .where((s) => DateUtils.isSameDay(s.date, _selectedDate))
            .toList();

        if (slots.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryEmerald.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Icon(Icons.calendar_today_rounded, size: 64, color: AppTheme.primaryEmerald.withValues(alpha: 0.2)),
                ),
                const SizedBox(height: 32),
                Text(
                  'Schedule is empty', 
                  style: GoogleFonts.plusJakartaSans(
                    color: AppTheme.grey900, 
                    fontWeight: FontWeight.w900, 
                    fontSize: 22,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'No operational slots defined for this date.', 
                  style: GoogleFonts.inter(color: AppTheme.grey400, fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
          physics: const BouncingScrollPhysics(),
          itemCount: slots.length,
          itemBuilder: (context, index) {
            final slot = slots[index];
            final utilPercent = slot.bookedCount / slot.capacity;
            
            return Container(
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: AppTheme.cardShadow,
                border: Border.all(color: AppTheme.grey100, width: 1.5),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: IntrinsicHeight(
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        color: utilPercent > 0.8 ? AppTheme.error : AppTheme.primaryEmerald,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(28),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppTheme.grey50,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(Icons.access_time_filled_rounded, 
                                  color: utilPercent > 0.8 ? AppTheme.error : AppTheme.primaryEmerald, 
                                  size: 24
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      slot.formatTime(context),
                                      style: GoogleFonts.plusJakartaSans(
                                        fontWeight: FontWeight.w900, 
                                        fontSize: 18, 
                                        color: AppTheme.grey900, 
                                        letterSpacing: -1,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Text(
                                          'SLOT FULLNESS: ', 
                                          style: GoogleFonts.plusJakartaSans(
                                            color: AppTheme.grey400, 
                                            fontSize: 8, 
                                            fontWeight: FontWeight.w900, 
                                            letterSpacing: 2,
                                          ),
                                        ),
                                        Text(
                                          '${(utilPercent * 100).toInt()}%', 
                                          style: GoogleFonts.plusJakartaSans(
                                            color: utilPercent > 0.8 ? AppTheme.error : AppTheme.primaryEmerald, 
                                            fontSize: 8, 
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          '${slot.bookedCount}/${slot.capacity} UN', 
                                          style: GoogleFonts.inter(
                                            color: AppTheme.grey900, 
                                            fontSize: 11, 
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 14),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: LinearProgressIndicator(
                                        value: utilPercent,
                                        backgroundColor: AppTheme.grey100,
                                        color: utilPercent > 0.8 ? AppTheme.error : AppTheme.primaryEmerald,
                                        minHeight: 6,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.grey300, size: 22),
                                onPressed: () => pickupService.deletePickupSlot(slot.id),
                                splashRadius: 24,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
