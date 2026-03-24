import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../models/pickup.dart';
import '../../models/pickup_slot.dart';
import '../../services/pickup_service.dart';
import '../../services/auth_service.dart';
import '../../services/admin_service.dart';
import '../../theme/app_theme.dart';
import 'pickup_qr_screen.dart';

class BookPickupScreen extends StatefulWidget {
  const BookPickupScreen({super.key});

  @override
  State<BookPickupScreen> createState() => _BookPickupScreenState();
}

class _BookPickupScreenState extends State<BookPickupScreen> {
  final _pageController = PageController();
  int _currentStep = 0;
  
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _addressController;
  final _notesController = TextEditingController();

  static const _wasteOptions = [
    {'key': 'dry', 'label': 'Dry Waste', 'icon': Icons.feed_rounded},
    {'key': 'wet', 'label': 'Wet Waste', 'icon': Icons.water_drop_rounded},
    {'key': 'e-waste', 'label': 'E-Waste', 'icon': Icons.memory_rounded},
    {'key': 'biomedical', 'label': 'Biomedical', 'icon': Icons.medical_services_rounded},
  ];

  static const _itemOptionsMap = {
    'dry': ['Paper', 'Cardboard', 'Plastic Wrapper', 'Glass Bottle', 'Metal Scrap', 'Textile'],
    'wet': ['Food Scraps', 'Vegetable Peels', 'Fruit Waste', 'Meat/Dairy'],
    'e-waste': ['Battery', 'Smartphone', 'Laptop', 'Cables', 'Charger'],
    'biomedical': ['Used Masks', 'Gloves', 'Syringes', 'Expired Medicine'],
  };

  String? _selectedWasteType;
  String? _selectedItem;
  PickupSlot? _selectedSlot;
  LatLng? _selectedLocation;
  bool _isLoading = false;
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthService>(context, listen: false).currentUser;
    _addressController = TextEditingController(text: user?.address ?? '');
    
