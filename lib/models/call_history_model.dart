import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum CallType { voice, video }
enum CallStatus { missed, completed, ongoing, failed }

class CallHistory {
  final String id;
  final String callerId;
  final String callerName;
  final String receiverId;
  final String receiverName;
  final String? unitId;
  final String? unitName;
  final CallType callType;
  final CallStatus status;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int? duration; // in seconds
  final String? reportId; // linked emergency report
  final List<String>? participants; // for group calls

  CallHistory({
    required this.id,
    required this.callerId,
    required this.callerName,
    required this.receiverId,
    required this.receiverName,
    this.unitId,
    this.unitName,
    required this.callType,
    required this.status,
    required this.startedAt,
    this.endedAt,
    this.duration,
    this.reportId,
    this.participants,
  });

  factory CallHistory.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return CallHistory(
      id: doc.id,
      callerId: data['callerId'] ?? '',
      callerName: data['callerName'] ?? '',
      receiverId: data['receiverId'] ?? '',
      receiverName: data['receiverName'] ?? '',
      unitId: data['unitId'],
      unitName: data['unitName'],
      callType: CallType.values[data['callType'] ?? 0],
      status: CallStatus.values[data['status'] ?? 0],
      startedAt: (data['startedAt'] as Timestamp).toDate(),
      endedAt: data['endedAt'] != null ? (data['endedAt'] as Timestamp).toDate() : null,
      duration: data['duration'],
      reportId: data['reportId'],
      participants: data['participants'] != null ? List<String>.from(data['participants']) : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'callerId': callerId,
      'callerName': callerName,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'unitId': unitId,
      'unitName': unitName,
      'callType': callType.index,
      'status': status.index,
      'startedAt': Timestamp.fromDate(startedAt),
      'endedAt': endedAt != null ? Timestamp.fromDate(endedAt!) : null,
      'duration': duration,
      'reportId': reportId,
      'participants': participants,
    };
  }

  CallHistory copyWith({
    String? id,
    String? callerId,
    String? callerName,
    String? receiverId,
    String? receiverName,
    String? unitId,
    String? unitName,
    CallType? callType,
    CallStatus? status,
    DateTime? startedAt,
    DateTime? endedAt,
    int? duration,
    String? reportId,
    List<String>? participants,
  }) {
    return CallHistory(
      id: id ?? this.id,
      callerId: callerId ?? this.callerId,
      callerName: callerName ?? this.callerName,
      receiverId: receiverId ?? this.receiverId,
      receiverName: receiverName ?? this.receiverName,
      unitId: unitId ?? this.unitId,
      unitName: unitName ?? this.unitName,
      callType: callType ?? this.callType,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      duration: duration ?? this.duration,
      reportId: reportId ?? this.reportId,
      participants: participants ?? this.participants,
    );
  }

  // Helper methods
  bool get isCompleted => status == CallStatus.completed;
  bool get isMissed => status == CallStatus.missed;
  bool get isOngoing => status == CallStatus.ongoing;

  String get durationText {
    if (duration == null) return '';
    final minutes = duration! ~/ 60;
    final seconds = duration! % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get statusText {
    switch (status) {
      case CallStatus.missed:
        return 'Missed';
      case CallStatus.completed:
        return durationText;
      case CallStatus.ongoing:
        return 'Ongoing';
      case CallStatus.failed:
        return 'Failed';
    }
  }

  Color get statusColor {
    switch (status) {
      case CallStatus.missed:
        return Colors.red;
      case CallStatus.completed:
        return Colors.green;
      case CallStatus.ongoing:
        return Colors.blue;
      case CallStatus.failed:
        return Colors.orange;
    }
  }
}
