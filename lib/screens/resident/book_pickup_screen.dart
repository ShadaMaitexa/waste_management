import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../../models/pickup.dart';
import '../../models/pickup_slot.dart';
import '../../services/pickup_service.dart';
import '../../services/auth_service.dart';
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
  PickupSlot? _selectedSlot;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PickupService>(context, listen: false).fetchAvailableSlots();
    });
  }

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

    if (_selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a collection slot'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final pickupService = Provider.of<PickupService>(context, listen: false);

      final authService = Provider.of<AuthService>(context, listen: false);
      final user = authService.currentUser;

      final pickup = Pickup(
        id: pickupService.generatePickupId(),
        userId: user?.id ?? 'user_anonymous',
        userName: user?.name ?? 'Guest User',
        userPhone: user?.phoneNumber ?? '+91 0000000000',
        address: _addressController.text.trim(),
        wardNumber: user?.wardNumber ?? '15',
        type: PickupType.regular,
        status: PickupStatus.scheduled,
        scheduledDate: _selectedSlot!.date, 
        scheduledTime: _selectedSlot!.startTime, 
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
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: AppTheme.bgSurface,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppTheme.bgSurface, Color(0xFFF1F8E9)],
              ),
            ),
          ),
          CustomScrollView(
            slivers: [
              _buildSliverAppBar(),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildStepHeader('01', 'CLASSIFICATION'),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Text(
                            'Select operational categories for collection',
                            style: GoogleFonts.plusJakartaSans(color: AppTheme.grey400, fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(height: 32),
                        _buildWasteTypeGrid(),
                        const SizedBox(height: 56),

                        _buildStepHeader('02', 'COLLECTION WINDOW'),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Text(
                            'Select an available operational slot',
                            style: GoogleFonts.plusJakartaSans(color: AppTheme.grey400, fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildSlotSelection(),
                        const SizedBox(height: 56),

                        _buildStepHeader('03', 'SERVICE PARAMETERS'),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Text(
                            'Define delivery geometry and logistics',
                            style: GoogleFonts.plusJakartaSans(color: AppTheme.grey400, fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(height: 32),
                        _buildServiceParameters(),
                        const SizedBox(height: 40),
                        _buildCollectionInfo(),
                        const SizedBox(height: 64),

                        _buildSubmitButton(),
                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Back Button
          Positioned(
            top: 50,
            left: 20,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: AppTheme.cardShadow,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.grey900, size: 18),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200.0,
      floating: false,
      pinned: true,
      backgroundColor: AppTheme.bgDark,
      automaticallyImplyLeading: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            color: AppTheme.bgDark,
            gradient: AppTheme.slateGradient,
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned(
                right: -40,
                bottom: -20,
                child: Icon(
                  Icons.add_task_rounded,
                  size: 200,
                  color: Colors.white.withValues(alpha: 0.03),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 0, 28, 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Schedule Pickup',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'SMART ECO-LOGISTICS DISPATCH',
                      style: GoogleFonts.plusJakartaSans(
                        color: AppTheme.primaryEmerald,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
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
          decoration: BoxDecoration(
            color: AppTheme.bgDark,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            step,
            style: GoogleFonts.plusJakartaSans(
              color: AppTheme.primaryEmerald,
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: AppTheme.grey900,
            letterSpacing: 1,
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
        childAspectRatio: 1.3,
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
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primaryEmerald : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: isSelected 
                ? [BoxShadow(color: AppTheme.primaryEmerald.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))]
                : AppTheme.cardShadow,
              border: Border.all(
                color: isSelected ? AppTheme.primaryEmerald : AppTheme.grey100,
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getWasteIcon(type),
                  size: 28,
                  color: isSelected ? Colors.white : AppTheme.grey900,
                ),
                const SizedBox(height: 12),
                Text(
                  _getWasteTypeTitle(type),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: isSelected ? Colors.white : AppTheme.grey900,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildServiceParameters() {
    return Column(
      children: [
        TextFormField(
          controller: _addressController,
          maxLines: 2,
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: AppTheme.grey900),
          decoration: const InputDecoration(
            hintText: 'Collection address',
            prefixIcon: Icon(Icons.location_pin, color: AppTheme.primaryEmerald, size: 20),
          ),
          validator: (value) => value == null || value.isEmpty ? 'Address required' : null,
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _notesController,
          maxLines: 3,
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: AppTheme.grey900),
          decoration: const InputDecoration(
            hintText: 'Operational notes (optional)',
            prefixIcon: Icon(Icons.note_alt_rounded, color: AppTheme.primaryEmerald, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildCollectionInfo() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.cardShadow,
        border: Border.all(color: AppTheme.grey100, width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.info_outline_rounded, color: AppTheme.info, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Pickups usually occur between 08:00 AM and 11:00 AM local time.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: AppTheme.grey500,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
          padding: EdgeInsets.zero,
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: AppTheme.slateGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.bgDark.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ],
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
                          letterSpacing: 2,
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

  Widget _buildSlotSelection() {
    return Consumer<PickupService>(
      builder: (context, service, child) {
        if (service.isLoading && service.availableSlots.isEmpty) {
          return _buildSlotShimmer();
        }

        if (service.availableSlots.isEmpty) {
          return Center(
            child: Text(
              'No available slots found for your region.',
              style: GoogleFonts.inter(color: AppTheme.grey400, fontSize: 13),
            ),
          );
        }

        return SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: service.availableSlots.length,
            itemBuilder: (context, index) {
              final slot = service.availableSlots[index];
              final isSelected = _selectedSlot?.id == slot.id;
              final isToday = DateFormat('yyyy-MM-dd').format(slot.date) == DateFormat('yyyy-MM-dd').format(DateTime.now());

              return GestureDetector(
                onTap: () => setState(() => _selectedSlot = slot),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 140,
                  margin: const EdgeInsets.only(right: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.bgDark : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isSelected ? AppTheme.bgDark : AppTheme.grey100,
                      width: 1.5,
                    ),
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: AppTheme.bgDark.withValues(alpha: 0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      )
                    ] : AppTheme.cardShadow,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isToday ? 'TODAY' : DateFormat('EEE, MMM d').format(slot.date).toUpperCase(),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: isSelected ? AppTheme.primaryEmerald : AppTheme.grey400,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        slot.formatTime(context),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
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
      },
    );
  }

  Widget _buildSlotShimmer() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        itemBuilder: (_, __) => Shimmer.fromColors(
          baseColor: Colors.grey[200]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            width: 140,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
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
