# BukAlert - Emergency Response System

A Flutter-based mobile app for emergency reporting and coordination in Bukidnon, Philippines, enhancing citizen-rescue team communication with real-time mapping, reporting, and a messenger-style video call feature.

## Features

### Citizen Module
- Real-time map showing user location and nearby rescue units
- Emergency reporting (fire, medical, crime, etc.)
- Quick call buttons and call history
- Bookmark rescue units
- Face verification authentication

### Admin Module
- Dashboard with reports and statistics
- Call logs with detailed information
- User and team management
- Report generation (PDF/Excel)

### Video Calling
- Messenger-style video calls between citizens and rescue admins
- One-to-one and group calls
- Screen sharing for incident visuals
- Low-latency support for rural areas

## Tech Stack

- **Frontend**: Flutter (Dart) for cross-platform Android/iOS
- **Backend**: Firebase (Firestore, Authentication, Storage)
- **Maps**: Google Maps API for location services
- **Video Calling**: Agora.io SDK with WebRTC
- **State Management**: Provider
- **UI**: Material Design 3

## Project Structure

```
lib/
├── main.dart                    # App entry point with Firebase initialization
├── firebase_options.dart        # Firebase configuration
├── services/
│   └── firebase_service.dart    # Firebase service wrapper
├── providers/
│   └── auth_provider.dart       # Authentication state management
├── models/
│   └── user_model.dart          # User data model
├── screens/
│   ├── auth/
│   │   ├── splash_screen.dart   # App splash screen
│   │   └── login_screen.dart    # Authentication screen
│   ├── citizen/
│   │   └── citizen_home_screen.dart # Citizen dashboard
│   └── admin/
│       └── admin_home_screen.dart   # Admin dashboard
├── widgets/                     # Reusable UI components
└── utils/                       # Utility functions
```

## Setup Instructions

### Prerequisites
1. Install Flutter SDK (3.0.0 or higher)
2. Install Android Studio or VS Code with Flutter extensions
3. Set up Android/iOS development environment

### Firebase Setup
1. Create a Firebase project at https://console.firebase.google.com/
2. Enable Authentication with Email/Password provider
3. Enable Firestore Database
4. Enable Firebase Cloud Messaging (FCM)
5. Enable Firebase Storage
6. Add Android/iOS apps to your Firebase project
7. Download and replace the `firebase_options.dart` file with your configuration

### Google Maps Setup
1. Enable Google Maps API in Google Cloud Console
2. Create API keys for Android and iOS
3. Add API keys to your Android manifest and iOS Info.plist

### Agora.io Setup
1. Create an account at https://console.agora.io/
2. Create a new project
3. Get your App ID and App Certificate
4. Update `lib/config/agora_config.dart` with your credentials:
   ```dart
   static const String appId = 'YOUR_ACTUAL_APP_ID';
   static const String appCertificate = 'YOUR_ACTUAL_APP_CERTIFICATE';
   ```
5. For development, generate temporary tokens from Agora Console
6. For production, implement server-side token generation

### Installation
1. Clone the repository
2. Navigate to the project directory: `cd bukalert`
3. Install dependencies: `flutter pub get`
4. Configure Firebase options in `lib/firebase_options.dart`
5. Run the app: `flutter run`

## Building the App

### Debug Build
```bash
flutter run
```

### Release Build for Android
```bash
flutter build apk --release
```

### Release Build for iOS
```bash
flutter build ios --release
```

### Web Build for Vercel Deployment
```bash
flutter build web --release
```

## Web Deployment (Vercel)

### Quick Deployment
1. **Configure Firebase & APIs** (see [Web Config Setup](WEB_CONFIG_SETUP.md))
2. **Build for web**: `flutter build web --release`
3. **Deploy to Vercel**:
   ```bash
   # Windows
   deploy.bat --prod

   # Linux/Mac
   ./deploy.sh --prod
   ```

### What Works in Web Version
- ✅ User authentication & profiles
- ✅ Emergency reporting system
- ✅ Real-time map display (with API key)
- ✅ Responsive design across devices
- ✅ Firestore database operations

### Limitations in Web Version
- ⚠️ Video calling requires browser permissions
- ⚠️ Push notifications use browser notifications
- ⚠️ GPS uses browser geolocation API
- ❌ Background location tracking
- ❌ Native device features

### Testing Web App
```bash
# Test locally
flutter run -d chrome

# Deploy to Vercel for testing
vercel
```

## Configuration Files

### Android Configuration
- Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
```

### iOS Configuration
- Add to `ios/Runner/Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access for video calling and face verification</string>
<key>NSMicrophoneUsageDescription</key>
<string>This app needs microphone access for video calling</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs location access to show nearby rescue units</string>
```

## Current Implementation Status

### ✅ Completed
- Flutter project setup with all dependencies
- Firebase configuration and initialization
- Authentication system with email/password
- Basic user roles (citizen, admin)
- Citizen and admin dashboards
- Splash screen and login screen
- Basic navigation structure
- **Emergency Reporting System**:
  - Real-time location services integration
  - Emergency report submission with categories (Fire, Medical, Crime, etc.)
  - Priority levels (Low, Medium, High, Critical)
  - Google Maps integration with nearby rescue units
  - Call history tracking
  - Report status tracking and management
- **Video Calling with Agora.io**:
  - Real-time video calling with WebRTC
  - **VP8 Codec Support**: Optimized video compression for better quality
  - Firestore-based call signaling (invite, accept, reject, end)
  - Call history and status tracking
  - Video controls (mute, camera toggle, switch camera, codec settings)
  - Dynamic codec switching during calls (VP8/H.264/Auto)
  - Adaptive video quality (Low/Medium/High)
  - Incoming call notifications with vibration
  - Call duration tracking
  - Emergency call prioritization
- **Push Notifications**:
  - Firebase Cloud Messaging (FCM) integration
  - Background message handling
  - Local notifications for incoming calls
  - Emergency call alerts with vibration
  - Notification permissions management
  - Cross-platform notification support (Android/iOS/Web)
- **Real-time Features**:
  - Live location tracking during emergencies
  - Real-time emergency report updates
  - Live rescue unit location sharing
  - Real-time dashboard statistics
  - Live call status updates
  - Location history and session management
- **UI/UX Design System**:
  - Comprehensive wireframes and design specifications
  - Responsive design implementation across all screen sizes
  - Emergency-focused color palette and typography
  - Accessible component library with touch-friendly interactions
  - Consistent spacing, animation, and interaction patterns

### 📋 Pending
- Face verification with camera
- Offline support for reports and calls
- Push notifications for incoming calls
- Report generation (PDF/Excel)
- Advanced admin features (bulk operations, analytics)

## Design Documentation

- **[UI/UX Wireframes](UI_UX_WIREFRAMES.md)** - Comprehensive wireframe specifications
- **[Design System](DESIGN_SYSTEM.md)** - Complete design system documentation
- **[FCM Setup Guide](FCM_SETUP.md)** - Push notification configuration
- **[Video Calling Guide](VIDEO_CALLING_README.md)** - Agora.io integration details
- **[Vercel Deployment Guide](VERCEL_DEPLOYMENT.md)** - Web deployment instructions
- **[Web Configuration Setup](WEB_CONFIG_SETUP.md)** - Web-specific configuration

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support, please contact the development team or create an issue in the repository.

---

**BukAlert** - Making Bukidnon safer, one emergency at a time.