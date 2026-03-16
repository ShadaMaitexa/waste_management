import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

// Mock LatLng class for Flutter
class LatLng {
  final double latitude;
  final double longitude;

  const LatLng(this.latitude, this.longitude);
}

enum Priority { high, medium, low }

class RoutePickupPoint {
  final String id;
  final String address;
  final LatLng coordinates;
  final List<String> wasteTypes;
  final String estimatedTime;
  final Priority priority;
  bool completed;

  RoutePickupPoint({
    required this.id,
    required this.address,
    required this.coordinates,
    required this.wasteTypes,
    required this.estimatedTime,
    required this.priority,
    required this.completed,
  });
}

class WorkerRoutePlannerScreen extends StatefulWidget {
  const WorkerRoutePlannerScreen({super.key});

  @override
  State<WorkerRoutePlannerScreen> createState() => _WorkerRoutePlannerScreenState();
}

class _WorkerRoutePlannerScreenState extends State<WorkerRoutePlannerScreen> 
    with TickerProviderStateMixin {
  
  TabController? _tabController;
  String _selectedWard = 'Ward 15';
  bool _isOptimizingRoute = false;
  
  final List<RoutePickupPoint> _routePoints = [
    RoutePickupPoint(
      id: '1',
      address: '123/A, Beach Road',
      coordinates: const LatLng(11.2588, 75.7804),
      wasteTypes: ['Dry Waste', 'Wet Waste'],
      estimatedTime: '9:00 AM',
      priority: Priority.high,
      completed: false,
    ),
    RoutePickupPoint(
      id: '2', 
      address: '456/B, Marine Drive',
      coordinates: const LatLng(11.2608, 75.7824),
      wasteTypes: ['Dry Waste Only'],
      estimatedTime: '9:30 AM',
      priority: Priority.medium,
      completed: false,
    ),
    RoutePickupPoint(
      id: '3',
      address: '789/C, Calicut Beach',
      coordinates: const LatLng(11.2628, 75.7844),
      wasteTypes: ['E-waste'],
      estimatedTime: '10:00 AM',
      priority: Priority.low,
      completed: true,
    ),
    RoutePickupPoint(
      id: '4',
      address: '321/D, Sargaram Road',
      coordinates: const LatLng(11.2648, 75.7864),
      wasteTypes: ['Dry Waste', 'Wet Waste'],
      estimatedTime: '10:30 AM',
      priority: Priority.high,
      completed: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgSurface,
      appBar: AppBar(
        title: Text(
          'Geospatial Logistics',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.hub_rounded, size: 22, color: AppTheme.primaryEmerald),
            onPressed: _optimizeRoute,
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryEmerald,
          indicatorWeight: 4,
          indicatorSize: TabBarIndicatorSize.label,
          labelColor: AppTheme.grey900,
          unselectedLabelColor: AppTheme.grey400,
          labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 0.5),
          tabs: const [
            Tab(text: 'SATELLITE MAP'),
            Tab(text: 'WAYPOINT LIST'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMapView(),
          _buildRouteListView(),
        ],
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildMapView() {
    return Stack(
      children: [
        Container(
          color: AppTheme.bgSurface,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.explore_off_rounded,
                  size: 64,
                  color: AppTheme.grey200,
                ),
                const SizedBox(height: 24),
                Text(
                  'ENGINE OFFLINE',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.grey300,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Map data requires satellite connection',
                  style: GoogleFonts.inter(color: AppTheme.grey300, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
        
        // Map Controls Overlay
        Positioned(
          top: AppTheme.spacingM,
          left: AppTheme.spacingM,
          right: AppTheme.spacingM,
          child: _buildMapControls(),
        ),
        
        // Route Info Card
        Positioned(
          bottom: AppTheme.spacingM,
          left: AppTheme.spacingM,
          right: AppTheme.spacingM,
          child: _buildRouteSummaryCard(),
        ),
      ],
    );
  }

  Widget _buildMapControls() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bgCanvas.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(32),
        boxShadow: AppTheme.cardShadow,
        border: Border.all(color: AppTheme.grey100),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildWardSelector(),
                  ),
                  const SizedBox(width: 12),
                  _buildMapAction(Icons.layers_rounded),
                  const SizedBox(width: 8),
                  _buildMapAction(Icons.my_location_rounded),
                ],
              ),
              if (_isOptimizingRoute) ...[
                const SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: const LinearProgressIndicator(
                    minHeight: 4,
                    backgroundColor: AppTheme.grey100,
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryEmerald),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMapAction(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.bgSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.grey100),
      ),
      child: Icon(icon, color: AppTheme.grey600, size: 20),
    );
  }

  Widget _buildWardSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.bgSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.grey100),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedWard,
          items: ['Ward 15', 'Ward 12', 'Ward 8', 'Ward 5']
              .map((ward) => DropdownMenuItem(
                value: ward, 
                child: Text(ward, style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13))))
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedWard = value!;
            });
          },
        ),
      ),
    );
  }



  Widget _buildRouteSummaryCard() {
    final completedCount = _routePoints.where((p) => p.completed).length;
    final totalDistance = _calculateTotalDistance();
    final estimatedTime = _calculateEstimatedTime();

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bgCanvas,
        borderRadius: BorderRadius.circular(40),
        boxShadow: AppTheme.intenseShadow,
        border: Border.all(color: AppTheme.grey100),
      ),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryEmerald.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.insights_rounded, color: AppTheme.primaryEmerald, size: 22),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ROUTE INTELLIGENCE',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.grey400,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      'Target Operational Window',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.grey900,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: _summaryItem(
                    'PROGRESS',
                    '$completedCount/${_routePoints.length}',
                    Icons.verified_user_rounded,
                    AppTheme.primaryEmerald,
                  ),
                ),
                Container(width: 1, height: 40, color: AppTheme.grey100),
                Expanded(
                  child: _summaryItem(
                    'EST. RADIUS',
                    totalDistance,
                    Icons.navigation_rounded,
                    const Color(0xFF6366F1),
                  ),
                ),
                Container(width: 1, height: 40, color: AppTheme.grey100),
                Expanded(
                  child: _summaryItem(
                    'DURATION',
                    estimatedTime,
                    Icons.timer_rounded,
                    const Color(0xFFF59E0B),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryItem(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 12),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: AppTheme.grey900,
            letterSpacing: -0.5,
          ),
        ),
        Text(
          title,
          style: GoogleFonts.inter(
            color: AppTheme.grey400,
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildRouteListView() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        children: [
          _buildRouteHeader(),
          const SizedBox(height: 32),
          _buildRouteList(),
        ],
      ),
    );
  }

  Widget _buildRouteHeader() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'WAYPOINT PIPELINE',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.grey400,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  '$_selectedWard Deployment',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.grey900,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryEmerald.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.sync_rounded, color: AppTheme.primaryEmerald, size: 20),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRouteList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _routePoints.length,
      itemBuilder: (_, index) {
        final point = _routePoints[index];
        return _buildRoutePointCard(point, index + 1);
      },
    );
  }

  Widget _buildRoutePointCard(RoutePickupPoint point, int sequence) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.bgCanvas,
        borderRadius: BorderRadius.circular(32),
        boxShadow: AppTheme.cardShadow,
        border: Border.all(color: AppTheme.grey100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildSequenceBadge(sequence, point.completed),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      point.address,
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: AppTheme.grey900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.timer_outlined, size: 12, color: AppTheme.grey400),
                        const SizedBox(width: 6),
                        Text(
                          point.estimatedTime,
                          style: GoogleFonts.inter(
                            color: AppTheme.grey500,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(width: 1, height: 10, color: AppTheme.grey100),
                        const SizedBox(width: 12),
                        Icon(Icons.layers_rounded, size: 12, color: point.priority == Priority.high ? const Color(0xFFEF4444).withValues(alpha: 0.5) : AppTheme.grey400),
                        const SizedBox(width: 6),
                        Text(
                          '${point.wasteTypes.length} Classes',
                          style: GoogleFonts.inter(
                            color: AppTheme.grey500,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _buildPriorityBadge(point.priority),
            ],
          ),
          const SizedBox(height: 24),
          _buildActionButtons(point),
        ],
      ),
    );
  }

  Widget _buildSequenceBadge(int sequence, bool completed) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: completed ? AppTheme.primaryEmerald.withValues(alpha: 0.1) : AppTheme.bgSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: completed ? AppTheme.primaryEmerald.withValues(alpha: 0.2) : AppTheme.grey100,
          width: 2,
        ),
      ),
      child: Center(
        child: completed
            ? const Icon(Icons.done_all_rounded, color: AppTheme.primaryEmerald, size: 20)
            : Text(
                sequence.toString().padLeft(2, '0'),
                style: GoogleFonts.plusJakartaSans(
                  color: AppTheme.grey900,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
      ),
    );
  }

  Widget _buildPriorityBadge(Priority priority) {
    Color color;
    String text;
    
    switch (priority) {
      case Priority.high:
        color = const Color(0xFFEF4444);
        text = 'PRIORITY';
        break;
      case Priority.medium:
        color = const Color(0xFFF59E0B);
        text = 'REVENUE';
        break;
      case Priority.low:
        color = const Color(0xFF6366F1);
        text = 'STANDARD';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildActionButtons(RoutePickupPoint point) {
    if (point.completed) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.primaryEmerald.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.primaryEmerald.withValues(alpha: 0.1)),
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.verified_rounded, color: AppTheme.primaryEmerald, size: 16),
              const SizedBox(width: 8),
              Text(
                'COLLECTION VERIFIED',
                style: GoogleFonts.inter(
                  color: AppTheme.primaryEmerald,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => _startNavigation(point),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.bgDark,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 0,
            ),
            child: Text('NAVIGATE', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 0.5)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () => _markCompleted(point),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryEmerald,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 0,
            ),
            child: Text('COMPLETE', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 0.5)),
          ),
        ),
        const SizedBox(width: 12),
        IconButton(
          onPressed: () => _showPointOptions(point),
          icon: const Icon(Icons.more_vert_rounded, size: 20),
          style: IconButton.styleFrom(
            backgroundColor: AppTheme.bgSurface,
            padding: const EdgeInsets.all(12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            side: const BorderSide(color: AppTheme.grey100),
          ),
        ),
      ],
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: () => _showRouteOptions(),
      icon: const Icon(Icons.settings_input_antenna_rounded, color: Colors.white, size: 20),
      label: Text(
        'OPERATIONS',
        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 1, color: Colors.white),
      ),
      backgroundColor: AppTheme.bgDark,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  String _calculateTotalDistance() {
    return '12.5 km';
  }

  String _calculateEstimatedTime() {
    return '4.2 hrs';
  }

  void _optimizeRoute() async {
    setState(() {
      _isOptimizingRoute = true;
    });

    // Simulate route optimization
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      setState(() {
        _isOptimizingRoute = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Route optimized successfully!'),
          backgroundColor: AppTheme.success,
        ),
      );
    }
  }

  void _startNavigation(RoutePickupPoint point) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Starting navigation to ${point.address}'),
        backgroundColor: AppTheme.info,
      ),
    );
  }

  void _markCompleted(RoutePickupPoint point) {
    setState(() {
      point.completed = true;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pickup marked as completed!'),
        backgroundColor: AppTheme.success,
      ),
    );
  }

  void _showPointOptions(RoutePickupPoint point) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Container(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.warning, color: AppTheme.warning),
              title: const Text('Report Issue'),
              onTap: () {
                Navigator.pop(context);
                // Handle issue reporting
              },
            ),
            ListTile(
              leading: const Icon(Icons.skip_next, color: AppTheme.info),
              title: const Text('Skip Pickup'),
              onTap: () {
                Navigator.pop(context);
                // Handle skip
              },
            ),
             ListTile(
              leading: const Icon(Icons.contact_phone, color: AppTheme.primaryGreen),
              title: const Text('Call Resident'),
              onTap: () {
                Navigator.pop(context);
                // Handle call
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showRouteOptions() {
    showModalBottomSheet(
      context: context,
      builder: (_) => Container(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('Recalculate Route'),
              onTap: () {
                Navigator.pop(context);
                _optimizeRoute();
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share Route Progress'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
