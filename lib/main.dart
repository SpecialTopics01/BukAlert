import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'services/firebase_service.dart';
import 'services/notification_service.dart';
import 'services/background_message_handler.dart';
import 'providers/auth_provider.dart';
import 'providers/emergency_provider.dart';
import 'providers/call_provider.dart';
import 'providers/location_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/splash_screen.dart';
import 'screens/citizen/emergency_report_screen.dart';
import 'widgets/incoming_call_dialog.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Set up background message handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Initialize Firebase service
  await FirebaseService().initializeFirebase();

  runApp(const BukAlertApp());
}

class BukAlertApp extends StatelessWidget {
  const BukAlertApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => EmergencyProvider()),
        ChangeNotifierProvider(create: (_) => CallProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
      ],
      child: MaterialApp(
        title: 'BukAlert - Emergency Response',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFD32F2F), // Red theme for emergency app
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          fontFamily: 'Roboto',
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFFD32F2F),
            foregroundColor: Colors.white,
            elevation: 2,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          cardTheme: const CardThemeData(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
        ),
        home: const AppWithIncomingCalls(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/emergency_report': (context) => const EmergencyReportScreen(),
          // Add more routes as we build screens
        },
      ),
    );
  }
}

class AppWithIncomingCalls extends StatefulWidget {
  const AppWithIncomingCalls({super.key});

  @override
  State<AppWithIncomingCalls> createState() => _AppWithIncomingCallsState();
}

class _AppWithIncomingCallsState extends State<AppWithIncomingCalls> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const SplashScreen(),
        Consumer<CallProvider>(
          builder: (context, callProvider, child) {
            if (callProvider.hasIncomingCall) {
              // Show incoming call dialog
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _showIncomingCallDialog(context, callProvider);
              });
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  void _showIncomingCallDialog(BuildContext context, CallProvider callProvider) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => IncomingCallDialog(
        invitation: callProvider.currentIncomingCall!,
        signalingService: callProvider.callSignalingService,
      ),
    ).then((_) {
      // Clear the incoming call when dialog is dismissed
      callProvider.clearIncomingCall();
    });
  }
}
