import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class LocationData {
  final String sessionId;
  final String userId;
  final double latitude;
  final double longitude;
  final double accuracy;
  final double altitude;
  final double speed;
  final double heading;
  final DateTime timestamp;
  final String purpose;
  final bool isActive;
  final String? unitId; // For shared locations from units

  LocationData({
    required this.sessionId,
    required this.userId,
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.altitude,
    required this.speed,
    required this.heading,
    required this.timestamp,
    required this.purpose,
    required this.isActive,
    this.unitId,
  });

  factory LocationData.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return LocationData(
      sessionId: data['sessionId'] ?? '',
      userId: data['userId'] ?? '',
      latitude: data['latitude'] ?? 0.0,
      longitude: data['longitude'] ?? 0.0,
      accuracy: data['accuracy'] ?? 0.0,
      altitude: data['altitude'] ?? 0.0,
      speed: data['speed'] ?? 0.0,
      heading: data['heading'] ?? 0.0,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      purpose: data['purpose'] ?? '',
      isActive: data['isActive'] ?? false,
      unitId: data['unitId'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'sessionId': sessionId,
      'userId': userId,
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'altitude': altitude,
      'speed': speed,
      'heading': heading,
      'timestamp': Timestamp.fromDate(timestamp),
      'purpose': purpose,
      'isActive': isActive,
      'unitId': unitId,
    };
  }

  LocationData copyWith({
    String? sessionId,
    String? userId,
    double? latitude,
    double? longitude,
    double? accuracy,
    double? altitude,
    double? speed,
    double? heading,
    DateTime? timestamp,
    String? purpose,
    bool? isActive,
    String? unitId,
  }) {
    return LocationData(
      sessionId: sessionId ?? this.sessionId,
      userId: userId ?? this.userId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      accuracy: accuracy ?? this.accuracy,
      altitude: altitude ?? this.altitude,
      speed: speed ?? this.speed,
      heading: heading ?? this.heading,
      timestamp: timestamp ?? this.timestamp,
      purpose: purpose ?? this.purpose,
      isActive: isActive ?? this.isActive,
      unitId: unitId ?? this.unitId,
    );
  }

  // Helper methods
  double distanceTo(LocationData other) {
    return Geolocator.distanceBetween(
      latitude,
      longitude,
      other.latitude,
      other.longitude,
    );
  }

  bool isNear(LocationData other, double radiusInMeters) {
    return distanceTo(other) <= radiusInMeters;
  }

  String get formattedSpeed {
    final speedKmh = speed * 3.6; // Convert m/s to km/h
    return '${speedKmh.toStringAsFixed(1)} km/h';
  }

  String get formattedAccuracy {
    return '±${accuracy.toStringAsFixed(1)}m';
  }

  String get cardinalDirection {
    if (heading >= 337.5 || heading < 22.5) return 'N';
    if (heading >= 22.5 && heading < 67.5) return 'NE';
    if (heading >= 67.5 && heading < 112.5) return 'E';
    if (heading >= 112.5 && heading < 157.5) return 'SE';
    if (heading >= 157.5 && heading < 202.5) return 'S';
    if (heading >= 202.5 && heading < 247.5) return 'SW';
    if (heading >= 247.5 && heading < 292.5) return 'W';
    return 'NW';
  }

  // Get movement status
  String get movementStatus {
    if (speed < 0.5) return 'Stationary';
    if (speed < 5) return 'Walking';
    if (speed < 15) return 'Running';
    if (speed < 30) return 'Driving';
    return 'High Speed';
  }

  // Check if location is recent (within last 5 minutes)
  bool get isRecent {
    return DateTime.now().difference(timestamp).inMinutes < 5;
  }

  // Get time ago string
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
