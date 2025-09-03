import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  // Stream controller for connectivity status
  final StreamController<bool> _connectivityController =
      StreamController<bool>.broadcast();
  Stream<bool> get connectivityStream => _connectivityController.stream;

  bool _isConnected = true;
  bool get isConnected => _isConnected;

  // Test URL for internet connectivity check
  static const String _testUrl = 'https://karthi-nexgen.tech';
  static const Duration _timeoutDuration = Duration(seconds: 10);

  /// Initialize connectivity monitoring
  Future<void> initialize() async {
    try {
      // Check initial connectivity
      final initialResult = await _connectivity.checkConnectivity();
      await _updateConnectionStatus(initialResult);

      // Listen to connectivity changes
      _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
        _updateConnectionStatus,
        onError: (error) {
          debugPrint('Connectivity error: $error');
          _setConnectionStatus(false);
        },
      );
    } catch (e) {
      debugPrint('Failed to initialize connectivity service: $e');
      _setConnectionStatus(false);
    }
  }

  /// Update connection status based on connectivity result
  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    if (result == ConnectivityResult.none) {
      _setConnectionStatus(false);
    } else {
      // Even if device shows connected, verify with actual internet check
      final hasInternet = await _checkInternetConnection();
      _setConnectionStatus(hasInternet);
    }
  }

  /// Perform actual internet connectivity test
  Future<bool> _checkInternetConnection() async {
    try {
      final response = await http.get(
        Uri.parse(_testUrl),
        headers: {'Cache-Control': 'no-cache'},
      ).timeout(_timeoutDuration);

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Internet check failed: $e');
      return false;
    }
  }

  /// Set connection status and notify listeners
  void _setConnectionStatus(bool isConnected) {
    if (_isConnected != isConnected) {
      _isConnected = isConnected;
      _connectivityController.add(isConnected);
      debugPrint('Connection status changed: $isConnected');
    }
  }

  /// Manual connectivity check (useful for retry scenarios)
  Future<bool> checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      if (result == ConnectivityResult.none) {
        _setConnectionStatus(false);
        return false;
      }

      final hasInternet = await _checkInternetConnection();
      _setConnectionStatus(hasInternet);
      return hasInternet;
    } catch (e) {
      debugPrint('Manual connectivity check failed: $e');
      _setConnectionStatus(false);
      return false;
    }
  }

  /// Get current connectivity result
  Future<ConnectivityResult> getCurrentConnectivityResult() async {
    try {
      return await _connectivity.checkConnectivity();
    } catch (e) {
      debugPrint('Failed to get connectivity result: $e');
      return ConnectivityResult.none;
    }
  }

  /// Check if device is connected to WiFi
  Future<bool> isWiFiConnected() async {
    final result = await getCurrentConnectivityResult();
    return result == ConnectivityResult.wifi;
  }

  /// Check if device is connected to mobile data
  Future<bool> isMobileDataConnected() async {
    final result = await getCurrentConnectivityResult();
    return result == ConnectivityResult.mobile;
  }

  /// Dispose of resources
  void dispose() {
    _connectivitySubscription?.cancel();
    _connectivityController.close();
  }
}

/// Extension to get user-friendly connectivity descriptions
extension ConnectivityResultExtension on ConnectivityResult {
  String get description {
    switch (this) {
      case ConnectivityResult.wifi:
        return 'WiFi';
      case ConnectivityResult.mobile:
        return 'Mobile Data';
      case ConnectivityResult.ethernet:
        return 'Ethernet';
      case ConnectivityResult.vpn:
        return 'VPN';
      case ConnectivityResult.bluetooth:
        return 'Bluetooth';
      case ConnectivityResult.other:
        return 'Other';
      case ConnectivityResult.none:
        return 'No Connection';
    }
  }
}
