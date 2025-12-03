# Video Calling Implementation Guide

This document explains the Agora.io video calling integration with Firestore signaling in the BukAlert app.

## Architecture Overview

### Components

1. **AgoraService** - Core video calling functionality using Agora.io SDK
2. **CallSignalingService** - Firestore-based signaling for call management
3. **CallProvider** - State management for calls
4. **VideoCallScreen** - UI for video calling
5. **IncomingCallDialog** - UI for incoming call notifications

### Call Flow

```
1. Caller initiates call
   ↓
2. Call invitation sent via Firestore
   ↓
3. Receiver gets notification
   ↓
4. Receiver accepts/rejects call
   ↓
5. If accepted: Join Agora channel
   ↓
6. Video call active
   ↓
7. Call ends, record saved to history
```

## Setup Instructions

### 1. Agora.io Configuration

Update `lib/config/agora_config.dart`:

```dart
class AgoraConfig {
  static const String appId = 'YOUR_AGORA_APP_ID';
  static const String appCertificate = 'YOUR_AGORA_APP_CERTIFICATE';
  // ... other settings
}
```

### 2. Firestore Collections

The app uses these Firestore collections:

- `call_history` - Call records with metadata
- `call_signals` - Real-time call signaling

### 3. Permissions

Required permissions in Android/iOS manifests:

```xml
<!-- AndroidManifest.xml -->
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

## Key Features

### Video Call Controls
- **Mute/Unmute** - Toggle microphone
- **Camera On/Off** - Toggle video feed
- **Switch Camera** - Front/back camera toggle
- **End Call** - Terminate call

### Call Signaling
- **Call Invite** - Send call invitation
- **Call Accept** - Accept incoming call
- **Call Reject** - Decline incoming call
- **Call End** - End active call
- **Call Cancel** - Cancel before acceptance

### Call States
- `idle` - No active call
- `connecting` - Establishing connection
- `connected` - Call active
- `disconnected` - Call ended
- `error` - Connection failed

## Usage Examples

### Making a Call

```dart
final callProvider = Provider.of<CallProvider>(context, listen: false);

final success = await callProvider.makeCall(
  receiverId: 'unit_123',
  receiverName: 'Fire Station 1',
  isVideoCall: true,
);

if (success) {
  Navigator.push(context, MaterialPageRoute(
    builder: (_) => VideoCallScreen(
      callId: callProvider.currentCallId!,
      receiverId: 'unit_123',
      receiverName: 'Fire Station 1',
    ),
  ));
}
```

### Handling Incoming Calls

```dart
Consumer<CallProvider>(
  builder: (context, callProvider, child) {
    if (callProvider.hasIncomingCall) {
      showDialog(
        context: context,
        builder: (_) => IncomingCallDialog(
          invitation: callProvider.currentIncomingCall!,
          signalingService: callProvider.signalingService,
        ),
      );
    }
    return SizedBox.shrink();
  },
);
```

### Call Controls

```dart
// In VideoCallScreen
Future<void> _toggleMute() async {
  await callProvider.toggleMute();
  setState(() => _isMuted = await callProvider.isMuted());
}

Future<void> _endCall() async {
  await callProvider.endCall();
  Navigator.pop(context);
}
```

## Error Handling

### Common Issues

1. **Token Expired**: Implement server-side token generation
2. **Network Issues**: Add retry mechanisms
3. **Permission Denied**: Request permissions properly
4. **Channel Full**: Handle max users exceeded

### Error States

```dart
_agoraService.callStateStream.listen((state) {
  switch (state) {
    case CallState.error:
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Call connection failed')),
      );
      break;
    case CallState.disconnected:
      // Auto-close call screen
      Navigator.pop(context);
      break;
    // ... handle other states
  }
});
```

## Testing

### Development Testing

1. Use Agora Console for temporary tokens
2. Test with multiple devices/browsers
3. Verify call quality and audio/video sync
4. Test network interruptions

### Production Considerations

1. **Token Security**: Server-side token generation
2. **Recording**: Optional call recording for emergencies
3. **Quality Monitoring**: Track call quality metrics
4. **Load Balancing**: Handle multiple concurrent calls

## Security Considerations

1. **Token Expiration**: Short-lived tokens (1 hour max)
2. **Channel Names**: Unique, non-predictable names
3. **User Authentication**: Verify caller identity
4. **Call Logging**: Record all emergency calls
5. **Data Encryption**: End-to-end encryption for sensitive calls

## Performance Optimization

1. **Video Quality**: Adaptive bitrate based on network
2. **Audio Processing**: Noise reduction and echo cancellation
3. **Battery Management**: Optimize for mobile devices
4. **Memory Management**: Proper cleanup of resources

## Troubleshooting

### Common Issues

1. **Black screen**: Camera permissions or hardware issues
2. **No audio**: Microphone permissions or audio routing
3. **Connection fails**: Network issues or invalid tokens
4. **Poor quality**: Network bandwidth or device performance

### Debug Tools

1. Agora Console analytics
2. Firebase Debug View
3. Flutter DevTools
4. Network monitoring tools

## Future Enhancements

1. **Group Calls**: Multi-party emergency conferences
2. **Screen Sharing**: Share incident visuals
3. **Call Recording**: Automatic recording for evidence
4. **Call Analytics**: Quality and performance metrics
5. **Offline Mode**: Basic calling without internet
