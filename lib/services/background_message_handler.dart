import 'package:firebase_messaging/firebase_messaging.dart';
import 'notification_service.dart';

/// Handle background messages from FCM
/// This must be a top-level function as required by FCM
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling background message: ${message.messageId}');
  print('Message data: ${message.data}');

  if (message.data['type'] == 'incoming_call') {
    final notificationService = NotificationService();
    await notificationService.initialize();

    // Show local notification for incoming call
    await notificationService.showIncomingCallNotification(message);
  }
}
