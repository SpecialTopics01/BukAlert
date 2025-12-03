import 'dart:async';
import 'dart:convert';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/call_history_model.dart';
import '../config/agora_config.dart';
import '../config/video_config.dart';
import 'firebase_service.dart';

class AgoraService {

  final FirebaseService _firebaseService = FirebaseService();
  RtcEngine? _engine;
  bool _isInitialized = false;
  bool _isJoined = false;
  String? _currentChannelId;
  String? _currentToken;

  // Call state
  StreamController<CallState> _callStateController = StreamController<CallState>.broadcast();
  Stream<CallState> get callStateStream => _callStateController.stream;

  CallState _currentCallState = CallState.idle;
  CallState get currentCallState => _currentCallState;

  // Remote users
  final Set<int> _remoteUids = {};
  Set<int> get remoteUids => _remoteUids;

  // Local media state
  bool _isMuted = false;
  bool _isCameraEnabled = true;

  // Call info
  String? _currentCallId;
  String? _callerId;
  String? _callerName;
  String? _receiverId;
  String? _receiverName;

  // Video configuration
  VideoCodec _currentCodec = VideoConfig.defaultCodec;
  VideoQuality _currentQuality = VideoQuality.medium;

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isJoined => _isJoined;
  String? get currentChannelId => _currentChannelId;
  RtcEngine? get engine => _engine;

