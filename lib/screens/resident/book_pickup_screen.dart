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
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppTheme.bgSurface,
        foregroundColor: AppTheme.grey900,
        leading: Navigator.canPop(context) 
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                onPressed: () => Navigator.pop(context),
              )
            : null,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStepHeader('01', 'WASTE CLASSIFICATION'),
                    const SizedBox(height: 20),
                    _buildWasteTypeGrid(),
                    const SizedBox(height: 48),

                    _buildStepHeader('02', 'COLLECTION POINT'),
                    const SizedBox(height: 20),
                    _buildAddressSection(),
                    const SizedBox(height: 24),
                    _buildCollectionInfo(),
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
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.primaryEmerald.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            step,
            style: GoogleFonts.plusJakartaSans(
              color: AppTheme.primaryEmerald,
              fontWeight: FontWeight.w900,
              fontSize: 15,
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
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.grey500,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                height: 2,
                width: 32,
                decoration: BoxDecoration(
                  color: AppTheme.grey200,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
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
        childAspectRatio: 1.6,
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
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primaryEmerald : AppTheme.bgCanvas,
              borderRadius: BorderRadius.circular(24),
              boxShadow: isSelected ? [
                BoxShadow(
                  color: AppTheme.primaryEmerald.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                )
              ] : AppTheme.cardShadow,
              border: Border.all(
                color: isSelected ? AppTheme.primaryEmerald : AppTheme.grey200,
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
                      color: isSelected ? Colors.white : AppTheme.grey500,
                      size: 24,
                    ),
                    const Spacer(),
                    if (isSelected)
                      const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18)
                    else 
                      Icon(Icons.circle_outlined, color: AppTheme.grey300, size: 18),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _getWasteTypeTitle(type).toUpperCase(),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: isSelected ? Colors.white : AppTheme.grey700,
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
        color: AppTheme.info.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.info.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppTheme.info.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: const Icon(Icons.info_rounded, color: AppTheme.info, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Standard Dispatch Protocol',
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: AppTheme.info, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your area is scheduled for daily collection between 8:00 AM and 10:00 AM.',
                  style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.grey600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bgCanvas,
        borderRadius: BorderRadius.circular(28),
        boxShadow: AppTheme.cardShadow,
        border: Border.all(color: AppTheme.grey200),
      ),
      child: Column(
        children: [
          TextFormField(
            controller: _addressController,
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: AppTheme.grey900, fontSize: 14),
            decoration: InputDecoration(
              labelText: 'SERVICE LOCATION',
              labelStyle: GoogleFonts.plusJakartaSans(color: AppTheme.grey400, fontWeight: FontWeight.w800, fontSize: 10, letterSpacing: 1),
              border: OutlineInputBorder(borderRadius: const BorderRadius.vertical(top: Radius.circular(28)), borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(borderRadius: const BorderRadius.vertical(top: Radius.circular(28)), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(borderRadius: const BorderRadius.vertical(top: Radius.circular(28)), borderSide: BorderSide.none),
              prefixIcon: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Icon(Icons.location_on_rounded, color: AppTheme.primaryEmerald, size: 22),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            ),
            validator: (value) => value!.isEmpty ? 'Location required' : null,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Divider(height: 1, color: AppTheme.grey200),
          ),
          TextFormField(
            controller: _notesController,
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, color: AppTheme.grey700, fontSize: 14),
            decoration: InputDecoration(
              labelText: 'OPERATIONAL NOTES (OPTIONAL)',
              labelStyle: GoogleFonts.plusJakartaSans(color: AppTheme.grey400, fontWeight: FontWeight.w800, fontSize: 10, letterSpacing: 1),
              border: OutlineInputBorder(borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)), borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)), borderSide: BorderSide.none),
              prefixIcon: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Icon(Icons.speaker_notes_rounded, color: AppTheme.accentIndigo, size: 22),
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
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: AppTheme.emeraldGradient,
        boxShadow: AppTheme.intenseShadow,
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
        onPressed: _isLoading ? null : _submitPickup,
        child: _isLoading
            ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Text(
                    'INITIALIZE DISPATCH',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                ],
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
