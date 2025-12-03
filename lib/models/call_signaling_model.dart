import 'package:cloud_firestore/cloud_firestore.dart';

enum CallSignalType {
  callInvite,     // Invitation to join a call
  callAccept,     // Call accepted
  callReject,     // Call rejected
  callEnd,        // Call ended
  callCancel,     // Call cancelled before acceptance
}

class CallSignal {
  final String id;
  final String callId;
  final String senderId;
  final String senderName;
  final String receiverId;
  final CallSignalType type;
  final DateTime timestamp;
  final Map<String, dynamic>? payload; // Additional data like channel info

  CallSignal({
    required this.id,
    required this.callId,
    required this.senderId,
    required this.senderName,
    required this.receiverId,
    required this.type,
    required this.timestamp,
    this.payload,
  });

  factory CallSignal.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return CallSignal(
      id: doc.id,
      callId: data['callId'] ?? '',
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      receiverId: data['receiverId'] ?? '',
      type: CallSignalType.values[data['type'] ?? 0],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      payload: data['payload'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'callId': callId,
      'senderId': senderId,
      'senderName': senderName,
      'receiverId': receiverId,
      'type': type.index,
      'timestamp': Timestamp.fromDate(timestamp),
      'payload': payload,
    };
  }

  CallSignal copyWith({
    String? id,
    String? callId,
    String? senderId,
    String? senderName,
    String? receiverId,
    CallSignalType? type,
    DateTime? timestamp,
    Map<String, dynamic>? payload,
  }) {
    return CallSignal(
      id: id ?? this.id,
      callId: callId ?? this.callId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      receiverId: receiverId ?? this.receiverId,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      payload: payload ?? this.payload,
    );
  }
}

class CallInvitation {
  final String callId;
  final String callerId;
  final String callerName;
  final String? reportId;
  final DateTime invitedAt;
  final bool isVideoCall;

  CallInvitation({
    required this.callId,
    required this.callerId,
    required this.callerName,
    this.reportId,
    required this.invitedAt,
    required this.isVideoCall,
  });

  factory CallInvitation.fromSignal(CallSignal signal) {
    return CallInvitation(
      callId: signal.callId,
      callerId: signal.senderId,
      callerName: signal.senderName,
      reportId: signal.payload?['reportId'],
      invitedAt: signal.timestamp,
      isVideoCall: signal.payload?['isVideoCall'] ?? true,
    );
  }
}
