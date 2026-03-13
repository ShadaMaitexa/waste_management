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
            top: 24,
            left: 24,
            right: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Create Pickup Slot',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.grey900),
              ),
              const SizedBox(height: 24),
              
              const Text('Start Time', style: TextStyle(fontWeight: FontWeight.bold)),
              ListTile(
                title: Text(startTime.format(context)),
                trailing: const Icon(Icons.access_time),
                onTap: () async {
                  final picked = await showTimePicker(context: context, initialTime: startTime);
                  if (picked != null) setModalState(() => startTime = picked);
                },
              ),
              
              const Text('End Time', style: TextStyle(fontWeight: FontWeight.bold)),
              ListTile(
                title: Text(endTime.format(context)),
                trailing: const Icon(Icons.access_time),
                onTap: () async {
                  final picked = await showTimePicker(context: context, initialTime: endTime);
                  if (picked != null) setModalState(() => endTime = picked);
                },
              ),
              
              const Text('Capacity (Pickups)', style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: capacity > 1 ? () => setModalState(() => capacity--) : null,
                  ),
                  Text('$capacity', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () => setModalState(() => capacity++),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
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
                  child: const Text('CREATE SLOT', style: TextStyle(fontWeight: FontWeight.bold)),
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
      backgroundColor: AppTheme.grey50,
      appBar: AppBar(
        title: const Text('Manage Pickup Slots'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.grey900,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildCalendarStrip(),
          Expanded(
            child: _buildSlotsList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddSlotDialog,
        backgroundColor: AppTheme.primaryGreen,
        icon: const Icon(Icons.add),
        label: const Text('New Slot'),
      ),
    );
  }

  Widget _buildCalendarStrip() {
    return Container(
      height: 100,
      color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 14,
        itemBuilder: (context, index) {
          final date = DateTime.now().add(Duration(days: index));
          final isSelected = DateUtils.isSameDay(date, _selectedDate);
          
          return GestureDetector(
            onTap: () => setState(() => _selectedDate = date),
            child: Container(
              width: 60,
              margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryGreen : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? AppTheme.primaryGreen : AppTheme.grey200,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('E').format(date).toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : AppTheme.grey500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('d').format(date),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: isSelected ? Colors.white : AppTheme.grey900,
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
                Icon(Icons.event_busy_outlined, size: 64, color: AppTheme.grey300),
                const SizedBox(height: 16),
                Text(
                  'No slots defined for this day',
                  style: TextStyle(color: AppTheme.grey500, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _showAddSlotDialog,
                  child: const Text('Add your first slot'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: slots.length,
          itemBuilder: (context, index) {
            final slot = slots[index];
            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                leading: CircleAvatar(
                  backgroundColor: AppTheme.primaryGreen.withOpacity(0.1),
                  child: const Icon(Icons.access_time, color: AppTheme.primaryGreen),
                ),
                title: Text(
                  slot.formatTime(context),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('Capacity: ${slot.bookedCount}/${slot.capacity} pickups'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppTheme.error),
                  onPressed: () => pickupService.deletePickupSlot(slot.id),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
