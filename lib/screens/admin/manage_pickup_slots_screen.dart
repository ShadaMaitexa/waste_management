import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
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
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 32,
            top: 32,
            left: 32,
            right: 32,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Define Pickup Slot',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppTheme.grey900, letterSpacing: -0.5),
              ),
              const Text('Set operational capacity for this time window.', 
                style: TextStyle(color: AppTheme.grey400, fontSize: 14)),
              const SizedBox(height: 32),
              
              _buildTimeSelector('START TIME', startTime, (picked) => setModalState(() => startTime = picked)),
              const SizedBox(height: 20),
              _buildTimeSelector('END TIME', endTime, (picked) => setModalState(() => endTime = picked)),
              
              const SizedBox(height: 32),
              const Text('UNIT CAPACITY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppTheme.grey400, letterSpacing: 1)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.grey50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.grey200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_rounded, color: AppTheme.grey700),
                      onPressed: capacity > 1 ? () => setModalState(() => capacity--) : null,
                    ),
                    Text('$capacity Households', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.grey900)),
                    IconButton(
                      icon: const Icon(Icons.add_rounded, color: AppTheme.primaryEmerald),
                      onPressed: () => setModalState(() => capacity++),
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
                  child: const Text('INITIALIZE SLOT'),
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
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppTheme.grey400, letterSpacing: 1)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final picked = await showTimePicker(context: context, initialTime: time);
            if (picked != null) onPicked(picked);
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.grey200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(time.format(context), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppTheme.grey800)),
                const Icon(Icons.access_time_filled_rounded, color: AppTheme.grey400, size: 20),
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
      backgroundColor: AppTheme.grey50,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text(
              'Operational Scheduling',
              style: TextStyle(fontWeight: FontWeight.w900, color: AppTheme.grey900, fontSize: 20),
            ),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.grey700, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.info_outline_rounded, color: AppTheme.grey400),
                onPressed: () {},
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
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryEmerald.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: _showAddSlotDialog,
          backgroundColor: AppTheme.primaryEmerald,
          elevation: 0,
          highlightElevation: 0,
          icon: const Icon(Icons.add_task_rounded, color: Colors.white),
          label: const Text('New Slot', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        ),
      ),
    );
  }

  Widget _buildCalendarStrip() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppTheme.grey100, width: 1.5)),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
              width: 68,
              margin: const EdgeInsets.only(right: 14),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryEmerald : Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isSelected ? AppTheme.primaryEmerald : AppTheme.grey200.withValues(alpha: 0.8),
                  width: 1.5,
                ),
                boxShadow: isSelected 
                  ? [BoxShadow(color: AppTheme.primaryEmerald.withValues(alpha: 0.25), blurRadius: 12, offset: const Offset(0, 6))] 
                  : [],
              ),
              child: Stack(
                children: [
                  if (isToday && !isSelected)
                    Positioned(
                      top: 6,
                      right: 6,
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
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: isSelected ? Colors.white.withValues(alpha: 0.85) : AppTheme.grey400,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('d').format(date),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: isSelected ? Colors.white : AppTheme.grey900,
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
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppTheme.grey100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.calendar_today_rounded, size: 48, color: AppTheme.grey300),
                ),
                const SizedBox(height: 24),
                const Text('Schedule is empty', style: TextStyle(color: AppTheme.grey900, fontWeight: FontWeight.w800, fontSize: 18)),
                const SizedBox(height: 8),
                const Text('No operational slots defined for this date.', style: TextStyle(color: AppTheme.grey400, fontSize: 14)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(24),
          physics: const BouncingScrollPhysics(),
          itemCount: slots.length,
          itemBuilder: (context, index) {
            final slot = slots[index];
            final utilPercent = slot.bookedCount / slot.capacity;
            
            return Container(
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
                border: Border.all(color: AppTheme.grey100, width: 1),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: IntrinsicHeight(
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        color: utilPercent > 0.8 ? AppTheme.error : AppTheme.primaryEmerald,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
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
                                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: AppTheme.grey900, letterSpacing: -0.5),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Text('LOAD FACTOR: ', style: TextStyle(color: AppTheme.grey400, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                                        Text('${(utilPercent * 100).toInt()}%', style: TextStyle(color: utilPercent > 0.8 ? AppTheme.error : AppTheme.primaryEmerald, fontSize: 10, fontWeight: FontWeight.w900)),
                                        const Spacer(),
                                        Text('${slot.bookedCount}/${slot.capacity} Units', style: const TextStyle(color: AppTheme.grey600, fontSize: 11, fontWeight: FontWeight.w700)),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
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
