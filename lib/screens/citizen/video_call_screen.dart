import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import '../../services/agora_service.dart';
import '../../config/video_config.dart';

class VideoCallScreen extends StatefulWidget {
  final String callId;
  final String receiverId;
  final String receiverName;
  final String? reportId;

  const VideoCallScreen({
    super.key,
    required this.callId,
    required this.receiverId,
    required this.receiverName,
    this.reportId,
  });

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  final AgoraService _agoraService = AgoraService();
  bool _isMuted = false;
  bool _isCameraEnabled = true;
  bool _isFrontCamera = true;
  CallState _callState = CallState.idle;
  Timer? _callTimer;
  int _callDuration = 0;
  bool _isInitializing = true;

  // Video codec settings
  VideoCodec _selectedCodec = VideoConfig.defaultCodec;
  VideoQuality _selectedQuality = VideoQuality.medium;

  @override
  void initState() {
    super.initState();
    _initializeCall();
    _listenToCallState();
  }

  @override
  void dispose() {
    _callTimer?.cancel();
    _agoraService.dispose();
    super.dispose();
  }

  Future<void> _initializeCall() async {
    setState(() => _isInitializing = true);

    final success = await _agoraService.startCall(
      receiverId: widget.receiverId,
      receiverName: widget.receiverName,
      callId: widget.callId,
      reportId: widget.reportId,
      codec: _selectedCodec,
      quality: _selectedQuality,
    );

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to start video call'),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.of(context).pop();
    }

    setState(() => _isInitializing = false);
  }

  void _listenToCallState() {
    _agoraService.callStateStream.listen((state) {
      setState(() => _callState = state);

      if (state == CallState.connected) {
        _startCallTimer();
      } else if (state == CallState.idle || state == CallState.disconnected) {
        _callTimer?.cancel();
        // Auto-close after a brief delay for disconnected state
        if (state == CallState.disconnected) {
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) Navigator.of(context).pop();
          });
        }
      }
    });
  }

  void _startCallTimer() {
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _callDuration++);
    });
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Future<void> _toggleMute() async {
    await _agoraService.toggleMute();
    final isMuted = await _agoraService.isMuted();
    setState(() => _isMuted = isMuted);
  }

  Future<void> _toggleCamera() async {
    await _agoraService.toggleCamera();
    final isEnabled = await _agoraService.isCameraEnabled();
    setState(() => _isCameraEnabled = isEnabled);
  }

  Future<void> _switchCamera() async {
    await _agoraService.switchCamera();
    setState(() => _isFrontCamera = !_isFrontCamera);
  }

  Future<void> _endCall() async {
    await _agoraService.endCall();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Main video area
            _buildVideoArea(),

            // Call info overlay
            _buildCallInfo(),

            // Call controls
            _buildCallControls(),

            // Loading overlay
            if (_isInitializing || _callState == CallState.connecting)
              _buildLoadingOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoArea() {
    if (!_agoraService.isInitialized) {
      return const Center(
        child: Text(
          'Initializing video call...',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      );
    }

    return AgoraVideoView(
      controller: VideoViewController(
        rtcEngine: _agoraService.engine!,
        canvas: const VideoCanvas(uid: 0), // Local video
      ),
    );
  }

  Widget _buildCallInfo() {
    return Positioned(
      top: 20,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.receiverName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _getCallStatusText(),
                  style: TextStyle(
                    color: _getCallStatusColor(),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            if (_callState == CallState.connected)
              Text(
                _formatDuration(_callDuration),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCallControls() {
    return Positioned(
      bottom: 40,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Mute button
            _buildControlButton(
              icon: _isMuted ? Icons.mic_off : Icons.mic,
              color: _isMuted ? Colors.red : Colors.white,
              onPressed: _toggleMute,
            ),

            // Camera toggle button
            _buildControlButton(
              icon: _isCameraEnabled ? Icons.videocam : Icons.videocam_off,
              color: _isCameraEnabled ? Colors.white : Colors.red,
              onPressed: _toggleCamera,
            ),

            // Switch camera button
            _buildControlButton(
              icon: Icons.flip_camera_ios,
              color: Colors.white,
              onPressed: _switchCamera,
            ),

            // Video settings button
            _buildControlButton(
              icon: Icons.settings,
              color: Colors.white,
              onPressed: _showVideoSettings,
            ),

            // End call button
            Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.call_end, color: Colors.white),
                onPressed: _endCall,
                iconSize: 28,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: color),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            const SizedBox(height: 20),
            Text(
              _isInitializing ? 'Initializing...' : 'Connecting...',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Calling ${widget.receiverName}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getCallStatusText() {
    switch (_callState) {
      case CallState.idle:
        return 'Disconnected';
      case CallState.connecting:
        return 'Connecting...';
      case CallState.connected:
        return 'Connected';
      case CallState.disconnected:
        return 'Call ended';
      case CallState.error:
        return 'Connection error';
    }
  }

  Color _getCallStatusColor() {
    switch (_callState) {
      case CallState.idle:
      case CallState.disconnected:
        return Colors.red;
      case CallState.connecting:
        return Colors.orange;
      case CallState.connected:
        return Colors.green;
      case CallState.error:
        return Colors.red;
    }
  }

  void _showVideoSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black.withOpacity(0.9),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Video Settings',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Video settings will be available in a future update.',
              style: TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}