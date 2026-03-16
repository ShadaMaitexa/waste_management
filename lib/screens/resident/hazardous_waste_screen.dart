import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class HazardousWasteScreen extends StatefulWidget {
  const HazardousWasteScreen({super.key});

  @override
  State<HazardousWasteScreen> createState() => _HazardousWasteScreenState();
}

class _HazardousWasteScreenState extends State<HazardousWasteScreen> {
  int _selectedTabIndex = 0;
  final List<String> _selectedItems = [];

  final List<Map<String, dynamic>> _tabs = [
    {
      'title': 'Yellow\nSanitary',
      'color': const Color(0xFFFFD54F),
      'icon': Icons.clean_hands_rounded
    },
    {
      'title': 'Red\nClinical',
      'color': const Color(0xFFE53935),
      'icon': Icons.medical_information_rounded
    },
    {
      'title': 'White\nSharps',
      'color': Colors.white,
      'icon': Icons.biotech_rounded
    },
    {
      'title': 'Blue\nMedicine',
      'color': const Color(0xFF42A5F5),
      'icon': Icons.medication_rounded
    },
  ];

  final Map<int, List<Map<String, dynamic>>> _categoryItems = {
    0: [
      {'name': 'Kids Diaper', 'icon': Icons.child_care_rounded},
      {'name': 'Adult Diaper', 'icon': Icons.elderly_rounded},
      {'name': 'Sanitary Pad', 'icon': Icons.water_drop_rounded},
      {'name': 'Medical Waste', 'icon': Icons.medical_services_rounded},
      {'name': 'Discreet', 'icon': Icons.shopping_bag_rounded},
      {'name': 'Hair', 'icon': Icons.face_retouching_natural_rounded},
    ],
    1: [
      {'name': 'Urine Bags', 'icon': Icons.bloodtype_outlined},
      {'name': 'Tubing', 'icon': Icons.linear_scale_rounded},
      {'name': 'Intravenous Tubes', 'icon': Icons.biotech_rounded},
      {'name': 'Gloves', 'icon': Icons.back_hand_rounded},
      {'name': 'Catheters', 'icon': Icons.device_thermostat_rounded},
    ],
    2: [
      {'name': 'Scalpels', 'icon': Icons.content_cut_rounded},
      {'name': 'Needles', 'icon': Icons.push_pin_rounded},
      {'name': 'Blades', 'icon': Icons.architecture_rounded},
    ],
    3: [
      {'name': 'Medicine Vials', 'icon': Icons.science_rounded},
      {'name': 'Ampoules', 'icon': Icons.vaccines_rounded},
    ],
  };

  void _toggleItem(String itemName) {
    setState(() {
      if (_selectedItems.contains(itemName)) {
        _selectedItems.remove(itemName);
      } else {
        _selectedItems.add(itemName);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgSurface,
      appBar: AppBar(
        title: Text(
          'SPECIALIZED WASTE',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800, 
            fontSize: 12,
            letterSpacing: 2,
            color: AppTheme.grey400,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline_rounded, size: 20),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          _buildInfoBanner(),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSidebar(),
                _buildItemsGrid(),
              ],
            ),
          ),
          _buildActionFooter(),
        ],
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.bgCanvas,
        borderRadius: BorderRadius.circular(28),
        boxShadow: AppTheme.cardShadow,
        border: Border.all(color: AppTheme.grey100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryEmerald.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.security_rounded, color: AppTheme.primaryEmerald, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SAFETY PROTOCOL ACTIVE',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.grey400,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Adhere to designated disposal geometry.',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.grey800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildSidebar() {
    return Container(
      width: 96,
      child: ListView.builder(
        padding: const EdgeInsets.only(left: 24, right: 12),
        itemCount: _tabs.length,
        itemBuilder: (context, index) {
          final tab = _tabs[index];
          final isSelected = _selectedTabIndex == index;
          final color = tab['color'] as Color;

          return GestureDetector(
            onTap: () => setState(() => _selectedTabIndex = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: isSelected ? color.withValues(alpha: 0.1) : AppTheme.bgCanvas,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? color.withValues(alpha: 0.3) : AppTheme.grey100,
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    tab['icon'],
                    color: isSelected ? color : AppTheme.grey300,
                    size: 24,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    tab['title'].split('\n')[1].toUpperCase(),
                    style: GoogleFonts.inter(
                      color: isSelected ? color : AppTheme.grey400,
                      fontWeight: FontWeight.w900,
                      fontSize: 9,
                      letterSpacing: 0.5,
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

  Widget _buildItemsGrid() {
    final items = _categoryItems[_selectedTabIndex] ?? [];

    return Expanded(
      child: GridView.builder(
        padding: const EdgeInsets.only(right: 24, bottom: 24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final isSelected = _selectedItems.contains(item['name']);
          final tabColor = _tabs[_selectedTabIndex]['color'] as Color;

          return GestureDetector(
            onTap: () => _toggleItem(item['name']),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.bgCanvas : AppTheme.bgCanvas.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isSelected ? tabColor.withValues(alpha: 0.4) : AppTheme.grey100,
                  width: 1.5,
                ),
                boxShadow: isSelected ? AppTheme.smoothShadow : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected ? tabColor.withValues(alpha: 0.1) : AppTheme.bgSurface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      item['icon'],
                      color: isSelected ? tabColor : AppTheme.grey400,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    item['name'].toUpperCase(),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      color: isSelected ? AppTheme.grey900 : AppTheme.grey500,
                      fontWeight: FontWeight.w800,
                      fontSize: 10,
                      letterSpacing: 0.2,
                    ),
                  ),
                  if (isSelected)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Icon(Icons.check_circle_rounded, color: tabColor, size: 16),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionFooter() {
    if (_selectedItems.isEmpty) return const SizedBox(height: 32);

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
      decoration: BoxDecoration(
        color: AppTheme.bgDark,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.bgDark.withValues(alpha: 0.4),
            offset: const Offset(0, -10),
            blurRadius: 30,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_selectedItems.length} SELECTIONS',
                    style: GoogleFonts.inter(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontWeight: FontWeight.w800,
                      fontSize: 10,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${_selectedItems.length * 45} DIVIDEND',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 56,
                width: 140,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, _selectedItems),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryEmerald,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: Text(
                    'VALIDATE',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                      fontSize: 12,
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
}
