import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/pickup.dart';
import '../../services/pickup_service.dart';
import '../../theme/app_theme.dart';

class BookPickupScreen extends StatefulWidget {
  const BookPickupScreen({super.key});

  @override
  State<BookPickupScreen> createState() => _BookPickupScreenState();
}

class _BookPickupScreenState extends State<BookPickupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController(text: '123 Green Street, Ward 15');
  final _notesController = TextEditingController();
  final _specialInstructionsController = TextEditingController();

  PickupType _selectedType = PickupType.regular;
  final List<WasteType> _selectedWasteTypes = [];
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 8, minute: 0);
  bool _isLoading = false;

  @override
  void dispose() {
    _addressController.dispose();
    _notesController.dispose();
    _specialInstructionsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: AppTheme.lightTheme.copyWith(
            colorScheme: const ColorScheme.light(
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
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: AppTheme.lightTheme.copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryGreen,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedTime) {
      setState(() => _selectedTime = picked);
    }
  }

  void _toggleWasteType(WasteType type) {
    setState(() {
      if (_selectedWasteTypes.contains(type)) {
        _selectedWasteTypes.remove(type);
      } else {
        _selectedWasteTypes.add(type);
      }
    });
  }

  Future<void> _submitPickup() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedWasteTypes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one waste type'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final pickupService = Provider.of<PickupService>(context, listen: false);

      final pickup = Pickup(
        id: pickupService.generatePickupId(),
        userId: 'user1',
        userName: 'John Doe',
        userPhone: '+91 9876543210',
        address: _addressController.text.trim(),
        wardNumber: '15',
        type: _selectedType,
        status: PickupStatus.scheduled,
        scheduledDate: _selectedDate,
        scheduledTime: _selectedTime,
        notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
        createdAt: DateTime.now(),
        wasteTypes: _selectedWasteTypes,
        estimatedDuration: _getEstimatedDuration(),
        specialInstructions: _specialInstructionsController.text.trim().isNotEmpty
            ? _specialInstructionsController.text.trim()
            : null,
      );

      final success = await pickupService.createPickup(pickup);

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pickup scheduled successfully!'),
              backgroundColor: AppTheme.success,
            ),
          );
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error scheduling pickup: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  double _getEstimatedDuration() {
    int baseDuration = 30;
    if (_selectedType == PickupType.emergency) baseDuration -= 10;
    baseDuration += _selectedWasteTypes.length * 5;
    return baseDuration.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.grey50,
      appBar: AppBar(
        title: const Text('New Pickup Request', style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppTheme.primaryGreen,
        iconTheme: const IconThemeData(color: AppTheme.primaryGreen),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStepHeader('1', 'Select Pickup Type'),
              const SizedBox(height: AppTheme.spacingM),
              _buildPickupTypeGrid(),
              const SizedBox(height: AppTheme.spacingL),

              _buildStepHeader('2', 'Select Waste Types'),
              const SizedBox(height: AppTheme.spacingM),
              _buildWasteTypeGrid(),
              const SizedBox(height: AppTheme.spacingL),

              if (_selectedType != PickupType.instant) ...[
                _buildStepHeader('3', 'Date & Time'),
                const SizedBox(height: AppTheme.spacingM),
                _buildDateTimeSelector(),
                const SizedBox(height: AppTheme.spacingL),
              ],

              _buildStepHeader(_selectedType == PickupType.instant ? '3' : '4', 'Address & Details'),
              const SizedBox(height: AppTheme.spacingM),
              _buildAddressSection(),
              const SizedBox(height: AppTheme.spacingXL),

              _buildSubmitButton(),
              const SizedBox(height: AppTheme.spacingL),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepHeader(String step, String title) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.primaryGreen, AppTheme.lightGreen],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryGreen.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Text(
            step,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.grey900,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildPickupTypeGrid() {
    return SizedBox(
      height: 110,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: PickupType.values.map((type) {
          final isSelected = _selectedType == type;
          return GestureDetector(
            onTap: () => setState(() => _selectedType = type),
            child: Container(
              width: 130, // Fixed width
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryGreen : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: (isSelected ? AppTheme.primaryGreen : AppTheme.grey300).withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Container(
                     padding: const EdgeInsets.all(8),
                     decoration: BoxDecoration(
                       color: isSelected ? Colors.white.withOpacity(0.2) : AppTheme.primaryGreen.withOpacity(0.1),
                       shape: BoxShape.circle,
                     ),
                     child: Icon(
                      _getPickupIcon(type),
                      color: isSelected ? Colors.white : AppTheme.primaryGreen,
                      size: 28,
                    ),
                   ),
                  const SizedBox(height: 10),
                  Text(
                    _getPickupTypeTitle(type),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      color: isSelected ? Colors.white : AppTheme.grey800,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildWasteTypeGrid() {
     return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: WasteType.values.map((type) {
        final isSelected = _selectedWasteTypes.contains(type);
        return GestureDetector(
          onTap: () => _toggleWasteType(type),
          child: Container(
             width: (MediaQuery.of(context).size.width - 48 - 12) / 2, // 2 column grid
             padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
             decoration: BoxDecoration(
               color: isSelected ? AppTheme.primaryGreen.withOpacity(0.05) : Colors.white,
               borderRadius: BorderRadius.circular(16),
               border: Border.all(
                 color: isSelected ? AppTheme.primaryGreen : Colors.transparent,
                 width: 1.5,
               ),
               boxShadow: isSelected ? [] : [
                 BoxShadow(
                   color: AppTheme.grey300.withOpacity(0.3),
                   blurRadius: 10,
                   offset: const Offset(0, 4),
                 ),
               ],
             ),
             child: Row(
               children: [
                 Container(
                   padding: const EdgeInsets.all(6),
                   decoration: BoxDecoration(
                     color: isSelected ? AppTheme.primaryGreen.withOpacity(0.1) : AppTheme.grey100,
                     borderRadius: BorderRadius.circular(8),
                   ),
                   child: Icon(
                     _getWasteIcon(type),
                     size: 20,
                     color: isSelected ? AppTheme.primaryGreen : AppTheme.grey600,
                   ),
                 ),
                 const SizedBox(width: 10),
                 Expanded(
                   child: Text(
                     _getWasteTypeTitle(type),
                     style: TextStyle(
                       fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                       color: isSelected ? AppTheme.primaryGreen : AppTheme.grey800,
                       fontSize: 14,
                     ),
                   ),
                 ),
                 if (isSelected) 
                   const Icon(Icons.check_circle, size: 18, color: AppTheme.primaryGreen),
               ],
             ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDateTimeSelector() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: _selectDate,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.grey300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Date', style: TextStyle(color: AppTheme.grey600, fontSize: 12)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 18, color: AppTheme.primaryGreen),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('EEE, MMM d').format(_selectedDate),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: _selectTime,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.grey300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Time', style: TextStyle(color: AppTheme.grey600, fontSize: 12)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 18, color: AppTheme.primaryGreen),
                      const SizedBox(width: 8),
                      Text(
                        _selectedTime.format(context),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddressSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.grey300.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          TextFormField(
            controller: _addressController,
            decoration: InputDecoration(
              labelText: 'Location',
              labelStyle: const TextStyle(color: AppTheme.grey600),
              border: OutlineInputBorder(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
              prefixIcon: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.location_on_rounded, color: AppTheme.primaryGreen, size: 20),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            validator: (value) => value!.isEmpty ? 'Address is required' : null,
          ),
          Divider(height: 1, color: AppTheme.grey200, indent: 16, endIndent: 16),
          TextFormField(
            controller: _notesController,
            decoration: InputDecoration(
              labelText: 'Instructions for driver (optional)',
              labelStyle: const TextStyle(color: AppTheme.grey600),
              border: OutlineInputBorder(
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
              prefixIcon: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.info.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.note_alt_rounded, color: AppTheme.info, size: 20),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
     return SizedBox(
      width: double.infinity,
      height: 54,
       child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            colors: [AppTheme.primaryGreen, AppTheme.secondaryGreen],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryGreen.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          ),
          onPressed: _isLoading ? null : _submitPickup,
          child: _isLoading
              ? const SizedBox(
                  height: 24, width: 24,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _selectedType == PickupType.instant ? 'Find a Driver Now' : 'Confirm Scheduling',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_rounded, size: 22),
                  ],
                ),
        ),
      ),
     );
  }

  IconData _getPickupIcon(PickupType type) {
    switch (type) {
      case PickupType.regular: return Icons.calendar_month_outlined;
      case PickupType.emergency: return Icons.bolt_outlined;
      case PickupType.instant: return Icons.local_shipping_outlined;
    }
  }

  IconData _getWasteIcon(WasteType type) {
     switch (type) {
      case WasteType.mixed: return Icons.delete_outline;
      case WasteType.dry: return Icons.description_outlined; // paper/dry
      case WasteType.wet: return Icons.water_drop_outlined;
      case WasteType.organic: return Icons.eco_outlined;
      case WasteType.recyclable: return Icons.recycling_outlined;
      case WasteType.electronic: return Icons.computer_outlined;
      case WasteType.hazardous: return Icons.warning_amber_outlined;
    }
  }

  String _getPickupTypeTitle(PickupType type) {
    switch (type) {
      case PickupType.regular: return 'Pre-book\n(Scheduled)';
      case PickupType.emergency: return 'Express\n(Priority)';
      case PickupType.instant: return 'Instant\n(Release Now)';
    }
  }

  String _getWasteTypeTitle(WasteType type) {
     final str = type.toString().split('.').last;
     return str[0].toUpperCase() + str.substring(1);
  }
}