    if (user?.latitude != null && user?.longitude != null) {
      _selectedLocation = LatLng(
        double.parse(user!.latitude!),
        double.parse(user.longitude!),
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PickupService>(context, listen: false).fetchAvailableSlots();
      _determinePosition();
    });
  }

  Future<void> _determinePosition() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      final latLng = LatLng(position.latitude, position.longitude);
      setState(() => _selectedLocation = latLng);
      _mapController?.animateCamera(CameraUpdate.newLatLng(latLng));
    } catch (e) {
      debugPrint('Location error: $e');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentStep < 3) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      setState(() => _currentStep++);
    } else {
      _submitPickup();
    }
  }

  void _prevPage() {
    if (_currentStep > 0) {
      _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      setState(() => _currentStep--);
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _submitPickup() async {
    if (_selectedWasteType == null || _selectedItem == null || _selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please complete all steps')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final pickupService = Provider.of<PickupService>(context, listen: false);
      final success = await pickupService.createPickup(
        item: _selectedItem!,
        address: _addressController.text.trim(),
        date: _selectedSlot!.date,
        slotId: int.tryParse(_selectedSlot!.id) ?? 0,
        wasteType: _selectedWasteType!,
      );

      if (success && mounted) {
        // Find the newly created pickup (most recent)
        final newPickup = pickupService.pickups.firstWhere(
          (p) => p.item == _selectedItem && p.wasteType == _selectedWasteType,
          orElse: () => pickupService.pickups.first,
        );
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => PickupQRScreen(pickup: newPickup)),
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgSurface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.grey900, size: 20),
          onPressed: _prevPage,
        ),
        title: _buildProgressIndicator(),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildWasteTypeStep(),
                _buildItemStep(),
                _buildSlotStep(),
                _buildLocationStep(),
              ],
            ),
          ),
          _buildBottomNavigation(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(4, (index) {
        final isActive = index <= _currentStep;
        return Container(
          width: 24, height: 4,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: isActive ? AppTheme.primaryEmerald : AppTheme.grey200,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }

  Widget _buildWasteTypeStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('SELECT TYPE', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 2, color: AppTheme.grey400)),
          const SizedBox(height: 8),
          Text('What kind of waste?', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, fontSize: 24, color: AppTheme.grey900)),
          const SizedBox(height: 32),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16),
              itemCount: _wasteOptions.length,
              itemBuilder: (context, index) {
                final opt = _wasteOptions[index];
                final isSelected = _selectedWasteType == opt['key'];
                return GestureDetector(
                  onTap: () => setState(() {
                    _selectedWasteType = opt['key'] as String;
                    _selectedItem = null;
                  }),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primaryEmerald : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: isSelected ? [BoxShadow(color: AppTheme.primaryEmerald.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))] : AppTheme.cardShadow,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(opt['icon'] as IconData, color: isSelected ? Colors.white : AppTheme.primaryEmerald, size: 40),
                        const SizedBox(height: 12),
                        Text(opt['label'] as String, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, color: isSelected ? Colors.white : AppTheme.grey900, fontSize: 14)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemStep() {
    final items = _itemOptionsMap[_selectedWasteType] ?? [];
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('SPECIFIC ITEM', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 2, color: AppTheme.grey400)),
          const SizedBox(height: 8),
          Text('Tell us exactly what it is', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, fontSize: 24, color: AppTheme.grey900)),
          const SizedBox(height: 32),
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final isSelected = _selectedItem == item;
                return GestureDetector(
                  onTap: () => setState(() => _selectedItem = item),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.bgDark : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isSelected ? AppTheme.bgDark : AppTheme.grey100),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(item, style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: isSelected ? Colors.white : AppTheme.grey800)),
                        if (isSelected) const Icon(Icons.check_circle_rounded, color: AppTheme.primaryEmerald, size: 20),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlotStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('COLLECTION SLOT', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 2, color: AppTheme.grey400)),
          const SizedBox(height: 8),
          Text('When should we come?', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, fontSize: 24, color: AppTheme.grey900)),
          const SizedBox(height: 32),
          _buildSlotSelectionUI(),
        ],
      ),
    );
  }

  Widget _buildSlotSelectionUI() {
    return Consumer<PickupService>(
      builder: (context, service, _) {
        if (service.isLoading) return const Center(child: CircularProgressIndicator());
        if (service.availableSlots.isEmpty) return const Center(child: Text('No slots available for your ward.'));
        
        return Expanded(
          child: ListView.builder(
            itemCount: service.availableSlots.length,
            itemBuilder: (context, index) {
              final slot = service.availableSlots[index];
              final isSelected = _selectedSlot?.id == slot.id;
              return GestureDetector(
                onTap: () => setState(() => _selectedSlot = slot),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primaryEmerald.withOpacity(0.1) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isSelected ? AppTheme.primaryEmerald : AppTheme.grey100, width: 2),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: AppTheme.primaryEmerald.withOpacity(0.1), shape: BoxShape.circle),
                        child: const Icon(Icons.calendar_month_rounded, color: AppTheme.primaryEmerald, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(DateFormat('EEEE, MMM d').format(slot.date), style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, color: AppTheme.grey900)),
                            Text(slot.formatTime(context), style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppTheme.grey500)),
                          ],
                        ),
                      ),
                      if (isSelected) const Icon(Icons.radio_button_checked_rounded, color: AppTheme.primaryEmerald),
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

  Widget _buildLocationStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('CONFIRM LOCATION', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 2, color: AppTheme.grey400)),
          const SizedBox(height: 8),
          Text('Where is the waste?', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, fontSize: 24, color: AppTheme.grey900)),
          const SizedBox(height: 24),
          Container(
            height: 240,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), boxShadow: AppTheme.cardShadow),
            child: GoogleMap(
              initialCameraPosition: CameraPosition(target: _selectedLocation ?? const LatLng(11.2588, 75.7804), zoom: 15),
              onMapCreated: (c) => _mapController = c,
              onTap: (pos) => setState(() => _selectedLocation = pos),
              markers: _selectedLocation != null 
                ? {Marker(markerId: const MarkerId('pickup'), position: _selectedLocation!, draggable: true, onDragEnd: (p) => setState(() => _selectedLocation = p))} 
                : {},
            ),
          ),
          const SizedBox(height: 24),
          _buildTextField('PICKUP ADDRESS', _addressController, Icons.location_on_rounded),
          const SizedBox(height: 16),
          _buildTextField('ADDITIONAL NOTES', _notesController, Icons.note_rounded, maxLines: 2),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w900, color: AppTheme.grey400, letterSpacing: 1.5)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppTheme.primaryEmerald, size: 20),
            filled: true, fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppTheme.grey100)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppTheme.grey100)),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigation() {
    final bool canGoNext = (_currentStep == 0 && _selectedWasteType != null) ||
                          (_currentStep == 1 && _selectedItem != null) ||
                          (_currentStep == 2 && _selectedSlot != null) ||
                          (_currentStep == 3);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: _prevPage,
              child: Text(_currentStep == 0 ? 'CANCEL' : 'BACK', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, color: AppTheme.grey400, letterSpacing: 1)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: (canGoNext && !_isLoading) ? _nextPage : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.bgDark, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0, padding: EdgeInsets.zero,
                ),
                child: Ink(
                  decoration: BoxDecoration(gradient: AppTheme.slateGradient, borderRadius: BorderRadius.circular(16)),
                  child: Container(
                    alignment: Alignment.center,
                    child: _isLoading 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(_currentStep == 3 ? 'CONFIRM BOOKING' : 'CONTINUE', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
