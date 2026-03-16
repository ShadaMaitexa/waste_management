import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
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
  final _addressController = TextEditingController(text: '123 Smart Residences, Ward 15');
  final _notesController = TextEditingController();

  final List<WasteType> _selectedWasteTypes = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
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
        type: PickupType.regular,
        status: PickupStatus.scheduled,
        scheduledDate: DateTime.now(), 
        scheduledTime: const TimeOfDay(hour: 8, minute: 0), 
        notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
        createdAt: DateTime.now(),
        wasteTypes: _selectedWasteTypes,
        estimatedDuration: 30.0,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgSurface,
      appBar: AppBar(
        title: Text(
          'Schedule Dispatch',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.white, letterSpacing: -0.5),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppTheme.bgDark,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.slateGradient,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Colors.white),
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
                    _buildStepHeader('01', 'WASTE CLASSIFICATION'),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Text(
                        'Select operational categories for collection',
                        style: GoogleFonts.inter(color: AppTheme.grey400, fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildWasteTypeGrid(),
                    const SizedBox(height: 56),

                    _buildStepHeader('02', 'SERVICE PARAMETERS'),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Text(
                        'Define delivery geometry and logistics',
                        style: GoogleFonts.inter(color: AppTheme.grey400, fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildAddressSection(),
                    const SizedBox(height: 40),
                    _buildCollectionInfo(),
                    const SizedBox(height: 64),

                    _buildSubmitButton(),
                    const SizedBox(height: 48),
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
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            gradient: AppTheme.emeraldGradient,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryEmerald.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            step,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: AppTheme.grey900,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildWasteTypeGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.4,
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
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.bgDark : Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: isSelected 
                ? [BoxShadow(color: AppTheme.bgDark.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))]
                : AppTheme.smoothShadow,
              border: Border.all(
                color: isSelected ? AppTheme.bgDark : AppTheme.grey200.withValues(alpha: 0.5),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white.withValues(alpha: 0.1) : AppTheme.primaryEmerald.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        _getWasteIcon(type),
                        color: isSelected ? Colors.white : AppTheme.primaryEmerald,
                        size: 24,
                      ),
                    ),
                    if (isSelected)
                      const Icon(Icons.check_circle_rounded, color: AppTheme.primaryEmerald, size: 24),
                  ],
                ),
                Text(
                  _getWasteTypeTitle(type).toUpperCase(),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
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

  Widget _buildCollectionInfo() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.bgCanvas,
        borderRadius: BorderRadius.circular(28),
        boxShadow: AppTheme.cardShadow,
        border: Border.all(color: AppTheme.grey100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.info_rounded, color: AppTheme.info, size: 18),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DISPATCH PROTOCOL',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w800,
                    color: AppTheme.grey400,
                    fontSize: 10,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Collection typically occurs within the 08:00 — 10:30 window.',
                  style: GoogleFonts.inter(fontSize: 13, color: AppTheme.grey700, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressSection() {
    return Column(
      children: [
        TextFormField(
          controller: _addressController,
          style: const TextStyle(fontWeight: FontWeight.w600),
          decoration: const InputDecoration(
            labelText: 'Service Location',
            prefixIcon: Icon(Icons.location_on_rounded, color: AppTheme.primaryEmerald),
          ),
          validator: (value) => value!.isEmpty ? 'Location required' : null,
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _notesController,
          maxLines: 3,
          style: const TextStyle(fontWeight: FontWeight.w500),
          decoration: const InputDecoration(
            labelText: 'Operational Notes (Optional)',
            prefixIcon: Icon(Icons.speaker_notes_rounded, color: AppTheme.grey400),
            hintText: 'e.g. Near the main gate',
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitPickup,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.bgDark,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: 12,
          shadowColor: AppTheme.bgDark.withValues(alpha: 0.4),
          padding: EdgeInsets.zero,
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: AppTheme.slateGradient,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Container(
            alignment: Alignment.center,
            child: _isLoading
                ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'INITIALIZE DISPATCH',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.bolt_rounded, size: 22, color: AppTheme.primaryEmerald),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  IconData _getWasteIcon(WasteType type) {
     switch (type) {
      case WasteType.mixed: return Icons.delete_sweep_rounded;
      case WasteType.dry: return Icons.feed_rounded; 
      case WasteType.wet: return Icons.water_drop_rounded;
      case WasteType.organic: return Icons.eco_rounded;
      case WasteType.recyclable: return Icons.recycling_rounded;
      case WasteType.electronic: return Icons.memory_rounded;
      case WasteType.hazardous: return Icons.warning_rounded;
    }
  }

  String _getWasteTypeTitle(WasteType type) {
     final str = type.toString().split('.').last;
     return str[0].toUpperCase() + str.substring(1);
  }
}
