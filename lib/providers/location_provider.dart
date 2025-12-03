import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../models/location_data_model.dart';
import '../services/location_tracking_service.dart';
import '../services/firebase_service.dart';

class LocationProvider with ChangeNotifier {
  final LocationTrackingService _locationService = LocationTrackingService();
  final FirebaseService _firebaseService = FirebaseService();

  // Current location state
  LocationData? _currentLocation;
  bool _isTracking = false;
  String? _currentSessionId;
  String? _trackingPurpose;

  // Nearby units
  List<Map<String, dynamic>> _nearbyUnits = [];
  Map<String, LocationData> _unitLocations = {};

  // Location history
  List<LocationData> _locationHistory = [];

  // Streams
  StreamSubscription<List<LocationData>>? _unitLocationSubscription;

  // Getters
  LocationData? get currentLocation => _currentLocation;
  bool get isTracking => _isTracking;
  String? get currentSessionId => _currentSessionId;
  String? get trackingPurpose => _trackingPurpose;
  List<Map<String, dynamic>> get nearbyUnits => _nearbyUnits;
  Map<String, LocationData> get unitLocations => _unitLocations;
  List<LocationData> get locationHistory => _locationHistory;

  LocationProvider() {
    _initializeLocationService();
  }

  void _initializeLocationService() {
    // Listen to location service state changes
    // This would be implemented with a stream from the location service
  }

  // Start emergency location tracking
  Future<bool> startEmergencyTracking(String reportId) async {
    if (_isTracking) {
      await stopTracking();
    }

    _currentSessionId = 'emergency_$reportId';
    _trackingPurpose = 'emergency';

    final success = await _locationService.startTracking(
      sessionId: _currentSessionId!,
      purpose: _trackingPurpose!,
      shareWithUnits: true,
    );

    if (success) {
      _isTracking = true;
      _startListeningToUnitLocations(_currentSessionId!);
      notifyListeners();
    }

    return success;
  }

  // Start call location tracking
  Future<bool> startCallTracking(String callId) async {
    if (_isTracking) {
      await stopTracking();
    }

    _currentSessionId = 'call_$callId';
    _trackingPurpose = 'call';

    final success = await _locationService.startTracking(
      sessionId: _currentSessionId!,
      purpose: _trackingPurpose!,
      shareWithUnits: true,
    );

    if (success) {
      _isTracking = true;
      _startListeningToUnitLocations(_currentSessionId!);
      notifyListeners();
    }

    return success;
  }

  // Start patrol tracking (for rescue units)
  Future<bool> startPatrolTracking() async {
    if (_isTracking) {
      await stopTracking();
    }

    final currentUser = _firebaseService.currentUser;
    if (currentUser == null) return false;

    _currentSessionId = 'patrol_${currentUser.uid}';
    _trackingPurpose = 'patrol';

    final success = await _locationService.startTracking(
      sessionId: _currentSessionId!,
      purpose: _trackingPurpose!,
      shareWithUnits: false,
    );

    if (success) {
      _isTracking = true;
      notifyListeners();
    }

    return success;
  }

  // Stop location tracking
  Future<void> stopTracking() async {
    if (_isTracking) {
      await _locationService.stopTracking();
      _isTracking = false;
      _currentSessionId = null;
      _trackingPurpose = null;
      _unitLocationSubscription?.cancel();
      _unitLocationSubscription = null;
      notifyListeners();
    }
  }

  // Update current location
  void updateCurrentLocation(LocationData location) {
    _currentLocation = location;
    _locationHistory.insert(0, location);

    // Keep only last 100 locations in history
    if (_locationHistory.length > 100) {
      _locationHistory = _locationHistory.sublist(0, 100);
    }

    notifyListeners();
  }

  // Load nearby rescue units
  Future<void> loadNearbyUnits() async {
    if (_currentLocation == null) return;

    try {
      final unitsQuery = await _firebaseService.firestore
          .collection('rescue_units')
          .where('isAvailable', isEqualTo: true)
          .get();

      _nearbyUnits = unitsQuery.docs
          .map((doc) => doc.data())
          .where((unit) {
            final unitLat = unit['latitude'] as double?;
            final unitLng = unit['longitude'] as double?;
            if (unitLat == null || unitLng == null) return false;

            final distance = _locationService.calculateDistance(
              _currentLocation!.latitude,
              _currentLocation!.longitude,
              unitLat,
              unitLng,
            );

            return distance <= 10000; // 10km radius
          })
          .toList();

      notifyListeners();
    } catch (e) {
      print('Failed to load nearby units: $e');
    }
  }

  // Start listening to unit locations during emergency
  void _startListeningToUnitLocations(String sessionId) {
    _unitLocationSubscription?.cancel();
    _unitLocationSubscription = _locationService
        .listenToUnitLocations(sessionId)
        .listen((unitLocations) {
          for (var location in unitLocations) {
            _unitLocations[location.userId] = location;
          }
          notifyListeners();
        });
  }

  // Get location history for current session
  Future<void> loadLocationHistory() async {
    if (_currentSessionId == null) return;

    try {
      _locationHistory = await _locationService.getLocationHistory(_currentSessionId!);
      notifyListeners();
    } catch (e) {
      print('Failed to load location history: $e');
    }
  }

  // Calculate distance to nearest unit
  double? getDistanceToNearestUnit() {
    if (_currentLocation == null || _nearbyUnits.isEmpty) return null;

    double minDistance = double.infinity;

    for (var unit in _nearbyUnits) {
      final unitLat = unit['latitude'] as double?;
      final unitLng = unit['longitude'] as double?;
      if (unitLat != null && unitLng != null) {
        final distance = _locationService.calculateDistance(
          _currentLocation!.latitude,
          _currentLocation!.longitude,
          unitLat,
          unitLng,
        );
        if (distance < minDistance) {
          minDistance = distance;
        }
      }
    }

    return minDistance == double.infinity ? null : minDistance;
  }

  // Get estimated arrival time for nearest unit
  Duration? getEstimatedArrivalTime() {
    final distance = getDistanceToNearestUnit();
    if (distance == null) return null;

    // Assume average speed of 40 km/h for emergency vehicles
    const averageSpeedKmh = 40.0;
    return _locationService.estimateTimeOfArrival(distance, averageSpeedKmh);
  }

  // Get active tracking sessions (for admin)
  Future<List<Map<String, dynamic>>> getActiveSessions() async {
    return await _locationService.getActiveSessions();
  }

  // Check if location services are available
  Future<bool> checkLocationServices() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  // Request location permissions
  Future<bool> requestLocationPermissions() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      final requested = await Geolocator.requestPermission();
      return requested == LocationPermission.whileInUse ||
             requested == LocationPermission.always;
    }
    return permission == LocationPermission.whileInUse ||
           permission == LocationPermission.always;
  }

  @override
  void dispose() {
    stopTracking();
    super.dispose();
  }
}
