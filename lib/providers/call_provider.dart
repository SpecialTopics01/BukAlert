import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/call_signaling_model.dart';
import '../services/agora_service.dart';
import '../services/call_signaling_service.dart';
import '../services/firebase_service.dart';
import '../services/notification_service.dart';
import '../config/video_config.dart';
import 'package:uuid/uuid.dart';

class CallProvider with ChangeNotifier {
  final AgoraService _agoraService = AgoraService();
  final CallSignalingService _signalingService = CallSignalingService();
  final FirebaseService _firebaseService = FirebaseService();

  CallState _currentCallState = CallState.idle;
  CallInvitation? _currentIncomingCall;
  bool _isInCall = false;
  String? _currentCallId;

  // Getters
  CallState get currentCallState => _currentCallState;
  CallInvitation? get currentIncomingCall => _currentIncomingCall;
  bool get isInCall => _isInCall;
  bool get hasIncomingCall => _currentIncomingCall != null;
  String? get currentCallId => _currentCallId;
  CallSignalingService get callSignalingService => _signalingService;

  // Streams
  Stream<CallInvitation> get incomingCallStream => _signalingService.incomingCallStream;

  CallProvider() {
    _initializeCallServices();
  }

  void _initializeCallServices() {
    // Listen for incoming calls
    final currentUser = _firebaseService.currentUser;
    if (currentUser != null) {
      _signalingService.startListeningForCalls(currentUser.uid);
      NotificationService().setupTokenRefreshListener(currentUser.uid);
    }

    // Listen to call state changes
    _agoraService.callStateStream.listen((state) {
      _currentCallState = state;
      _isInCall = state == CallState.connected;

      if (state == CallState.idle) {
        _currentCallId = null;
      }

      notifyListeners();
    });

    // Listen for incoming call invitations
    _signalingService.incomingCallStream.listen((invitation) {
      if (!_isInCall) { // Only show if not already in a call
        _currentIncomingCall = invitation;
        notifyListeners();
      }
    });
  }

  // Make a call
  Future<bool> makeCall({
    required String receiverId,
    required String receiverName,
    String? reportId,
    bool isVideoCall = true,
  }) async {
    try {
      // Generate unique call ID
      const uuid = Uuid();
      final callId = uuid.v4();

      _currentCallId = callId;

      // Send call invitation via signaling
      await _signalingService.sendCallInvitation(
        callId: callId,
        receiverId: receiverId,
        receiverName: receiverName,
        callerName: _firebaseService.currentUser?.displayName ?? 'Unknown User',
        reportId: reportId,
        isVideoCall: isVideoCall,
      );

      // Start the call with VP8 codec
      final success = await _agoraService.startCall(
        receiverId: receiverId,
        receiverName: receiverName,
        callId: callId,
        reportId: reportId,
        codec: VideoCodec.vp8, // Use VP8 codec by default
        quality: VideoQuality.medium,
      );

      if (!success) {
        _currentCallId = null;
        return false;
      }

      // Listen for call responses
      _listenForCallResponse(callId, receiverId);

      return true;
    } catch (e) {
      print('Failed to make call: $e');
      _currentCallId = null;
      return false;
    }
  }

  void _listenForCallResponse(String callId, String receiverId) {
    _signalingService.listenForCallResponses(callId, receiverId).listen((signal) {
      switch (signal.type) {
        case CallSignalType.callAccept:
          // Call accepted, continue with current call
          print('Call accepted by $receiverId');
          break;
        case CallSignalType.callReject:
          // Call rejected, end the call
          print('Call rejected by $receiverId');
          _endCallInternal();
          break;
        case CallSignalType.callEnd:
          // Call ended by other party
          print('Call ended by $receiverId');
          _endCallInternal();
          break;
        case CallSignalType.callCancel:
          // Call cancelled by caller before acceptance
          print('Call cancelled by $receiverId');
          _endCallInternal();
          break;
        default:
          print('Unhandled call signal type: ${signal.type}');
          break;
      }
    });
  }

  // Accept incoming call
  Future<void> acceptIncomingCall() async {
    if (_currentIncomingCall == null) return;

    try {
      // Send accept signal
      await _signalingService.acceptCall(
        _currentIncomingCall!.callId,
        _currentIncomingCall!.callerId,
      );

      // Clear incoming call
      _currentIncomingCall = null;
      notifyListeners();

      // Note: The actual video call screen should be navigated to by the UI layer
    } catch (e) {
      print('Failed to accept call: $e');
    }
  }

  // Reject incoming call
  Future<void> rejectIncomingCall() async {
    if (_currentIncomingCall == null) return;

    try {
      await _signalingService.rejectCall(
        _currentIncomingCall!.callId,
        _currentIncomingCall!.callerId,
      );

      _currentIncomingCall = null;
      notifyListeners();
    } catch (e) {
      print('Failed to reject call: $e');
    }
  }

  // End current call
  Future<void> endCall() async {
    if (_currentCallId != null && _currentIncomingCall != null) {
      // End incoming call
      await _signalingService.endCall(
        _currentIncomingCall!.callId,
        _currentIncomingCall!.callerId,
      );
    }

    await _endCallInternal();
  }

  Future<void> _endCallInternal() async {
    await _agoraService.endCall();
    _currentIncomingCall = null;
    _currentCallId = null;
    _currentCallState = CallState.idle;
    _isInCall = false;
    notifyListeners();
  }

  // Toggle mute
  Future<void> toggleMute() async {
    await _agoraService.toggleMute();
    notifyListeners();
  }

  // Toggle camera
  Future<void> toggleCamera() async {
    await _agoraService.toggleCamera();
    notifyListeners();
  }

  // Switch camera
  Future<void> switchCamera() async {
    await _agoraService.switchCamera();
    notifyListeners();
  }

  // Get mute status
  Future<bool> isMuted() async {
    return await _agoraService.isMuted();
  }

  // Get camera status
  Future<bool> isCameraEnabled() async {
    return await _agoraService.isCameraEnabled();
  }

  // Clear incoming call (when dismissed without action)
  void clearIncomingCall() {
    _currentIncomingCall = null;
    notifyListeners();
  }

  // Update user for signaling (when user changes)
  void updateUser(String userId) {
    _signalingService.startListeningForCalls(userId);
  }

  @override
  void dispose() {
    _agoraService.dispose();
    _signalingService.dispose();
    super.dispose();
  }
}
