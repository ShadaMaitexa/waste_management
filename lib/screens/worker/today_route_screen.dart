import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';

class TodayRouteScreen extends StatefulWidget {
  const TodayRouteScreen({super.key});

  @override
  State<TodayRouteScreen> createState() => _TodayRouteScreenState();
}

class _TodayRouteScreenState extends State<TodayRouteScreen> {
  bool _isOnDuty = false;
  String _currentStatus = 'Not Started';
  final List<Map<String, dynamic>> _todaysPickups = [];

  @override
  void initState() {
    super.initState();
    _todaysPickups.addAll(_getMockTodaysPickups());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Today's Route"),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.navigation),
            onPressed: _startNavigation,
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: _showMoreOptions,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStatusHeader(),
          _buildRouteOverview(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              itemCount: _todaysPickups.length,
              itemBuilder: (_, index) =>
                  _buildPickupCard(_todaysPickups[index]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomActionBar(),
    );
  }

  // ---------------- STATUS HEADER ----------------

  Widget _buildStatusHeader() {
    Color statusColor;
    IconData statusIcon;

    switch (_currentStatus) {
      case 'On Route':
        statusColor = AppTheme.info;
        statusIcon = Icons.directions_walk;
        break;
      case 'At Pickup':
        statusColor = AppTheme.warning;
        statusIcon = Icons.location_on;
        break;
      case 'Completed':
        statusColor = AppTheme.success;
        statusIcon = Icons.check_circle;
        break;
      default:
        statusColor = AppTheme.grey600;
        statusIcon = Icons.pause_circle_filled;
    }

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [statusColor, statusColor.withOpacity(0.85)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(statusIcon, color: Colors.white, size: 32),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Status: $_currentStatus',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Ward 15, Kozhikode',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              _buildStatusToggle(),
            ],
          ),
          const SizedBox(height: AppTheme.spacingM),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _StatusMetric('Pickups', '12'),
              _StatusMetric('Completed', '8'),
              _StatusMetric('Remaining', '4'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusToggle() {
    return Switch(
      value: _isOnDuty,
      activeColor: Colors.white,
      onChanged: (value) {
        setState(() {
          _isOnDuty = value;
          _currentStatus = value ? 'On Route' : 'Not Started';
        });
      },
    );
  }

  // ---------------- ROUTE OVERVIEW ----------------

  Widget _buildRouteOverview() {
    return Card(
      margin: const EdgeInsets.all(AppTheme.spacingM),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.route, color: AppTheme.primaryGreen),
                SizedBox(width: 8),
                Text(
                  'Route Overview',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingM),
            LinearProgressIndicator(
              value: 8 / 12,
              backgroundColor: AppTheme.grey200,
              valueColor:
                  const AlwaysStoppedAnimation(AppTheme.primaryGreen),
            ),
            const SizedBox(height: 8),
            Row(
              children: const [
                Icon(Icons.access_time, size: 16),
                SizedBox(width: 6),
                Text('Estimated completion: 2:30 PM'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- PICKUP CARD ----------------

  Widget _buildPickupCard(Map<String, dynamic> pickup) {
    Color color;
    String label;

    switch (pickup['status']) {
      case 'completed':
        color = AppTheme.success;
        label = 'Completed';
        break;
      case 'in_progress':
        color = AppTheme.warning;
        label = 'In Progress';
        break;
      default:
        color = AppTheme.info;
        label = 'Pending';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Pickup #${pickup['id']}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Chip(
                  label: Text(label),
                  backgroundColor: color.withOpacity(0.1),
                  labelStyle: TextStyle(color: color),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(DateFormat('h:mm a').format(pickup['scheduledTime'])),
            const SizedBox(height: 8),
            _detail(Icons.location_on, pickup['address']),
            _detail(Icons.person, pickup['residentName']),
            _detail(Icons.phone, pickup['phone']),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              children: (pickup['wasteTypes'] as List<String>)
                  .map((e) => Chip(label: Text(e)))
                  .toList(),
            ),
            const SizedBox(height: 8),
            _buildActionButtons(pickup),
          ],
        ),
      ),
    );
  }

  Widget _detail(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16),
        const SizedBox(width: 6),
        Expanded(child: Text(text)),
      ],
    );
  }

  // ---------------- ACTIONS ----------------

  Widget _buildActionButtons(Map<String, dynamic> pickup) {
    if (pickup['status'] == 'pending') {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _startPickup(pickup),
              child: const Text('Start'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton(
              onPressed: () => _callResident(pickup),
              child: const Text('Call'),
            ),
          ),
        ],
      );
    }

    if (pickup['status'] == 'in_progress') {
      return ElevatedButton(
        onPressed: () => _completePickup(pickup),
        child: const Text('Complete Pickup'),
      );
    }

    return OutlinedButton(
      onPressed: () => _viewDetails(pickup),
      child: const Text('View Details'),
    );
  }

  Widget _buildBottomActionBar() {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      child: ElevatedButton.icon(
        icon: const Icon(Icons.check_circle),
        label: const Text('Complete Route'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.success,
        ),
        onPressed: _markRouteComplete,
      ),
    );
  }

  // ---------------- MOCK DATA ----------------

  List<Map<String, dynamic>> _getMockTodaysPickups() {
    return [
      {
        'id': 'PK2025001',
        'scheduledTime': DateTime.now(),
        'status': 'completed',
        'wasteTypes': ['Dry', 'Wet'],
        'address': '123 Green Street',
        'residentName': 'John Doe',
        'phone': '+91 9876543210',
      },
      {
        'id': 'PK2025002',
        'scheduledTime': DateTime.now(),
        'status': 'in_progress',
        'wasteTypes': ['Electronic'],
        'address': '456 Beach Road',
        'residentName': 'Jane Smith',
        'phone': '+91 9876543211',
      },
      {
        'id': 'PK2025003',
        'scheduledTime': DateTime.now(),
        'status': 'pending',
        'wasteTypes': ['Organic'],
        'address': '789 Marine Drive',
        'residentName': 'Bob Johnson',
        'phone': '+91 9876543212',
      },
    ];
  }

  // ---------------- HELPERS ----------------

  void _startPickup(Map<String, dynamic> pickup) {
    setState(() {
      pickup['status'] = 'in_progress';
      _currentStatus = 'At Pickup';
    });
  }

  void _completePickup(Map<String, dynamic> pickup) {
    setState(() {
      pickup['status'] = 'completed';
      _currentStatus = 'On Route';
    });
  }

  void _callResident(Map<String, dynamic> pickup) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Calling ${pickup['residentName']}')),
    );
  }

  void _viewDetails(Map<String, dynamic> pickup) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Pickup #${pickup['id']}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Address: ${pickup['address']}'),
              Text('Resident: ${pickup['residentName']}'),
              Text('Phone: ${pickup['phone']}'),
              Text('Waste: ${(pickup['wasteTypes'] as List).join(', ')}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _markRouteComplete() {
    setState(() => _currentStatus = 'Completed');
  }

  void _startNavigation() {}

  void _showMoreOptions() {}

  void _reportIssue() {}
}

// ---------------- SMALL WIDGET ----------------

class _StatusMetric extends StatelessWidget {
  final String label;
  final String value;

  const _StatusMetric(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white70)),
      ],
    );
  }
}
