import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/call_signaling_model.dart';
import 'firebase_service.dart';
import 'notification_service.dart';

class CallSignalingService {
  final FirebaseService _firebaseService = FirebaseService();
  final StreamController<CallInvitation> _incomingCallController = StreamController<CallInvitation>.broadcast();
  final StreamController<CallSignal> _callSignalController = StreamController<CallSignal>.broadcast();

  Stream<CallInvitation> get incomingCallStream => _incomingCallController.stream;
  Stream<CallSignal> get callSignalStream => _callSignalController.stream;

  // Listen for incoming calls
  void startListeningForCalls(String userId) {
    _firebaseService.firestore
        .collection('call_signals')
        .where('receiverId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
          for (var change in snapshot.docChanges) {
            if (change.type == DocumentChangeType.added) {
              final signal = CallSignal.fromFirestore(change.doc);
              _callSignalController.add(signal);

              // Handle call invitation
              if (signal.type == CallSignalType.callInvite) {
                final invitation = CallInvitation.fromSignal(signal);
                _incomingCallController.add(invitation);
              }
            }
          }
        });
  }

  // Send call invitation
  Future<void> sendCallInvitation({
    required String callId,
    required String receiverId,
    required String receiverName,
    required String callerName,
    String? reportId,
    bool isVideoCall = true,
  }) async {
    final currentUser = _firebaseService.currentUser;
    if (currentUser == null) return;

    final signal = CallSignal(
      id: '', // Will be set by Firestore
      callId: callId,
      senderId: currentUser.uid,
      senderName: callerName,
      receiverId: receiverId,
      type: CallSignalType.callInvite,
      timestamp: DateTime.now(),
      payload: {
        'reportId': reportId,
        'isVideoCall': isVideoCall,
        'channelName': 'call_$callId',
      },
    );

    await _firebaseService.firestore
        .collection('call_signals')
        .add(signal.toFirestore());

    // Send push notification
    await NotificationService().sendIncomingCallNotification(
      receiverId: receiverId,
      callerId: currentUser.uid,
      callerName: callerName,
      callId: callId,
      reportId: reportId,
    );
  }

  // Accept call
  Future<void> acceptCall(String callId, String callerId) async {
    final currentUser = _firebaseService.currentUser;
    if (currentUser == null) return;

    final signal = CallSignal(
      id: '',
      callId: callId,
      senderId: currentUser.uid,
      senderName: currentUser.displayName ?? 'Unknown User',
      receiverId: callerId,
      type: CallSignalType.callAccept,
      timestamp: DateTime.now(),
    );

    await _firebaseService.firestore
        .collection('call_signals')
        .add(signal.toFirestore());
  }

  // Reject call
  Future<void> rejectCall(String callId, String callerId) async {
    final currentUser = _firebaseService.currentUser;
    if (currentUser == null) return;

    final signal = CallSignal(
      id: '',
      callId: callId,
      senderId: currentUser.uid,
      senderName: currentUser.displayName ?? 'Unknown User',
      receiverId: callerId,
      type: CallSignalType.callReject,
      timestamp: DateTime.now(),
    );

    await _firebaseService.firestore
        .collection('call_signals')
        .add(signal.toFirestore());
  }

  // End call
  Future<void> endCall(String callId, String otherUserId) async {
    final currentUser = _firebaseService.currentUser;
    if (currentUser == null) return;

    final signal = CallSignal(
      id: '',
      callId: callId,
      senderId: currentUser.uid,
      senderName: currentUser.displayName ?? 'Unknown User',
      receiverId: otherUserId,
      type: CallSignalType.callEnd,
      timestamp: DateTime.now(),
    );

    await _firebaseService.firestore
        .collection('call_signals')
        .add(signal.toFirestore());
  }

  // Cancel call (before acceptance)
  Future<void> cancelCall(String callId, String receiverId) async {
    final currentUser = _firebaseService.currentUser;
    if (currentUser == null) return;

    final signal = CallSignal(
      id: '',
      callId: callId,
      senderId: currentUser.uid,
      senderName: currentUser.displayName ?? 'Unknown User',
      receiverId: receiverId,
      type: CallSignalType.callCancel,
      timestamp: DateTime.now(),
    );

    await _firebaseService.firestore
        .collection('call_signals')
        .add(signal.toFirestore());
  }

  // Listen for call responses (accept/reject/end)
  Stream<CallSignal> listenForCallResponses(String callId, String expectedSenderId) {
    return _firebaseService.firestore
        .collection('call_signals')
        .where('callId', isEqualTo: callId)
        .where('senderId', isEqualTo: expectedSenderId)
        .where('type', whereIn: [
          CallSignalType.callAccept.index,
          CallSignalType.callReject.index,
          CallSignalType.callEnd.index,
          CallSignalType.callCancel.index,
        ])
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => CallSignal.fromFirestore(doc));
        })
        .expand((signals) => signals);
  }

  // Clean up old signals (older than 24 hours)
  Future<void> cleanupOldSignals() async {
    final cutoffTime = DateTime.now().subtract(const Duration(hours: 24));

    final query = await _firebaseService.firestore
        .collection('call_signals')
        .where('timestamp', isLessThan: Timestamp.fromDate(cutoffTime))
        .get();

    final batch = _firebaseService.firestore.batch();
    for (var doc in query.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  // Get active call invitations for a user
  Future<List<CallInvitation>> getActiveCallInvitations(String userId) async {
    final cutoffTime = DateTime.now().subtract(const Duration(minutes: 5)); // Consider calls active for 5 minutes

    final query = await _firebaseService.firestore
        .collection('call_signals')
        .where('receiverId', isEqualTo: userId)
        .where('type', isEqualTo: CallSignalType.callInvite.index)
        .where('timestamp', isGreaterThan: Timestamp.fromDate(cutoffTime))
        .orderBy('timestamp', descending: true)
        .get();

    return query.docs.map((doc) {
      final signal = CallSignal.fromFirestore(doc);
      return CallInvitation.fromSignal(signal);
    }).toList();
  }

  void dispose() {
    _incomingCallController.close();
    _callSignalController.close();
  }
}
