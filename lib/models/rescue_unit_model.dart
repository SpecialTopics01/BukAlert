import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RescueUnit {
  final String id;
  final String name;
  final String type;
  final double latitude;
  final double longitude;
  final String? phoneNumber;
  final String? address;
  final bool isAvailable;
  final List<String>? capabilities; // e.g., ['fire', 'medical', 'police']
  final int? responseRadius; // in kilometers
  final String? contactPerson;
  final DateTime? lastUpdated;

  RescueUnit({
    required this.id,
    required this.name,
    required this.type,
    required this.latitude,
    required this.longitude,
    this.phoneNumber,
    this.address,
    required this.isAvailable,
    this.capabilities,
    this.responseRadius,
    this.contactPerson,
    this.lastUpdated,
  });

  factory RescueUnit.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return RescueUnit(
      id: doc.id,
      name: data['name'] ?? '',
      type: data['type'] ?? '',
      latitude: data['latitude'] ?? 0.0,
      longitude: data['longitude'] ?? 0.0,
      phoneNumber: data['phoneNumber'],
      address: data['address'],
      isAvailable: data['isAvailable'] ?? true,
      capabilities: data['capabilities'] != null ? List<String>.from(data['capabilities']) : null,
      responseRadius: data['responseRadius'],
      contactPerson: data['contactPerson'],
      lastUpdated: data['lastUpdated'] != null ? (data['lastUpdated'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'type': type,
      'latitude': latitude,
      'longitude': longitude,
      'phoneNumber': phoneNumber,
      'address': address,
      'isAvailable': isAvailable,
      'capabilities': capabilities,
      'responseRadius': responseRadius,
      'contactPerson': contactPerson,
      'lastUpdated': lastUpdated != null ? Timestamp.fromDate(lastUpdated!) : null,
    };
  }

  RescueUnit copyWith({
    String? id,
    String? name,
    String? type,
    double? latitude,
    double? longitude,
    String? phoneNumber,
    String? address,
    bool? isAvailable,
    List<String>? capabilities,
    int? responseRadius,
    String? contactPerson,
    DateTime? lastUpdated,
  }) {
    return RescueUnit(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      isAvailable: isAvailable ?? this.isAvailable,
      capabilities: capabilities ?? this.capabilities,
      responseRadius: responseRadius ?? this.responseRadius,
      contactPerson: contactPerson ?? this.contactPerson,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  // Helper methods
  double distanceTo(double userLat, double userLng) {
    const double earthRadius = 6371; // Earth's radius in kilometers

    final double dLat = (userLat - latitude) * (3.14159 / 180);
    final double dLng = (userLng - longitude) * (3.14159 / 180);

    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(latitude) * math.cos(userLat) * math.sin(dLng / 2) * math.sin(dLng / 2);

    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  bool canRespondTo(String emergencyType) {
    if (capabilities == null || capabilities!.isEmpty) {
      return true; // Assume can respond to all if no specific capabilities listed
    }
    return capabilities!.contains(emergencyType.toLowerCase());
  }

  String get availabilityText => isAvailable ? 'Available' : 'Busy';
  Color get availabilityColor => isAvailable ? Colors.green : Colors.red;
}
