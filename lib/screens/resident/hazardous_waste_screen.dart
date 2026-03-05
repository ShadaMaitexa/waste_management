import 'package:flutter/material.dart';
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
      'title': 'Yellow\nCategory',
      'color': const Color(0xFFFFD54F),
      'bgActive': Colors.transparent,
      'bgInactive': Colors.transparent,
      'textActive': const Color(0xFFFFD54F),
      'textInactive': const Color(0xFFFFD54F),
      'icon': Icons.coronavirus_outlined
    },
    {
      'title': 'Red\nCategory',
      'color': const Color(0xFFE53935),
      'bgActive': const Color(0xFFE53935),
      'bgInactive': const Color(0xFFE53935),
      'textActive': Colors.white,
      'textInactive': Colors.white,
      'icon': Icons.coronavirus_outlined
    },
    {
      'title': 'White\nCategory',
      'color': Colors.white,
      'bgActive': Colors.white,
      'bgInactive': Colors.white,
      'textActive': Colors.black,
      'textInactive': Colors.black,
      'icon': Icons.coronavirus_outlined
    },
    {
      'title': 'Blue\nCategory',
      'color': const Color(0xFF42A5F5),
      'bgActive': const Color(0xFF42A5F5),
      'bgInactive': const Color(0xFF42A5F5),
      'textActive': Colors.black,
      'textInactive': Colors.black,
      'icon': Icons.coronavirus_outlined
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
      {'name': 'Syringes', 'icon': Icons.vaccines_rounded},
      {'name': 'Gloves', 'icon': Icons.back_hand_rounded},
      {'name': 'IV Tubes', 'icon': Icons.bubble_chart_rounded},
    ],
    2: [
      {'name': 'Needles', 'icon': Icons.push_pin_rounded},
      {'name': 'Scalpels', 'icon': Icons.content_cut_rounded},
    ],
    3: [
      {'name': 'Glass Vials', 'icon': Icons.science_rounded},
      {'name': 'Broken Glass', 'icon': Icons.view_in_ar_rounded},
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
    // Dark theme specific for this exact screen to match Akri completely
    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F0F0F),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0F0F0F),
          elevation: 0,
          foregroundColor: Colors.white,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'Select your item',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18, color: Colors.white),
          ),
          centerTitle: false,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: IconButton(
                icon: const Icon(Icons.help_outline_rounded, color: Colors.white),
                onPressed: () {
                  // Navigate to FAQs
                  Navigator.pushNamed(context, '/faq');
                },
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            _buildTopBanner(),
            const SizedBox(height: 16),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSideMenu(),
                  _buildItemsList(),
                ],
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFF8E24AA), Color(0xFF5E35B1)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          border: Border.all(color: Colors.white24, width: 1),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF8E24AA).withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Domestic Hazardous Waste\n(incl Sanitary)',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, height: 1.4),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    const Text(
                      '₹45',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 28),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      '+gst\n/kg',
                      style: TextStyle(color: Colors.white70, fontSize: 10, height: 1.1),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.yellow.shade700.withOpacity(0.8), shape: BoxShape.circle),
              child: const Icon(Icons.coronavirus_rounded, color: Colors.black87, size: 28),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSideMenu() {
    return Container(
      width: 100,
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.only(topRight: Radius.circular(24)),
      ),
      child: ListView.builder(
        itemCount: _tabs.length,
        itemBuilder: (context, index) {
          final tab = _tabs[index];
          final isSelected = _selectedTabIndex == index;

          return GestureDetector(
            onTap: () => setState(() => _selectedTabIndex = index),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8, left: 8, right: 8, top: 4),
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: tab['bgInactive'],
                borderRadius: BorderRadius.circular(16),
                border: isSelected && index == 0
                    ? Border.all(color: const Color(0xFFFFD54F), width: 1.5)
                    : null,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    tab['icon'],
                    color: tab['textInactive'],
                    size: 28,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    tab['title'],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: tab['textInactive'],
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      fontSize: 12,
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

  Widget _buildItemsList() {
    final items = _categoryItems[_selectedTabIndex] ?? [];

    return Expanded(
      child: Container(
        color: const Color(0xFF1E1E1E),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            final isSelected = _selectedItems.contains(item['name']);

            return GestureDetector(
              onTap: () => _toggleItem(item['name']),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  // Emulate the Akri style yellow-grey gradient pill
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFC4AD88),
                      const Color(0xFF8E836A).withOpacity(0.8),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(item['icon'], color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        item['name'],
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.primaryGreen : Colors.black,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? AppTheme.primaryGreen : Colors.black,
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.white, size: 20)
                          : null,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    if (_selectedItems.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            offset: const Offset(0, -4),
            blurRadius: 10,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Text(
                '${_selectedItems.length} items selected',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: () {
                // Return to previous screen with selected items
                Navigator.of(context).pop(_selectedItems);
              },
              child: const Text('Continue', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
