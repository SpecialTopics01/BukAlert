import 'dart:async';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import '../models/call_signaling_model.dart';
import '../services/call_signaling_service.dart';
import '../screens/citizen/video_call_screen.dart';

class IncomingCallDialog extends StatefulWidget {
  final CallInvitation invitation;
  final CallSignalingService signalingService;

  const IncomingCallDialog({
    super.key,
    required this.invitation,
    required this.signalingService,
  });

  @override
  State<IncomingCallDialog> createState() => _IncomingCallDialogState();
}

class _IncomingCallDialogState extends State<IncomingCallDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  Timer? _ringTimer;
  int _ringCount = 0;
  bool _isVibrating = false;

  @override
  void initState() {
    super.initState();
    _startRinging();
    _startVibration();
    _setupAnimation();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _ringTimer?.cancel();
    _stopVibration();
    super.dispose();
  }

  void _setupAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  void _startRinging() {
    _ringTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _ringCount++;
      if (_ringCount >= 10) { // Auto-reject after 30 seconds
        _rejectCall();
      }
    });
  }

  void _startVibration() async {
    final hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator ?? false) {
      setState(() => _isVibrating = true);
      Vibration.vibrate(
        pattern: [0, 1000, 500, 1000, 500, 1000],
        repeat: 0,
      );
    }
  }

  void _stopVibration() {
    if (_isVibrating) {
      Vibration.cancel();
      setState(() => _isVibrating = false);
    }
  }

  void _acceptCall() async {
    _stopVibration();
    _ringTimer?.cancel();

    // Send accept signal
    await widget.signalingService.acceptCall(
      widget.invitation.callId,
      widget.invitation.callerId,
    );

    if (mounted) {
      // Close dialog
      Navigator.of(context).pop();

      // Navigate to video call screen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => VideoCallScreen(
            callId: widget.invitation.callId,
            receiverId: widget.invitation.callerId,
            receiverName: widget.invitation.callerName,
            reportId: widget.invitation.reportId,
          ),
        ),
      );
    }
  }

  void _rejectCall() async {
    _stopVibration();
    _ringTimer?.cancel();

    // Send reject signal
    await widget.signalingService.rejectCall(
      widget.invitation.callId,
      widget.invitation.callerId,
    );

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Prevent back button
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with emergency indicator
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFFD32F2F),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    // Emergency icon with animation
                    AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _scaleAnimation.value,
                          child: const Icon(
                            Icons.videocam,
                            color: Colors.white,
                            size: 48,
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    // Emergency call text
                    const Text(
                      'EMERGENCY VIDEO CALL',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              // Call details
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Caller info
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: const Color(0xFFD32F2F).withOpacity(0.1),
                      child: Text(
                        widget.invitation.callerName.isNotEmpty
                            ? widget.invitation.callerName[0].toUpperCase()
                            : 'R',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFD32F2F),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Caller name
                    Text(
                      widget.invitation.callerName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 8),

                    // Call type
                    Text(
                      widget.invitation.isVideoCall ? 'Video Call' : 'Voice Call',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Emergency indicator
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.red[200]!),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.warning,
                            color: Colors.red[700],
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Emergency Call',
                            style: TextStyle(
                              color: Colors.red[700],
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Action buttons
                    Row(
                      children: [
                        // Reject button
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _rejectCall,
                            icon: const Icon(Icons.call_end),
                            label: const Text('Decline'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 16),

                        // Accept button
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _acceptCall,
                            icon: const Icon(Icons.videocam),
                            label: const Text('Accept'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
