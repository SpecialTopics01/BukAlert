import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../models/call_signaling_model.dart';
import 'firebase_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final FirebaseService _firebaseService = FirebaseService();

  bool _isInitialized = false;
  String? _fcmToken;

  // Getters
  bool get isInitialized => _isInitialized;
  String? get fcmToken => _fcmToken;

  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize local notifications
    await _initializeLocalNotifications();

    // Initialize Firebase Messaging
    await _initializeFirebaseMessaging();

    _isInitialized = true;
  }

  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channel for Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'emergency_calls',
      'Emergency Calls',
      description: 'Notifications for incoming emergency video calls',
      importance: Importance.max,
      showBadge: true,
      enableVibration: true,
      enableLights: true,
      ledColor: Color(0xFFD32F2F),
      playSound: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> _initializeFirebaseMessaging() async {
    // Request permission
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined permission');
      return;
    }

    // Get FCM token
    _fcmToken = await _firebaseMessaging.getToken();
    print('FCM Token: $_fcmToken');

    // Save token to user profile
    if (_fcmToken != null && _firebaseService.currentUser != null) {
      await _firebaseService.usersCollection
          .doc(_firebaseService.currentUser!.uid)
          .update({'fcmToken': _fcmToken});
    }

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    // Handle notification taps when app was terminated
    FirebaseMessaging.onMessageOpenedApp.listen(_onNotificationOpenedApp);
  }

  // Handle background messages
  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    print('Handling background message: ${message.messageId}');

    if (message.data['type'] == 'incoming_call') {
      final notificationService = NotificationService._instance;
      await notificationService._showIncomingCallNotification(message);
    }
  }

  // Handle foreground messages
  void _onForegroundMessage(RemoteMessage message) {
    print('Received foreground message: ${message.messageId}');

    if (message.data['type'] == 'incoming_call') {
      _showIncomingCallNotification(message);
    }
  }

  // Show incoming call notification
  Future<void> _showIncomingCallNotification(RemoteMessage message) async {
    final callData = message.data;
    final callerName = callData['callerName'] ?? 'Unknown Caller';
    final callId = callData['callId'] ?? '';
    final isVideoCall = callData['isVideoCall'] == 'true';

    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'incoming_call_channel',
      'Incoming Calls',
      channelDescription: 'Notifications for incoming calls',
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.call,
      sound: RawResourceAndroidNotificationSound('ringtone'),
      vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'ringtone.wav',
    );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      0,
      'Incoming ${isVideoCall ? 'Video' : 'Voice'} Call',
      'Call from $callerName',
      details,
      payload: jsonEncode(callData),
    );
  }

  // Handle notification opened from terminated state
  void _onNotificationOpenedApp(RemoteMessage message) {
    print('Notification opened from terminated state: ${message.messageId}');

    if (message.data['type'] == 'incoming_call') {
      // Navigate to appropriate screen
      _handleIncomingCallNotification(message.data);
    }
  }

  // Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null) {
      final data = jsonDecode(payload);
      if (data['type'] == 'incoming_call') {
        _handleIncomingCallNotification(data);
      }
    }
  }

  Future<void> showIncomingCallNotification(RemoteMessage message) async {
    final data = message.data;
    final callId = data['callId'] ?? '';
    final callerName = data['callerName'] ?? 'Unknown Caller';

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'emergency_calls',
      'Emergency Calls',
      channelDescription: 'Notifications for incoming emergency video calls',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      autoCancel: true,
      enableVibration: true,
      enableLights: true,
      ledColor: Color(0xFFD32F2F),
      ledOnMs: 1000,
      ledOffMs: 500,
      visibility: NotificationVisibility.public,
      sound: RawResourceAndroidNotificationSound('emergency_alert'),
      styleInformation: BigTextStyleInformation(''),
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'emergency_alert.wav',
      badgeNumber: 1,
    );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      callId.hashCode, // Unique notification ID
      '🚨 EMERGENCY CALL',
      '$callerName is calling',
      details,
      payload: jsonEncode({
        'type': 'incoming_call',
        'callId': callId,
        'callerName': callerName,
        'callerId': data['callerId'],
        'reportId': data['reportId'],
      }),
    );
  }

  void _handleIncomingCallNotification(Map<String, dynamic> data) {
    final callId = data['callId'] ?? '';
    final callerId = data['callerId'] ?? '';
    final callerName = data['callerName'] ?? 'Unknown Caller';
    final reportId = data['reportId'];

    // This will be handled by the main app to show the incoming call dialog
    // The CallProvider will listen for this and show the dialog
  }

  // Send push notification for incoming call
  Future<void> sendIncomingCallNotification({
    required String receiverId,
    required String callerId,
    required String callerName,
    required String callId,
    String? reportId,
  }) async {
    try {
      // Get receiver's FCM token
      final receiverDoc = await _firebaseService.usersCollection.doc(receiverId).get();
      if (!receiverDoc.exists) return;

      final receiverToken = receiverDoc.get('fcmToken') as String?;
      if (receiverToken == null) return;

      // Send notification via FCM (server-side implementation needed)
      // For now, we'll use local notification simulation
      // In production, this should be done server-side

      print('Would send FCM notification to: $receiverToken');
      print('Call from: $callerName (ID: $callerId)');
      print('Call ID: $callId');

    } catch (e) {
      print('Failed to send call notification: $e');
    }
  }

  // Show local notification for testing
  Future<void> showTestNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'test_channel',
      'Test Notifications',
      channelDescription: 'Channel for testing notifications',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );
  }

  // Cancel specific notification
  Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  // Update FCM token in user profile
  Future<void> updateFCMToken(String userId) async {
    if (_fcmToken != null) {
      await _firebaseService.usersCollection.doc(userId).update({
        'fcmToken': _fcmToken,
        'fcmTokenUpdated': DateTime.now(),
      });
    }
  }

  // Listen for token updates
  void setupTokenRefreshListener(String userId) {
    _firebaseMessaging.onTokenRefresh.listen((String token) {
      _fcmToken = token;
      updateFCMToken(userId);
    });
  }
}
