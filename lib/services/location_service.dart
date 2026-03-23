import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'auth_service.dart';

class LocationService extends ChangeNotifier {
  final AuthService _authService;
  StreamSubscription<Position>? _positionSubscription;
  Timer? _updateTimer;
  Position? _currentPosition;
  bool _isServiceEnabled = false;

  LocationService(this._authService);

  Position? get currentPosition => _currentPosition;

  Future<bool> requestPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _isServiceEnabled = false;
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    _isServiceEnabled = true;
    return true;
  }

  void startTracking() {
    if (_positionSubscription != null) return;

    final Settings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    _positionSubscription = Geolocator.getPositionStream(locationSettings: Settings).listen(
      (Position position) {
        _currentPosition = position;
        notifyListeners();
      },
    );

    // Update backend periodically (every 30 seconds if moving)
    _updateTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _sendLocationToBackend();
    });
  }

  void stopTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _updateTimer?.cancel();
    _updateTimer = null;
  }

  Future<void> _sendLocationToBackend() async {
    if (_currentPosition == null || !_authService.isAuthenticated) return;
    
    // Only workers and drivers should share live location
    if (_authService.currentUserType != UserType.worker && 
        _authService.currentUserType != UserType.driver) return;

    await _authService.updateProfile(
      latitude: _currentPosition!.latitude.toString(),
      longitude: _currentPosition!.longitude.toString(),
    );
    debugPrint('[LocationService] Location updated for ${_authService.currentUserType?.name}');
  }

  @override
  void dispose() {
    stopTracking();
    super.dispose();
  }
}
