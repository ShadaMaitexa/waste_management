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
  late TextEditingController _addressController;
  final _notesController = TextEditingController();

  static const _wasteOptions = [
    {'key': 'dry', 'label': 'Dry Waste', 'icon': Icons.feed_rounded},
    {'key': 'wet', 'label': 'Wet Waste', 'icon': Icons.water_drop_rounded},
    {'key': 'organic', 'label': 'Organic', 'icon': Icons.eco_rounded},
    {'key': 'recyclable', 'label': 'Recyclable', 'icon': Icons.recycling_rounded},
    {'key': 'e-waste', 'label': 'E-Waste', 'icon': Icons.memory_rounded},
    {'key': 'hazardous', 'label': 'Hazardous', 'icon': Icons.warning_rounded},
    {'key': 'mixed', 'label': 'Mixed', 'icon': Icons.delete_sweep_rounded},
  ];

  static const _itemOptionsMap = {
    'dry': ['Paper', 'Cardboard', 'Plastic Wrapper', 'Glass Bottle', 'Metal Scrap', 'Textile'],
    'wet': ['Food Scraps', 'Vegetable Peels', 'Fruit Waste', 'Meat/Dairy'],
    'organic': ['Garden Waste', 'Leaves', 'Grass Clippings', 'Wood'],
    'recyclable': ['Plastic Bottle (HDPE)', 'Aluminum Can', 'Glass Container', 'Newspaper'],
    'e-waste': ['Battery', 'Smartphone', 'Laptop', 'Cables', 'Charger'],
    'hazardous': ['Paint', 'Chemicals', 'Medicines', 'Oil'],
    'mixed': ['General House Waste', 'Sanitary Waste'],
  };

  String? _selectedWasteType;
  String? _selectedItem;
  PickupSlot? _selectedSlot;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthService>(context, listen: false).currentUser;
    _addressController = TextEditingController(text: (user?.address != null && user!.address.isNotEmpty) ? user.address : (user?.wardNumber != null ? 'Smart Residence, Ward ${user!.wardNumber}' : 'Default Ward 15'));
    
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

  void _selectWasteType(String key) {
    setState(() {
      _selectedWasteType = key;
      _selectedItem = null; // Reset item when category changes
    });
  }

  void _selectItem(String item) {
    setState(() => _selectedItem = item);
  }

  Future<void> _submitPickup() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedWasteType == null) {
      _showError('Please select a waste category');
      return;
    }
    if (_selectedItem == null) {
      _showError('Please select a specific item');
      return;
    }
    if (_selectedSlot == null) {
      _showError('Please select a collection slot');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final pickupService = Provider.of<PickupService>(context, listen: false);
      final slotId = int.tryParse(_selectedSlot!.id) ?? 0;

      final success = await pickupService.createPickup(
        item: _selectedItem!,
        address: _addressController.text.trim(),
        date: _selectedSlot!.date,
        slotId: slotId,
        wasteType: _selectedWasteType!,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pickup scheduled successfully!'), backgroundColor: AppTheme.success),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) _showError('Error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppTheme.error),
    );
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
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildStepHeader('01', 'CATEGORY'),
                        const SizedBox(height: 12),
                        _buildWasteTypeGrid(),
                        
                        if (_selectedWasteType != null) ...[
                          const SizedBox(height: 32),
                          _buildStepHeader('02', 'SPECIFIC ITEM'),
                          const SizedBox(height: 12),
                          _buildItemOptions(),
                        ],

                        const SizedBox(height: 32),
                        _buildStepHeader('03', 'TIME SLOT'),
                        const SizedBox(height: 12),
                        _buildSlotSelection(),

                        const SizedBox(height: 32),
                        _buildStepHeader('04', 'PICKUP DETAILS'),
                        const SizedBox(height: 12),
                        _buildServiceParameters(),
                        const SizedBox(height: 40),

                        _buildSubmitButton(),
                        const SizedBox(height: 60),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 160.0,
      pinned: true,
      backgroundColor: AppTheme.bgDark,
      automaticallyImplyLeading: false,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(color: AppTheme.bgDark, gradient: AppTheme.slateGradient),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Book Pickup',
                  style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -1.2),
                ),
                Text(
                  'WASTE MANAGEMENT SYSTEM',
                  style: GoogleFonts.plusJakartaSans(color: AppTheme.primaryEmerald, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepHeader(String step, String title) {
    return Row(
      children: [
        Container(
          width: 28, height: 28,
          decoration: BoxDecoration(color: AppTheme.bgDark, borderRadius: BorderRadius.circular(8)),
          alignment: Alignment.center,
          child: Text(step, style: GoogleFonts.plusJakartaSans(color: AppTheme.primaryEmerald, fontWeight: FontWeight.w900, fontSize: 11)),
        ),
        const SizedBox(width: 12),
        Text(title, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, fontSize: 13, color: AppTheme.grey900, letterSpacing: 1.5)),
      ],
    );
  }

  Widget _buildWasteTypeGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1,
      ),
      itemCount: _wasteOptions.length,
      itemBuilder: (context, index) {
        final option = _wasteOptions[index];
        final isSelected = _selectedWasteType == option['key'];
        return GestureDetector(
          onTap: () => _selectWasteType(option['key'] as String),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primaryEmerald : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isSelected ? AppTheme.primaryEmerald : AppTheme.grey100, width: 1.5),
              boxShadow: isSelected ? [BoxShadow(color: AppTheme.primaryEmerald.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : AppTheme.cardShadow,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(option['icon'] as IconData, color: isSelected ? Colors.white : AppTheme.grey400, size: 28),
                const SizedBox(height: 8),
                Text(
                  (option['label'] as String).toUpperCase(),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(color: isSelected ? Colors.white : AppTheme.grey900, fontWeight: FontWeight.w900, fontSize: 8, letterSpacing: 0.5),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildItemOptions() {
    final items = _itemOptionsMap[_selectedWasteType] ?? [];
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: items.map((item) {
        final isSelected = _selectedItem == item;
        return FilterChip(
          selected: isSelected,
          label: Text(item),
          labelStyle: GoogleFonts.plusJakartaSans(
            fontSize: 12, fontWeight: FontWeight.w700, 
            color: isSelected ? Colors.white : AppTheme.grey700
          ),
          onSelected: (_) => _selectItem(item),
          backgroundColor: Colors.white,
          selectedColor: AppTheme.primaryEmerald,
          checkmarkColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: isSelected ? AppTheme.primaryEmerald : AppTheme.grey200)),
        );
      }).toList(),
    );
  }

  Widget _buildSlotSelection() {
    return Consumer<PickupService>(
      builder: (context, service, child) {
        if (service.isLoading) return Shimmer.fromColors(baseColor: AppTheme.grey50, highlightColor: Colors.white, child: Container(height: 100, color: Colors.white));
        if (service.availableSlots.isEmpty) return Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: const Text('No operational slots available right now.'));

        return SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: service.availableSlots.length,
            itemBuilder: (context, index) {
              final slot = service.availableSlots[index];
              final isSelected = _selectedSlot?.id == slot.id;
              return GestureDetector(
                onTap: () => setState(() => _selectedSlot = slot),
                child: Container(
                  width: 140,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.bgDark : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: isSelected ? AppTheme.bgDark : AppTheme.grey100, width: 1.5),
                    boxShadow: AppTheme.cardShadow,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(DateFormat('MMM dd').format(slot.date), style: GoogleFonts.plusJakartaSans(color: isSelected ? Colors.white : AppTheme.grey900, fontWeight: FontWeight.w900, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text(slot.formatTime(context), style: GoogleFonts.inter(color: isSelected ? AppTheme.primaryEmerald : AppTheme.grey400, fontWeight: FontWeight.w700, fontSize: 12)),
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

  Widget _buildServiceParameters() {
    return Column(
      children: [
        _buildTextField('PICKUP ADDRESS', _addressController, Icons.location_on_rounded),
        const SizedBox(height: 20),
        _buildTextField('PICKUP NOTES', _notesController, Icons.note_add_rounded, maxLines: 3),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w900, color: AppTheme.grey400, letterSpacing: 1.5)),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppTheme.grey400, size: 20),
            filled: true, fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppTheme.grey100)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppTheme.grey100)),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      height: 64,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitPickup,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.bgDark, foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0, padding: EdgeInsets.zero,
        ),
        child: Ink(
          decoration: BoxDecoration(gradient: AppTheme.slateGradient, borderRadius: BorderRadius.circular(20)),
          child: Container(
            alignment: Alignment.center,
            child: _isLoading 
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                : Text('CONFIRM BOOKING', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 14)),
          ),
        ),
      ),
    );
  }
}
