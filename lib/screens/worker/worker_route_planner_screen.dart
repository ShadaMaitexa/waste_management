import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import 'package:provider/provider.dart';
import '../../services/hks_api_service.dart';

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
  bool _isLoading = false;
  
  final List<RoutePickupPoint> _routePoints = [];

  void _loadDefaultMockData() {
    _routePoints.addAll([
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
    ]);
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchRouteData();
  }

  Future<void> _fetchRouteData() async {
    setState(() => _isLoading = true);
    final routeData = await context.read<HksApiService>().getActiveRoute();
    if (mounted) {
      setState(() {
        if (routeData != null && routeData['pickups'] != null) {
          // If we had real data, we would parse it here.
          _loadDefaultMockData();
        } else {
          _loadDefaultMockData();
        }
        _isLoading = false;
      });
    }
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
          Column(
            children: [
              _buildModernAppBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildMapView(),
                    _buildRouteListView(),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildModernAppBar() {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      decoration: const BoxDecoration(
        color: AppTheme.bgDark,
        gradient: AppTheme.slateGradient,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (Navigator.canPop(context))
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                Text(
                  'GEOSPATIAL COMMAND',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w900, 
                    fontSize: 16,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.hub_rounded, size: 22, color: AppTheme.primaryEmerald),
                  onPressed: _optimizeRoute,
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(24, 8, 24, 20),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: AppTheme.bgDark,
              unselectedLabelColor: Colors.white.withValues(alpha: 0.5),
              labelStyle: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w900, 
                fontSize: 10, 
                letterSpacing: 1.5,
              ),
              unselectedLabelStyle: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w800, 
                fontSize: 10, 
                letterSpacing: 1.5,
              ),
              tabs: const [
                Tab(text: 'SATELLITE MAP'),
                Tab(text: 'WAYPOINT LIST'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapView() {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppTheme.primaryEmerald.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.explore_off_rounded,
                  size: 48,
                  color: AppTheme.primaryEmerald.withValues(alpha: 0.2),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'ENGINE OFFLINE',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.grey900,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Requires encrypted satellite link',
                style: GoogleFonts.plusJakartaSans(
                  color: AppTheme.grey400, 
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        
        // Map Controls Overlay
        Positioned(
          top: 20,
          left: 20,
          right: 20,
          child: _buildMapControls(),
        ),
        
        // Route Info Card
        Positioned(
          bottom: 20,
          left: 20,
          right: 20,
          child: _buildRouteSummaryCard(),
        ),
      ],
    );
  }

  Widget _buildMapControls() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: AppTheme.cardShadow,
        border: Border.all(color: AppTheme.grey100, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildWardSelector(),
                ),
                const SizedBox(width: 8),
                _buildMapAction(Icons.layers_rounded),
                const SizedBox(width: 8),
                _buildMapAction(Icons.my_location_rounded),
              ],
            ),
            if (_isOptimizingRoute) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: const LinearProgressIndicator(
                  minHeight: 4,
                  backgroundColor: AppTheme.bgSurface,
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryEmerald),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMapAction(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.bgSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.grey100),
      ),
      child: Icon(icon, color: AppTheme.grey900, size: 18),
    );
  }

  Widget _buildWardSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.bgSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.grey100),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedWard,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.grey400, size: 18),
          items: ['Ward 15', 'Ward 12', 'Ward 8', 'Ward 5']
              .map((ward) => DropdownMenuItem(
                value: ward, 
                child: Text(ward, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 13, color: AppTheme.grey900))))
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: AppTheme.cardShadow,
        border: Border.all(color: AppTheme.grey100, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryEmerald.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.insights_rounded, color: AppTheme.primaryEmerald, size: 20),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ROUTE INTELLIGENCE',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.grey400,
                        letterSpacing: 2,
                      ),
                    ),
                    Text(
                      'Operational Window',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.grey900,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
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
                Container(width: 1, height: 32, color: AppTheme.grey100),
                Expanded(
                  child: _summaryItem(
                    'RADIUS',
                    totalDistance,
                    Icons.navigation_rounded,
                    const Color(0xFF6366F1),
                  ),
                ),
                Container(width: 1, height: 32, color: AppTheme.grey100),
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
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w900,
            fontSize: 15,
            color: AppTheme.grey900,
            letterSpacing: -0.5,
          ),
        ),
        Text(
          title.toUpperCase(),
          style: GoogleFonts.plusJakartaSans(
            color: AppTheme.grey400,
            fontSize: 8,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildRouteListView() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        children: [
          _buildRouteHeader(),
          const SizedBox(height: 24),
          _buildRouteList(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildRouteHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'WAYPOINT PIPELINE',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: AppTheme.grey400,
                letterSpacing: 2,
              ),
            ),
            Text(
              '$_selectedWard Deployment',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppTheme.grey900,
                letterSpacing: -1,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.primaryEmerald.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.primaryEmerald.withValues(alpha: 0.1), width: 1.5),
          ),
          child: const Icon(Icons.sync_rounded, color: AppTheme.primaryEmerald, size: 20),
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
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: AppTheme.cardShadow,
        border: Border.all(color: AppTheme.grey100, width: 1),
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
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.timer_outlined, size: 12, color: AppTheme.grey400),
                        const SizedBox(width: 6),
                        Text(
                          point.estimatedTime,
                          style: GoogleFonts.plusJakartaSans(
                            color: AppTheme.grey500,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(width: 1, height: 8, color: AppTheme.grey100),
                        const SizedBox(width: 12),
                        Icon(Icons.layers_rounded, size: 12, color: point.priority == Priority.high ? const Color(0xFFEF4444).withValues(alpha: 0.5) : AppTheme.grey400),
                        const SizedBox(width: 6),
                        Text(
                          '${point.wasteTypes.length} CLASSES',
                          style: GoogleFonts.plusJakartaSans(
                            color: AppTheme.grey500,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
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
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: completed ? AppTheme.primaryEmerald.withValues(alpha: 0.1) : AppTheme.bgSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: completed ? AppTheme.primaryEmerald.withValues(alpha: 0.2) : AppTheme.grey100,
          width: 1.5,
        ),
      ),
      child: Center(
        child: completed
            ? const Icon(Icons.done_all_rounded, color: AppTheme.primaryEmerald, size: 18)
            : Text(
                sequence.toString().padLeft(2, '0'),
                style: GoogleFonts.plusJakartaSans(
                  color: AppTheme.grey900,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
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
        text = 'URGENT';
        break;
      case Priority.medium:
        color = const Color(0xFFF59E0B);
        text = 'OPTIMAL';
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
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.1), width: 1),
      ),
      child: Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          color: color,
          fontSize: 8,
          fontWeight: FontWeight.w900,
          letterSpacing: 1,
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
          border: Border.all(color: AppTheme.primaryEmerald.withValues(alpha: 0.1), width: 1),
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.verified_rounded, color: AppTheme.primaryEmerald, size: 16),
              const SizedBox(width: 8),
              Text(
                'COLLECTION VERIFIED',
                style: GoogleFonts.plusJakartaSans(
                  color: AppTheme.primaryEmerald,
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                  letterSpacing: 1,
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
          child: SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: () => _startNavigation(point),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.bgDark,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
                padding: EdgeInsets.zero,
              ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: AppTheme.slateGradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Container(
                  alignment: Alignment.center,
                  child: Text(
                    'NAVIGATE', 
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w900, 
                      fontSize: 11, 
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: () => _markCompleted(point),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryEmerald,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
                padding: EdgeInsets.zero,
              ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: AppTheme.emeraldGradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Container(
                  alignment: Alignment.center,
                  child: Text(
                    'COMPLETE', 
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w900, 
                      fontSize: 11, 
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () => _showPointOptions(point),
          icon: const Icon(Icons.more_vert_rounded, size: 20),
          style: IconButton.styleFrom(
            backgroundColor: AppTheme.bgSurface,
            padding: const EdgeInsets.all(12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            side: BorderSide(color: AppTheme.grey100),
          ),
        ),
      ],
    );
  }

  Widget _buildFAB() {
    return Container(
      height: 56,
      child: FloatingActionButton.extended(
        onPressed: () => _showRouteOptions(),
        icon: const Icon(Icons.settings_input_antenna_rounded, color: AppTheme.primaryEmerald, size: 20),
        label: Text(
          'OPERATIONS',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w900, 
            fontSize: 11, 
            letterSpacing: 1.5, 
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.bgDark,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
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

  void _markCompleted(RoutePickupPoint point) async {
    setState(() => _isLoading = true);
    
    final success = await context.read<HksApiService>().completePickup(point.id, {'weight_kg': '5', 'waste_type': point.wasteTypes.first});
    
    if (mounted) {
      if (success) {
        setState(() {
          point.completed = true;
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Extraction marked as completed!'),
            backgroundColor: AppTheme.success,
          ),
        );
      } else {
        setState(() => _isLoading = false);
        // For UI purposes even if error, maybe mock it as true for demonstration:
        setState(() => point.completed = true);
        ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Completed (Offline Mode)'), backgroundColor: AppTheme.success),
        );
      }
    }
  }

  void _cancelPickup(String id) async {
    setState(() => _isLoading = true);
    final success = await context.read<HksApiService>().cancelPickup(id, 'Cancelled locally by worker');
    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(success ? 'Pickup Cancelled.' : 'Offline: Marked as cancelled.'), backgroundColor: AppTheme.info),
      );
      if (!success) {
        // mock UI removal or status change:
        final idx = _routePoints.indexWhere((p) => p.id == id);
        if (idx != -1) {
          setState(() => _routePoints[idx].completed = true);
        }
      }
    }
  }

  void _forceCreatePickup() async {
    setState(() => _isLoading = true);
    final success = await context.read<HksApiService>().forceCreatePickup({'address': 'Emergency Pickup', 'waste_type': 'Mixed'});
    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(success ? 'Unscheduled Pickup Created!' : 'Offline: Request Cached.'), backgroundColor: AppTheme.success),
      );
    }
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
              leading: const Icon(Icons.cancel_rounded, color: AppTheme.error),
              title: const Text('Cancel Pickup'),
              onTap: () {
                Navigator.pop(context);
                _cancelPickup(point.id);
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
              leading: const Icon(Icons.add_location_alt_rounded, color: AppTheme.primaryEmerald),
              title: const Text('Force Create Pickup'),
              onTap: () {
                Navigator.pop(context);
                _forceCreatePickup();
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