  Future<bool> initializeAgora() async {
    if (_isInitialized) return true;

    try {
      // Request permissions
      await _requestPermissions();

      // Create engine
      _engine = createAgoraRtcEngine();
      await _engine!.initialize(RtcEngineContext(
        appId: AgoraConfig.appId,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ));

      // Configure video encoder for VP8
      await _configureVideoEncoder();

      // Set event handlers
      _setupEventHandlers();

      _isInitialized = true;
      return true;
    } catch (e) {
      print('Failed to initialize Agora: $e');
      return false;
    }
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.camera,
      Permission.microphone,
    ].request();
  }

  Future<void> _configureVideoEncoder() async {
    if (_engine == null) return;

    try {
      // Set video encoder configuration with VP8 codec
      final encoderConfig = VideoConfig.getEncoderConfig(
        codec: _currentCodec,
        quality: _currentQuality,
      );

      await _engine!.setVideoEncoderConfiguration(encoderConfig);

      // Enable dual stream mode for better quality adaptation
      await _engine!.enableDualStreamMode(enabled: true);

      // Video quality is configured via encoder configuration

      print('Video encoder configured with ${encoderConfig.codecType} codec');
    } catch (e) {
      print('Failed to configure video encoder: $e');
    }
  }

  void _setupEventHandlers() {
    if (_engine == null) return;

    _engine!.registerEventHandler(RtcEngineEventHandler(
      onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
        print('Successfully joined channel: ${connection.channelId}');
        _isJoined = true;
        _currentChannelId = connection.channelId;
        _updateCallState(CallState.connected);
      },

      onLeaveChannel: (RtcConnection connection, RtcStats stats) {
        print('Left channel: ${connection.channelId}');
        _isJoined = false;
        _currentChannelId = null;
        _remoteUids.clear();
        _updateCallState(CallState.idle);
      },

      onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
        print('Remote user joined: $remoteUid');
        _remoteUids.add(remoteUid);
        _updateCallState(CallState.connected);
      },

      onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
        print('Remote user left: $remoteUid');
        _remoteUids.remove(remoteUid);
        if (_remoteUids.isEmpty) {
          _updateCallState(CallState.idle);
        }
      },

      onError: (ErrorCodeType err, String msg) {
        print('Agora error: $err - $msg');
        _updateCallState(CallState.error);
      },

      onConnectionStateChanged: (RtcConnection connection, ConnectionStateType state, ConnectionChangedReasonType reason) {
        print('Connection state changed: $state, reason: $reason');
        switch (state) {
          case ConnectionStateType.connectionStateConnecting:
            _updateCallState(CallState.connecting);
            break;
          case ConnectionStateType.connectionStateConnected:
            _updateCallState(CallState.connected);
            break;
          case ConnectionStateType.connectionStateDisconnected:
            _updateCallState(CallState.disconnected);
            break;
          case ConnectionStateType.connectionStateFailed:
            _updateCallState(CallState.error);
            break;
          default:
            break;
        }
      },
    ));
  }

  Future<String> _generateToken(String channelName) async {
    // TODO: Implement proper token generation
    // For development, you can use temporary tokens from Agora Console
    // For production, implement server-side token generation with App Certificate
    return AgoraConfig.getTempToken(channelName, '0');
  }

  Future<bool> startCall({
    required String receiverId,
    required String receiverName,
    required String callId,
    String? reportId,
    VideoCodec codec = VideoConfig.defaultCodec,
    VideoQuality quality = VideoQuality.medium,
  }) async {
    if (!_isInitialized) {
      final initialized = await initializeAgora();
      if (!initialized) return false;
    }

    try {
    _currentCallId = callId;
    _receiverId = receiverId;
    _receiverName = receiverName;
    _currentCodec = codec;
    _currentQuality = quality;

    final currentUser = _firebaseService.currentUser;
    if (currentUser == null) return false;

      _callerId = currentUser.uid;
      _callerName = currentUser.displayName ?? 'Unknown User';

      // Generate channel name (using callId for uniqueness)
      final channelName = 'call_$callId';

      // Generate token
      final token = await _generateToken(channelName);

      // Set channel options with VP8 codec
      final channelMediaOptions = ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        channelProfile: ChannelProfileType.channelProfileCommunication,
        publishCameraTrack: true,
        publishMicrophoneTrack: true,
        publishScreenCaptureVideo: false,
        publishScreenCaptureAudio: false,
        autoSubscribeAudio: true,
        autoSubscribeVideo: true,
      );

      // Join channel
      await _engine!.joinChannel(
        token: token,
        channelId: channelName,
        uid: 0,
        options: channelMediaOptions,
      );

      // Create call record in Firestore
      await _createCallRecord(callId, reportId);

      _updateCallState(CallState.connecting);
      return true;
    } catch (e) {
      print('Failed to start call: $e');
      _updateCallState(CallState.error);
      return false;
    }
  }

  Future<void> _createCallRecord(String callId, String? reportId) async {
    final callRecord = CallHistory(
      id: callId,
      callerId: _callerId!,
      callerName: _callerName!,
      receiverId: _receiverId!,
      receiverName: _receiverName!,
      callType: CallType.video,
      status: CallStatus.ongoing,
      startedAt: DateTime.now(),
      reportId: reportId,
    );

    await _firebaseService.firestore
        .collection('call_history')
        .doc(callId)
        .set(callRecord.toFirestore());
  }

  Future<void> endCall() async {
    if (!_isJoined) return;

    try {
      await _engine!.leaveChannel();
      await _updateCallRecordOnEnd();
      _resetCallState();
    } catch (e) {
      print('Failed to end call: $e');
    }
  }

  Future<void> _updateCallRecordOnEnd() async {
    if (_currentCallId == null) return;

    final endTime = DateTime.now();
    final duration = endTime.difference(DateTime.now()).inSeconds; // TODO: Calculate actual duration

    await _firebaseService.firestore
        .collection('call_history')
        .doc(_currentCallId!)
        .update({
          'status': CallStatus.completed.index,
          'endedAt': endTime,
          'duration': duration,
        });
  }

  void _resetCallState() {
    _currentCallId = null;
    _callerId = null;
    _callerName = null;
    _receiverId = null;
    _receiverName = null;
    _currentToken = null;
    _remoteUids.clear();
  }

  Future<void> toggleMute() async {
    if (_engine == null) return;
    _isMuted = !_isMuted;
    await _engine!.muteLocalAudioStream(_isMuted);
  }

  Future<void> toggleCamera() async {
    if (_engine == null) return;
    _isCameraEnabled = !_isCameraEnabled;
    await _engine!.enableLocalVideo(_isCameraEnabled);
  }

  Future<void> switchCamera() async {
    if (_engine == null) return;
    await _engine!.switchCamera();
  }

  bool isMuted() {
    return _isMuted;
  }

  bool isCameraEnabled() {
    return _isCameraEnabled;
  }

  // Change video codec during call
  Future<bool> changeVideoCodec(VideoCodec codec, {VideoQuality quality = VideoQuality.medium}) async {
    if (_engine == null || !_isJoined) return false;

    try {
      _currentCodec = codec;
      _currentQuality = quality;

      final encoderConfig = VideoConfig.getEncoderConfig(
        codec: codec,
        quality: quality,
      );

      await _engine!.setVideoEncoderConfiguration(encoderConfig);
      print('Video codec changed to ${encoderConfig.codecType}');
      return true;
    } catch (e) {
      print('Failed to change video codec: $e');
      return false;
    }
  }

  // Change video quality during call
  Future<bool> changeVideoQuality(VideoQuality quality) async {
    if (_engine == null || !_isJoined) return false;

    try {
      _currentQuality = quality;

      final encoderConfig = VideoConfig.getEncoderConfig(
        codec: _currentCodec,
        quality: quality,
      );

      await _engine!.setVideoEncoderConfiguration(encoderConfig);
      print('Video quality changed to ${quality.name}');
      return true;
    } catch (e) {
      print('Failed to change video quality: $e');
      return false;
    }
  }

  // Get current codec information
  VideoCodec get currentCodec => _currentCodec;
  VideoQuality get currentQuality => _currentQuality;

  // Check codec support
  Future<Map<VideoCodec, bool>> getCodecSupport() async {
    return {
      VideoCodec.vp8: await VideoConfig.isVp8Supported(),
      VideoCodec.h264: true, // H264 is widely supported
      VideoCodec.auto: true, // Auto selection always available
    };
  }

  void _updateCallState(CallState state) {
    _currentCallState = state;
    _callStateController.add(state);
  }

  Future<void> dispose() async {
    if (_isJoined) {
      await endCall();
    }

    await _engine?.release();
    _engine = null;
    _isInitialized = false;
    await _callStateController.close();
  }
}

enum CallState {
  idle,
  connecting,
  connected,
  disconnected,
  error,
}
