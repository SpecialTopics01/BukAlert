import 'package:cloud_firestore/cloud_firestore.dart';

enum EmergencyType {
  fire('Fire Emergency', '🔥'),
  medical('Medical Emergency', '🚑'),
  crime('Crime/Violence', '🚔'),
  accident('Traffic Accident', '🚗'),
  naturalDisaster('Natural Disaster', '🌪️'),
  other('Other Emergency', '⚠️');

  const EmergencyType(this.displayName, this.emoji);
  final String displayName;
  final String emoji;
}

enum EmergencyStatus {
  reported('Reported'),
  acknowledged('Acknowledged'),
  responding('Responding'),
  resolved('Resolved'),
  cancelled('Cancelled');

  const EmergencyStatus(this.displayName);
  final String displayName;
}

class EmergencyReport {
  final String id;
  final String userId;
  final String userName;
  final EmergencyType type;
  final String description;
  final String location;
  final double latitude;
  final double longitude;
  final EmergencyStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? assignedUnitId;
  final String? assignedUnitName;
  final List<String>? mediaUrls; // For photos/videos
  final String? additionalNotes;
  final int? priority; // 1=Low, 2=Medium, 3=High, 4=Critical

  EmergencyReport({
    required this.id,
    required this.userId,
    required this.userName,
    required this.type,
    required this.description,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.assignedUnitId,
    this.assignedUnitName,
    this.mediaUrls,
    this.additionalNotes,
    this.priority = 2,
  });

  factory EmergencyReport.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return EmergencyReport(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      type: EmergencyType.values[data['type'] ?? 0],
      description: data['description'] ?? '',
      location: data['location'] ?? '',
      latitude: data['latitude'] ?? 0.0,
      longitude: data['longitude'] ?? 0.0,
      status: EmergencyStatus.values[data['status'] ?? 0],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null ? (data['updatedAt'] as Timestamp).toDate() : null,
      assignedUnitId: data['assignedUnitId'],
      assignedUnitName: data['assignedUnitName'],
      mediaUrls: data['mediaUrls'] != null ? List<String>.from(data['mediaUrls']) : null,
      additionalNotes: data['additionalNotes'],
      priority: data['priority'] ?? 2,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'type': type.index,
      'description': description,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'status': status.index,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'assignedUnitId': assignedUnitId,
      'assignedUnitName': assignedUnitName,
      'mediaUrls': mediaUrls,
      'additionalNotes': additionalNotes,
      'priority': priority,
    };
  }

  EmergencyReport copyWith({
    String? id,
    String? userId,
    String? userName,
    EmergencyType? type,
    String? description,
    String? location,
    double? latitude,
    double? longitude,
    EmergencyStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? assignedUnitId,
    String? assignedUnitName,
    List<String>? mediaUrls,
    String? additionalNotes,
    int? priority,
  }) {
    return EmergencyReport(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      type: type ?? this.type,
      description: description ?? this.description,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      assignedUnitId: assignedUnitId ?? this.assignedUnitId,
      assignedUnitName: assignedUnitName ?? this.assignedUnitName,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      additionalNotes: additionalNotes ?? this.additionalNotes,
      priority: priority ?? this.priority,
    );
  }

  // Helper methods
  bool get isActive => status.index < EmergencyStatus.resolved.index;
  bool get isAssigned => assignedUnitId != null;
  String get statusColor {
    switch (status) {
      case EmergencyStatus.reported:
        return '#FF9800'; // Orange
      case EmergencyStatus.acknowledged:
        return '#2196F3'; // Blue
      case EmergencyStatus.responding:
        return '#4CAF50'; // Green
      case EmergencyStatus.resolved:
        return '#9E9E9E'; // Grey
      case EmergencyStatus.cancelled:
        return '#F44336'; // Red
      default:
        return '#9E9E9E';
    }
  }

  int get estimatedResponseTime {
    switch (priority) {
      case 4:
        return 5; // 5 minutes for critical
      case 3:
        return 10; // 10 minutes for high
      case 2:
        return 15; // 15 minutes for medium
      case 1:
      default:
        return 30; // 30 minutes for low
    }
  }
}
