import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'auth_service.dart';
import 'pickup_service.dart';

class WebSocketService extends ChangeNotifier {
  final AuthService _authService;
  final PickupService _pickupService;
  WebSocketChannel? _channel;
  bool _isConnected = false;

  WebSocketService(this._authService, this._pickupService);

  bool get isConnected => _isConnected;

  void connect() {
    if (_isConnected || !_authService.isAuthenticated) return;

    final token = _authService.token;
    final wsUrl = 'wss://waste-management-backend-1.onrender.com/ws/pickups/?token=$token';

    try {
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      _isConnected = true;
      notifyListeners();

      _channel!.stream.listen(
        (message) {
          _handleMessage(message);
        },
        onError: (error) {
          debugPrint('[WS] Error: $error');
          _reconnect();
        },
        onDone: () {
          debugPrint('[WS] Connection closed');
          _isConnected = false;
          _reconnect();
        },
      );
    } catch (e) {
      debugPrint('[WS] Connection Failed: $e');
      _isConnected = false;
      _reconnect();
    }
  }

  void _handleMessage(dynamic message) {
    try {
      final data = jsonDecode(message);
      debugPrint('[WS] Received: $data');

      if (data['type'] == 'pickup_status_update') {
        // Refresh pickups to reflect change
        _pickupService.fetchPickups();
      }
    } catch (e) {
      debugPrint('[WS] Message Parse Error: $e');
    }
  }

  void _reconnect() {
    _isConnected = false;
    notifyListeners();
    Future.delayed(const Duration(seconds: 5), () {
      if (_authService.isAuthenticated) connect();
    });
  }

  void disconnect() {
    _channel?.sink.close();
    _channel = null;
    _isConnected = false;
    notifyListeners();
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}
