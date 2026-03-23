import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/admin_service.dart';
import '../../theme/app_theme.dart';

class AdminLiveMapScreen extends StatefulWidget {
  const AdminLiveMapScreen({super.key});

  @override
  State<AdminLiveMapScreen> createState() => _AdminLiveMapScreenState();
}

class _AdminLiveMapScreenState extends State<AdminLiveMapScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  Timer? _refreshTimer;
  Set<Marker> _markers = {};
  
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(11.2588, 75.7804), // Kozhikode default
    zoom: 13,
  );

  @override
  void initState() {
    super.initState();
    _startTracking();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startTracking() {
    _updateMarkers();
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) _updateMarkers();
    });
  }

  Future<void> _updateMarkers() async {
    final adminService = Provider.of<AdminService>(context, listen: false);
    await adminService.fetchDashboardStats();
    
    final liveData = adminService.systemStats['live_map'];
    if (liveData is List) {
      final newMarkers = liveData.map((worker) {
        final lat = double.tryParse(worker['latitude']?.toString() ?? '0') ?? 0.0;
        final lng = double.tryParse(worker['longitude']?.toString() ?? '0') ?? 0.0;
        
        return Marker(
          markerId: MarkerId(worker['id'].toString()),
          position: LatLng(lat, lng),
          infoWindow: InfoWindow(
            title: worker['username'] ?? 'Worker',
            snippet: 'Ward: ${worker['ward'] ?? "N/A"} • Last update: ${worker['last_location_update'] ?? "Just now"}',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        );
      }).toSet();

      setState(() {
        _markers = newMarkers;
      });
      
      // Auto-center on first marker if map controller is ready and zoom is default
      /*
      if (_markers.isNotEmpty && !_hasMoved) {
        final controller = await _controller.future;
        controller.animateCamera(CameraUpdate.newLatLng(_markers.first.position));
      }
      */
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.only(left: 16, top: 8),
          decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: AppTheme.cardShadow),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.grey900),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 8),
            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: AppTheme.cardShadow),
            child: IconButton(
              icon: const Icon(Icons.refresh_rounded, color: AppTheme.primaryEmerald),
              onPressed: _updateMarkers,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _initialPosition,
            markers: _markers,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapType: MapType.normal,
          ),
          Positioned(
            bottom: 32,
            left: 20,
            right: 20,
            child: _buildBottomCard(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Worker Map', 
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w900, 
                      fontSize: 18, 
                      color: AppTheme.grey900, 
                      letterSpacing: -0.5
                    )
                  ),
                  Text(
                    'Track worker locations in real-time', 
                    style: GoogleFonts.inter(
                      fontSize: 12, 
                      color: AppTheme.grey400, 
                      fontWeight: FontWeight.w500
                    )
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: AppTheme.primaryEmerald.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Text(
                  '${_markers.length} TOTAL', 
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9, 
                    fontWeight: FontWeight.w900, 
                    color: AppTheme.primaryEmerald, 
                    letterSpacing: 1
                  )
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
