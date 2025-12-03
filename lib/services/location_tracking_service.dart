import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/location_data_model.dart';
import '../config/google_maps_config.dart';
import '../services/firebase_service.dart';

class LocationTrackingService {
  static final LocationTrackingService _instance = LocationTrackingService._internal();
  factory LocationTrackingService() => _instance;
  LocationTrackingService._internal();

  final FirebaseService _firebaseService = FirebaseService();
  StreamSubscription<Position>? _positionSubscription;
  Timer? _locationUpdateTimer;
  bool _isTracking = false;
  String? _currentSessionId;
  String? _trackingPurpose; // 'emergency', 'call', 'patrol', etc.

  // Getters
  bool get isTracking => _isTracking;
  String? get currentSessionId => _currentSessionId;

  // Start location tracking
  Future<bool> startTracking({
    required String sessionId,
    required String purpose,
    Duration updateInterval = GoogleMapsConfig.locationUpdateInterval,
    bool shareWithUnits = false,
  }) async {
    if (_isTracking) {
      await stopTracking();
    }

    try {
      // Check permissions
      final hasPermission = await Geolocator.checkPermission();
      if (hasPermission == LocationPermission.denied ||
          hasPermission == LocationPermission.deniedForever) {
        return false;
      }

      _currentSessionId = sessionId;
      _trackingPurpose = purpose;
      _isTracking = true;

      // Start periodic location updates
      _locationUpdateTimer = Timer.periodic(updateInterval, (timer) async {
        await _updateLocation(shareWithUnits: shareWithUnits);
      });

      // Initial location update
      await _updateLocation(shareWithUnits: shareWithUnits);

      return true;
    } catch (e) {
      print('Failed to start location tracking: $e');
      _isTracking = false;
      return false;
    }
  }

  // Stop location tracking
  Future<void> stopTracking() async {
    _locationUpdateTimer?.cancel();
    _positionSubscription?.cancel();

    if (_currentSessionId != null) {
      await _updateTrackingStatus(false);
    }

    _isTracking = false;
    _currentSessionId = null;
    _trackingPurpose = null;
  }

  // Update current location
  Future<void> _updateLocation({bool shareWithUnits = false}) async {
    if (!_isTracking || _currentSessionId == null) return;

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final locationData = LocationData(
        sessionId: _currentSessionId!,
        userId: _firebaseService.currentUser?.uid ?? 'unknown',
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        altitude: position.altitude,
        speed: position.speed,
        heading: position.heading,
        timestamp: DateTime.now(),
        purpose: _trackingPurpose!,
        isActive: true,
      );

      // Save to Firestore
      await _saveLocationData(locationData);

      // Share with nearby units if requested
      if (shareWithUnits) {
        await _shareLocationWithUnits(locationData);
      }

    } catch (e) {
      print('Failed to update location: $e');
    }
  }

  // Save location data to Firestore
  Future<void> _saveLocationData(LocationData locationData) async {
    try {
      await _firebaseService.firestore
          .collection('location_tracking')
          .add(locationData.toFirestore());
    } catch (e) {
      print('Failed to save location data: $e');
    }
  }

  // Share location with nearby rescue units
  Future<void> _shareLocationWithUnits(LocationData locationData) async {
    try {
      // Find nearby units (within 10km)
      final unitsQuery = await _firebaseService.firestore
          .collection('rescue_units')
          .get();

      final nearbyUnits = unitsQuery.docs.where((doc) {
        final unitData = doc.data();
        final unitLat = unitData['latitude'] as double?;
        final unitLng = unitData['longitude'] as double?;

        if (unitLat == null || unitLng == null) return false;

        // Calculate distance
        final distance = Geolocator.distanceBetween(
          locationData.latitude,
          locationData.longitude,
          unitLat,
          unitLng,
        );

        return distance <= 10000; // 10km radius
      }).toList();

      // Share location with nearby units
      for (var unitDoc in nearbyUnits) {
        await _firebaseService.firestore
            .collection('location_sharing')
            .add({
              'sessionId': locationData.sessionId,
              'userId': locationData.userId,
              'unitId': unitDoc.id,
              'latitude': locationData.latitude,
              'longitude': locationData.longitude,
              'timestamp': Timestamp.fromDate(locationData.timestamp),
              'purpose': locationData.purpose,
            });
      }
    } catch (e) {
      print('Failed to share location with units: $e');
    }
  }

  // Update tracking status
  Future<void> _updateTrackingStatus(bool isActive) async {
    if (_currentSessionId == null) return;

    try {
      await _firebaseService.firestore
          .collection('location_sessions')
          .doc(_currentSessionId)
          .set({
            'sessionId': _currentSessionId,
            'userId': _firebaseService.currentUser?.uid ?? 'unknown',
            'purpose': _trackingPurpose,
            'isActive': isActive,
            'startedAt': isActive ? Timestamp.now() : null,
            'endedAt': !isActive ? Timestamp.now() : null,
          }, SetOptions(merge: true));
    } catch (e) {
      print('Failed to update tracking status: $e');
    }
  }

  // Get location history for a session
  Future<List<LocationData>> getLocationHistory(String sessionId) async {
    try {
      final query = await _firebaseService.firestore
          .collection('location_tracking')
          .where('sessionId', isEqualTo: sessionId)
          .orderBy('timestamp', descending: true)
          .get();

      return query.docs
          .map((doc) => LocationData.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Failed to get location history: $e');
      return [];
    }
  }

  // Listen to shared locations from units
  Stream<List<LocationData>> listenToUnitLocations(String sessionId) {
    return _firebaseService.firestore
        .collection('location_sharing')
        .where('sessionId', isEqualTo: sessionId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => LocationData.fromFirestore(doc))
              .toList();
        });
  }

  // Get active tracking sessions
  Future<List<Map<String, dynamic>>> getActiveSessions() async {
    try {
      final query = await _firebaseService.firestore
          .collection('location_sessions')
          .where('isActive', isEqualTo: true)
          .get();

      return query.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Failed to get active sessions: $e');
      return [];
    }
  }

  // Calculate distance between two locations
  double calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    return Geolocator.distanceBetween(lat1, lng1, lat2, lng2);
  }

  // Get estimated time of arrival
  Duration estimateTimeOfArrival(double distance, double averageSpeedKmh) {
    final timeInHours = distance / (averageSpeedKmh * 1000); // Convert km to meters
    return Duration(minutes: (timeInHours * 60).round());
  }
}
