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
            'Sanitary & Bio-Waste',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.white, letterSpacing: -0.5),
          ),
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton(
                icon: const Icon(Icons.help_outline_rounded, color: Colors.white70),
                onPressed: () => Navigator.pushNamed(context, '/help'),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            _buildTopBanner(),
            const SizedBox(height: 24),
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
    final tab = _tabs[_selectedTabIndex];
    return Container(
        margin: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        height: 100,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF1A1A1A),
              tab['color'].withValues(alpha: 0.15),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: tab['color'].withValues(alpha: 0.2), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4), // Darker shadow for slate theme
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Biomedical Waste',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: -0.5),
                  ),
                  Text(
                    'SAFE DISPOSAL PROTOCOL',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1),
                  ),
                ],
              ),
            ),
            const VerticalDivider(color: Colors.white24, width: 32),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    const Text(
                      '₹45',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 24),
                    ),
                    const SizedBox(width: AppTheme.spacingS),
                    Text(
                      '/KG',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 10, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                Text(
                  '+GST EXTRA',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 8, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ],
        ),
    );
  }

  Widget _buildSideMenu() {
    return Container(
      width: 90,
      margin: const EdgeInsets.only(left: 20, right: 12),
      child: ListView.builder(
        itemCount: _tabs.length,
        itemBuilder: (context, index) {
          final tab = _tabs[index];
          final isSelected = _selectedTabIndex == index;

          return GestureDetector(
            onTap: () => setState(() => _selectedTabIndex = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withValues(alpha: 0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: isSelected 
                    ? Border.all(color: tab['color'].withValues(alpha: 0.5), width: 1.5)
                    : Border.all(color: Colors.white.withValues(alpha: 0.05), width: 1.5),
              ),
              child: Column(
                children: [
                  Icon(
                    tab['icon'],
                    color: isSelected ? tab['color'] : Colors.white24,
                    size: 24,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    tab['title'].split('\n')[0].toUpperCase(),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white24,
                      fontWeight: FontWeight.w900,
                      fontSize: 10,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    tab['title'].split('\n')[1].toUpperCase(),
                    style: TextStyle(
                      color: isSelected ? tab['color'] : Colors.white24,
                      fontWeight: FontWeight.w700,
                      fontSize: 8,
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

  Widget _buildItemsList() {
    final items = _categoryItems[_selectedTabIndex] ?? [];

    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 20),
        child: ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            final isSelected = _selectedItems.contains(item['name']);

            return GestureDetector(
              onTap: () => _toggleItem(item['name']),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF2C2C2E),
                      const Color(0xFF1C1C1E),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: isSelected ? AppTheme.primaryGreen.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.05),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppTheme.spacingS),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(AppTheme.radiusS),
                      ),
                      child: Icon(item['icon'], color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        item['name'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    if (isSelected)
                      const Icon(Icons.check_circle_rounded, color: AppTheme.primaryGreen, size: 24)
                    else
                      Icon(Icons.add_circle_outline_rounded, color: Colors.white.withValues(alpha: 0.2), size: 24),
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
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            offset: const Offset(0, -10),
            blurRadius: 30,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_selectedItems.length} ITEMS SELECTED',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5),
                ),
                Text(
                  'READY FOR COLLECTION',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 10, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 32),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppTheme.primaryGreen, AppTheme.secondaryGreen]),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryGreen.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(_selectedItems),
              child: const Text(
                'CONFIRM',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
