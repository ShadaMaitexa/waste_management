import 'package:flutter/material.dart';
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
      appBar: AppBar(
        title: const Text('Route Planner'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _optimizeRoute,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.map), text: 'Map View'),
            Tab(icon: Icon(Icons.list), text: 'Route List'),
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
        // Mock Map Container
        Container(
          color: Colors.grey[200],
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.map,
                  size: 80,
                  color: Colors.grey,
                ),
                SizedBox(height: AppTheme.spacingM),
                Text(
                  'Interactive Map View',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: AppTheme.spacingS),
                Text(
                  'Google Maps integration would be displayed here',
                  style: TextStyle(color: Colors.grey),
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildWardSelector(),
                ),
                const SizedBox(width: AppTheme.spacingM),
                Expanded(
                  child: _buildOptimizeButton(),
                ),
              ],
            ),
            if (_isOptimizingRoute) ...[
              const SizedBox(height: AppTheme.spacingM),
              const LinearProgressIndicator(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWardSelector() {
    return DropdownButtonFormField<String>(
      value: _selectedWard,
      decoration: InputDecoration(
        labelText: 'Ward',
        prefixIcon: const Icon(Icons.location_city, color: AppTheme.primaryGreen),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
        ),
      ),
      items: ['Ward 15', 'Ward 12', 'Ward 8', 'Ward 5']
          .map((ward) => DropdownMenuItem(value: ward, child: Text(ward)))
          .toList(),
      onChanged: (value) {
        setState(() {
          _selectedWard = value!;
        });
      },
    );
  }

  Widget _buildOptimizeButton() {
    return ElevatedButton.icon(
      onPressed: _isOptimizingRoute ? null : _optimizeRoute,
      icon: _isOptimizingRoute
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.route, size: 16),
      label: Text(_isOptimizingRoute ? 'Optimizing...' : 'Optimize Route'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 48),
      ),
    );
  }

  Widget _buildRouteSummaryCard() {
    final completedCount = _routePoints.where((p) => p.completed).length;
    final totalDistance = _calculateTotalDistance();
    final estimatedTime = _calculateEstimatedTime();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.route, color: AppTheme.primaryGreen),
                const SizedBox(width: AppTheme.spacingS),
                Text(
                  'Route Summary',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingM),
            Row(
              children: [
                Expanded(
                  child: _summaryItem(
                    'Completed',
                    '$completedCount/${_routePoints.length}',
                    Icons.check_circle,
                    AppTheme.success,
                  ),
                ),
                Expanded(
                  child: _summaryItem(
                    'Distance',
                    totalDistance,
                    Icons.straighten,
                    AppTheme.info,
                  ),
                ),
                Expanded(
                  child: _summaryItem(
                    'ETA',
                    estimatedTime,
                    Icons.access_time,
                    AppTheme.warning,
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
        const SizedBox(height: AppTheme.spacingXS),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.grey600,
          ),
        ),
      ],
    );
  }

  Widget _buildRouteListView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRouteHeader(),
          const SizedBox(height: AppTheme.spacingM),
          _buildRouteList(),
        ],
      ),
    );
  }

  Widget _buildRouteHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Today\'s Route',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTheme.spacingS),
            Text(
              _selectedWard,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.primaryGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppTheme.spacingM),
            Row(
              children: [
                _headerInfoItem('Total Stops', '${_routePoints.length}'),
                _headerInfoItem('Completed', '${_routePoints.where((p) => p.completed).length}'),
                _headerInfoItem('Remaining', '${_routePoints.where((p) => !p.completed).length}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerInfoItem(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryGreen,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.grey600,
            ),
          ),
        ],
      ),
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
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildSequenceBadge(sequence, point.completed),
                const SizedBox(width: AppTheme.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        point.address,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingXS),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: AppTheme.grey600,
                          ),
                          const SizedBox(width: AppTheme.spacingXS),
                          Text(
                            point.estimatedTime,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.grey600,
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
            const SizedBox(height: AppTheme.spacingM),
            _buildWasteTypes(point.wasteTypes),
            const SizedBox(height: AppTheme.spacingM),
            _buildActionButtons(point),
          ],
        ),
      ),
    );
  }

  Widget _buildSequenceBadge(int sequence, bool completed) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: completed ? AppTheme.success : AppTheme.primaryGreen,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: completed
            ? const Icon(Icons.check, color: Colors.white, size: 16)
            : Text(
                '$sequence',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
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
        color = AppTheme.error;
        text = 'High';
        break;
      case Priority.medium:
        color = AppTheme.warning;
        text = 'Medium';
        break;
      case Priority.low:
        color = AppTheme.info;
        text = 'Low';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingS,
        vertical: AppTheme.spacingXS,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusS),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildWasteTypes(List<String> wasteTypes) {
    return Wrap(
      spacing: AppTheme.spacingS,
      runSpacing: AppTheme.spacingS,
      children: wasteTypes.map((type) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingS,
            vertical: AppTheme.spacingXS,
          ),
          decoration: BoxDecoration(
            color: AppTheme.grey100,
            borderRadius: BorderRadius.circular(AppTheme.radiusS),
          ),
          child: Text(
            type,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.grey700,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActionButtons(RoutePickupPoint point) {
    if (point.completed) {
      return Row(
        children: [
          const Icon(Icons.check_circle, color: AppTheme.success, size: 16),
          const SizedBox(width: AppTheme.spacingXS),
          const Text(
            'Completed',
            style: TextStyle(
              color: AppTheme.success,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _startNavigation(point),
            icon: const Icon(Icons.navigation, size: 16),
            label: const Text('Navigate'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: AppTheme.spacingM),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _markCompleted(point),
            icon: const Icon(Icons.check, size: 16),
            label: const Text('Complete'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.success,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: AppTheme.spacingM),
        IconButton(
          onPressed: () => _showPointOptions(point),
          icon: const Icon(Icons.more_vert),
          style: IconButton.styleFrom(
            backgroundColor: AppTheme.grey100,
          ),
        ),
      ],
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: () => _showRouteOptions(),
      icon: const Icon(Icons.more_horiz),
      label: const Text('Options'),
      backgroundColor: AppTheme.primaryGreen,
      foregroundColor: Colors.white,
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
