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
        title: const Text(
          'Waste Collection',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -0.5),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.grey900,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStepHeader('01', 'MODE OF COLLECTION'),
                    const SizedBox(height: 20),
                    _buildPickupTypeGrid(),
                    const SizedBox(height: 40),

                    _buildStepHeader('02', 'CLASSIFICATION'),
                    const SizedBox(height: 20),
                    _buildWasteTypeGrid(),
                    const SizedBox(height: 40),

                    if (_selectedType != PickupType.instant) ...[
                      _buildStepHeader('03', 'SCHEDULING'),
                      const SizedBox(height: 20),
                      _buildDateTimeSelector(),
                      const SizedBox(height: 40),
                    ],

                    _buildStepHeader(_selectedType == PickupType.instant ? '03' : '04', 'LOCATION & LOGISTICS'),
                    const SizedBox(height: 20),
                    _buildAddressSection(),
                    const SizedBox(height: 48),

                    _buildSubmitButton(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepHeader(String step, String title) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppTheme.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.center,
          child: Text(
            step,
            style: const TextStyle(
              color: AppTheme.primaryGreen,
              fontWeight: FontWeight.w900,
              fontSize: 16,
              letterSpacing: -0.5,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.grey900,
                  letterSpacing: -0.5,
                ),
              ),
              Container(
                height: 2,
                width: 32,
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPickupTypeGrid() {
    return SizedBox(
      height: 160,
      child: ListView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        physics: const BouncingScrollPhysics(),
        children: PickupType.values.map((type) {
          final isSelected = _selectedType == type;
          return GestureDetector(
            onTap: () => setState(() => _selectedType = type),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 150,
              margin: const EdgeInsets.only(right: 20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryGreen : Colors.white,
                borderRadius: BorderRadius.circular(36),
                boxShadow: [
                  BoxShadow(
                    color: (isSelected ? AppTheme.primaryGreen : Colors.black).withOpacity(isSelected ? 0.3 : 0.04),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white.withOpacity(0.2) : AppTheme.grey50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getPickupIcon(type),
                      color: isSelected ? Colors.white : AppTheme.primaryGreen,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _getPickupTypeTitle(type).split('\n')[0].toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: isSelected ? Colors.white : AppTheme.grey900,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getPickupTypeTitle(type).contains('\n') 
                        ? _getPickupTypeTitle(type).split('\n')[1] 
                        : 'Ready',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white.withOpacity(0.7) : AppTheme.grey500,
                    ),
                    textAlign: TextAlign.center,
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
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: WasteType.values.length,
      itemBuilder: (context, index) {
        final type = WasteType.values[index];
        final isSelected = _selectedWasteTypes.contains(type);
        return GestureDetector(
          onTap: () => _toggleWasteType(type),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primaryGreen : Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
              border: Border.all(
                color: isSelected ? AppTheme.primaryGreen : AppTheme.grey100,
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Icon(
                      _getWasteIcon(type),
                      color: isSelected ? Colors.white : AppTheme.primaryGreen,
                      size: 22,
                    ),
                    const Spacer(),
                    if (isSelected)
                      const Icon(Icons.verified_rounded, color: Colors.white, size: 16),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _getWasteTypeTitle(type).toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: isSelected ? Colors.white : AppTheme.grey900,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDateTimeSelector() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: _selectDate,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                    const Icon(Icons.event_note_rounded, color: AppTheme.primaryGreen),
                    const SizedBox(height: 8),
                    Text(
                      DateFormat('EEE, MMM d').format(_selectedDate),
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(width: 1, height: 40, color: AppTheme.grey100),
          Expanded(
            child: InkWell(
              onTap: _selectTime,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                    const Icon(Icons.schedule_rounded, color: AppTheme.primaryGreen),
                    const SizedBox(height: 8),
                    Text(
                      _selectedTime.format(context),
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          TextFormField(
            controller: _addressController,
            style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.grey900),
            decoration: InputDecoration(
              labelText: 'COLLECTION POINT',
              labelStyle: const TextStyle(color: AppTheme.grey500, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1),
              border: OutlineInputBorder(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
              prefixIcon: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Icon(Icons.location_on_rounded, color: AppTheme.primaryGreen, size: 22),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            ),
            validator: (value) => value!.isEmpty ? 'Location required' : null,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Divider(height: 1, color: AppTheme.grey100),
          ),
          TextFormField(
            controller: _notesController,
            style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.grey700, fontSize: 14),
            decoration: InputDecoration(
              labelText: 'SPECIAL INSTRUCTIONS',
              labelStyle: const TextStyle(color: AppTheme.grey500, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1),
              border: OutlineInputBorder(
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
              prefixIcon: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Icon(Icons.maps_ugc_rounded, color: AppTheme.info, size: 22),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 72,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [AppTheme.primaryGreen, AppTheme.secondaryGreen],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGreen.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
        onPressed: _isLoading ? null : _submitPickup,
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    (_selectedType == PickupType.instant ? 'INITIATE COLLECTION' : 'CONFIRM BOOKING').toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                ],
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
