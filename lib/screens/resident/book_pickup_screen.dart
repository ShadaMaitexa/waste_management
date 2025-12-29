import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/pickup.dart';
import '../../services/pickup_service.dart';
import '../../services/reward_service.dart';
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
  final List<WasteType> _selectedWasteTypes = [WasteType.dry, WasteType.wet];
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

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
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

    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
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

    setState(() {
      _isLoading = true;
    });

    try {
      final pickupService = Provider.of<PickupService>(context, listen: false);
      final rewardService = Provider.of<RewardService>(context, listen: false);

      final pickup = Pickup(
        id: pickupService.generatePickupId(),
        userId: 'user1', // Mock user ID
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
            ? _specialInstructionsController.text.trim() : null,
      );

      final success = await pickupService.createPickup(pickup);
      
      if (success) {
        // Award points for booking pickup
        await rewardService.addPoints(
          'user1',
          10,
          'Pickup Scheduled',
          'Points earned for scheduling a waste pickup',
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pickup scheduled successfully! +10 points earned'),
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
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  double _getEstimatedDuration() {
    int baseDuration = 30;
    
    if (_selectedType == PickupType.bulk) baseDuration += 30;
    if (_selectedType == PickupType.emergency) baseDuration -= 10;
    
    baseDuration += _selectedWasteTypes.length * 5;
    
    return baseDuration.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Waste Pickup'),
        elevation: 0,
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pickup Type Selection
              _buildSectionTitle('Pickup Type'),
              const SizedBox(height: AppTheme.spacingS),
              _buildPickupTypeSelector(),
              const SizedBox(height: AppTheme.spacingL),

              // Date and Time Selection
              _buildSectionTitle('Date & Time'),
              const SizedBox(height: AppTheme.spacingS),
              _buildDateTimeSelector(),
              const SizedBox(height: AppTheme.spacingL),

              // Waste Type Selection
              _buildSectionTitle('Waste Types'),
              const SizedBox(height: AppTheme.spacingS),
              _buildWasteTypeSelector(),
              const SizedBox(height: AppTheme.spacingL),

              // Address
              _buildSectionTitle('Pickup Address'),
              const SizedBox(height: AppTheme.spacingS),
              _buildAddressField(),
              const SizedBox(height: AppTheme.spacingL),

              // Special Instructions
              _buildSectionTitle('Additional Information'),
              const SizedBox(height: AppTheme.spacingS),
              _buildNotesField(),
              const SizedBox(height: AppTheme.spacingS),
              _buildSpecialInstructionsField(),
              const SizedBox(height: AppTheme.spacingXL),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitPickup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingM),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusM),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Schedule Pickup',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.grey800,
          ),
    );
  }

  Widget _buildPickupTypeSelector() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.grey300),
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
      ),
      child: Column(
        children: PickupType.values.map((type) {
          return RadioListTile<PickupType>(
            value: type,
            groupValue: _selectedType,
            onChanged: (value) {
              setState(() {
                _selectedType = value!;
              });
            },
            title: Text(_getPickupTypeTitle(type)),
            subtitle: Text(_getPickupTypeDescription(type)),
            activeColor: AppTheme.primaryGreen,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDateTimeSelector() {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: _selectDate,
            child: Container(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.grey300),
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, color: AppTheme.primaryGreen),
                  const SizedBox(width: AppTheme.spacingS),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Date',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.grey600,
                              ),
                        ),
                        Text(
                          DateFormat('MMM d, yyyy').format(_selectedDate),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: AppTheme.spacingM),
        Expanded(
          child: InkWell(
            onTap: _selectTime,
            child: Container(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.grey300),
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
              ),
              child: Row(
                children: [
                  Icon(Icons.access_time, color: AppTheme.primaryGreen),
                  const SizedBox(width: AppTheme.spacingS),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Time',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.grey600,
                              ),
                        ),
                        Text(
                          _selectedTime.format(context),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWasteTypeSelector() {
    return Wrap(
      spacing: AppTheme.spacingS,
      runSpacing: AppTheme.spacingS,
      children: WasteType.values.map((type) {
        final isSelected = _selectedWasteTypes.contains(type);
        return FilterChip(
          label: Text(_getWasteTypeTitle(type)),
          selected: isSelected,
          onSelected: (_) => _toggleWasteType(type),
          selectedColor: AppTheme.primaryGreen.withOpacity(0.2),
          checkmarkColor: AppTheme.primaryGreen,
          backgroundColor: AppTheme.grey100,
          labelStyle: TextStyle(
            color: isSelected ? AppTheme.primaryGreen : AppTheme.grey700,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAddressField() {
    return TextFormField(
      controller: _addressController,
      decoration: const InputDecoration(
        labelText: 'Pickup Address',
        hintText: 'Enter your complete address',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.location_on),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter pickup address';
        }
        return null;
      },
    );
  }

  Widget _buildNotesField() {
    return TextFormField(
      controller: _notesController,
      decoration: const InputDecoration(
        labelText: 'Notes (Optional)',
        hintText: 'Any additional notes for the pickup',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.note),
      ),
      maxLines: 2,
    );
  }

  Widget _buildSpecialInstructionsField() {
    return TextFormField(
      controller: _specialInstructionsController,
      decoration: const InputDecoration(
        labelText: 'Special Instructions (Optional)',
        hintText: 'Any special instructions for the worker',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.info_outline),
      ),
      maxLines: 3,
    );
  }

  String _getPickupTypeTitle(PickupType type) {
    switch (type) {
      case PickupType.regular:
        return 'Regular Pickup';
      case PickupType.emergency:
        return 'Emergency Pickup';
      case PickupType.bulk:
        return 'Bulk Pickup';
      case PickupType.special:
        return 'Special Pickup';
    }
  }

  String _getPickupTypeDescription(PickupType type) {
    switch (type) {
      case PickupType.regular:
        return 'Standard waste collection';
      case PickupType.emergency:
        return 'Priority collection within 2 hours';
      case PickupType.bulk:
        return 'Large quantity waste collection';
      case PickupType.special:
        return 'Special waste requiring handling';
    }
  }

  String _getWasteTypeTitle(WasteType type) {
    switch (type) {
      case WasteType.mixed:
        return 'Mixed';
      case WasteType.dry:
        return 'Dry';
      case WasteType.wet:
        return 'Wet';
      case WasteType.organic:
        return 'Organic';
      case WasteType.recyclable:
        return 'Recyclable';
      case WasteType.electronic:
        return 'Electronic';
      case WasteType.hazardous:
        return 'Hazardous';
    }
  }
}
