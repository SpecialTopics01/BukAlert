# Firebase Cloud Messaging (FCM) Setup for Push Notifications

This document explains how to set up FCM push notifications for incoming video calls in the BukAlert app.

## Overview

The app uses FCM to send push notifications when someone receives an incoming video call. This ensures users are notified even when the app is in the background or terminated.

## Architecture

```
1. Call Initiated → Firestore Signal Sent
2. FCM Notification Sent → Device Receives
3. Background Handler → Local Notification
4. User Interaction → App Opens to Call Screen
```

## Firebase Console Setup

### 1. Enable Cloud Messaging
1. Go to Firebase Console → Your Project
2. Navigate to "Cloud Messaging" tab
3. This enables FCM for your project

### 2. Get Server Key
1. Go to Project Settings → Cloud Messaging
2. Copy the "Server Key" (you'll need this for sending notifications)

## Android Setup

### 1. Add FCM Dependency
Already added in `pubspec.yaml`:
```yaml
firebase_messaging: ^15.0.0
```

### 2. Update Android Manifest
Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Add these permissions -->
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
    <uses-permission android:name="android.permission.VIBRATE" />

    <application>
        <!-- Add default notification channel -->
        <meta-data
            android:name="com.google.firebase.messaging.default_notification_channel_id"
            android:value="emergency_calls"/>
    </application>
</manifest>
```

### 3. Add Notification Icons
Add notification icons to `android/app/src/main/res/drawable/`:
- `ic_launcher.png` (already exists)
- `emergency_alert.wav` (add to `raw/` folder for custom sound)

## iOS Setup

### 1. Enable Push Notifications
1. Open iOS project in Xcode
2. Go to Signing & Capabilities
3. Add "Push Notifications" capability
4. Add "Background Modes" capability
5. Enable "Remote notifications" in Background Modes

### 2. Update Info.plist
Add to `ios/Runner/Info.plist`:

```xml
<key>FirebaseAppDelegateProxyEnabled</key>
<false/>
<key>UIBackgroundModes</key>
<array>
    <string>remote-notification</string>
</array>
```

## Server-Side Implementation

Since FCM notifications need to be sent from a server, you'll need to implement server-side functions. Here are examples:

### Cloud Function (Node.js)

```javascript
const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

exports.sendCallNotification = functions.firestore
    .document('call_signals/{signalId}')
    .onCreate(async (snap, context) => {
        const signal = snap.data();

        if (signal.type !== 'callInvite') return;

        // Get receiver's FCM token
        const userDoc = await admin.firestore()
            .collection('users')
            .doc(signal.receiverId)
            .get();

        if (!userDoc.exists) return;

        const fcmToken = userDoc.get('fcmToken');
        if (!fcmToken) return;

        // Send FCM notification
        const message = {
            token: fcmToken,
            notification: {
                title: '🚨 EMERGENCY CALL',
                body: `${signal.senderName} is calling`,
            },
            data: {
                type: 'incoming_call',
                callId: signal.callId,
                callerId: signal.senderId,
                callerName: signal.senderName,
                reportId: signal.payload?.reportId || '',
            },
            android: {
                priority: 'high',
                notification: {
                    channel_id: 'emergency_calls',
                    priority: 'high',
                    default_vibrate_timings: true,
                    default_sound: true,
                },
            },
            apns: {
                payload: {
                    aps: {
                        sound: 'emergency_alert.wav',
                        badge: 1,
                    },
                },
            },
        };

        try {
            await admin.messaging().send(message);
            console.log('Notification sent successfully');
        } catch (error) {
            console.error('Error sending notification:', error);
        }
    });
```

### REST API (Express.js)

```javascript
const express = require('express');
const admin = require('firebase-admin');

const app = express();
app.use(express.json());

// Send call notification endpoint
app.post('/send-call-notification', async (req, res) => {
    const { receiverId, callerId, callerName, callId, reportId } = req.body;

    try {
        // Get receiver's FCM token
        const userDoc = await admin.firestore()
            .collection('users')
            .doc(receiverId)
            .get();

        const fcmToken = userDoc.get('fcmToken');

        const message = {
            token: fcmToken,
            notification: {
                title: '🚨 EMERGENCY CALL',
                body: `${callerName} is calling`,
            },
            data: {
                type: 'incoming_call',
                callId: callId,
                callerId: callerId,
                callerName: callerName,
                reportId: reportId || '',
            },
        };

        await admin.messaging().send(message);
        res.json({ success: true });

    } catch (error) {
        console.error('Error:', error);
        res.status(500).json({ error: error.message });
    }
});

app.listen(3000, () => {
    console.log('Server running on port 3000');
});
```

## Client-Side Implementation

### 1. Request Permissions
The app automatically requests notification permissions on startup.

### 2. Handle Notifications

**Foreground Notifications:**
```dart
FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  // Show local notification
  NotificationService().showIncomingCallNotification(message);
});
```

**Background Notifications:**
Handled automatically by the background message handler.

**Terminated State:**
```dart
FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
  // Navigate to appropriate screen
  navigatorKey.currentState?.pushNamed('/incoming-call', arguments: message.data);
});
```

## Testing Notifications

### 1. Using Firebase Console
1. Go to Firebase Console → Cloud Messaging
2. Create a new notification
3. Target a specific device using FCM token
4. Test with the data payload format above

### 2. Using cURL
```bash
curl -X POST -H "Authorization: key=YOUR_SERVER_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "to": "DEVICE_FCM_TOKEN",
    "notification": {
      "title": "🚨 EMERGENCY CALL",
      "body": "Someone is calling"
    },
    "data": {
      "type": "incoming_call",
      "callId": "call_123",
      "callerId": "user_456",
      "callerName": "John Doe"
    }
  }' \
  https://fcm.googleapis.com/fcm/send
```

## Troubleshooting

### Common Issues

1. **Notifications not received:**
   - Check FCM token is saved in user profile
   - Verify server key is correct
   - Check device notification permissions

2. **Background notifications not working:**
   - Ensure background handler is registered in main()
   - Check AndroidManifest for proper configuration

3. **iOS notifications not working:**
   - Verify APNs certificate in Firebase Console
   - Check Info.plist configuration
   - Ensure app is not in "Do Not Disturb" mode

### Debug Tips

1. **Check FCM Token:**
```dart
String? token = await FirebaseMessaging.instance.getToken();
print('FCM Token: $token');
```

2. **Test Local Notifications:**
```dart
await NotificationService().showTestNotification(
  title: 'Test',
  body: 'This is a test notification',
);
```

3. **Monitor FCM Messages:**
Use Firebase Console → Cloud Messaging → Reports

## Security Considerations

1. **Token Validation:** Always validate FCM tokens before sending
2. **Rate Limiting:** Implement rate limiting to prevent spam
3. **User Consent:** Only send notifications to users who have consented
4. **Data Encryption:** Encrypt sensitive data in notification payloads

## Production Deployment

1. **Server Setup:** Deploy Cloud Functions or your server
2. **Environment Variables:** Store server keys securely
3. **Monitoring:** Set up monitoring for notification delivery
4. **Backup Systems:** Have fallback notification methods

## Cost Considerations

- **FCM is free** for most use cases
- **Cloud Functions** have a generous free tier
- **Monitor usage** in Firebase Console
- **Optimize payloads** to reduce data costs
