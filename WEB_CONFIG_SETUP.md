# BukAlert Web Configuration Setup

This guide helps you configure BukAlert for web deployment, especially for Vercel.

## Firebase Web Configuration

### 1. Add Web App to Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your BukAlert project
3. Click the gear icon → "Project settings"
4. Scroll down to "Your apps" section
5. Click the "</>" icon to add a web app
6. Enter app details:
   - App nickname: "BukAlert Web"
   - Also set up Firebase Hosting: **No** (we're using Vercel)
7. Copy the Firebase config

### 2. Update Firebase Options

Update `lib/firebase_options.dart` with your web configuration:

```dart
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    // ... keep other platforms as they are

    static const FirebaseOptions web = FirebaseOptions(
      apiKey: 'your-web-api-key',
      authDomain: 'your-project.firebaseapp.com',
      projectId: 'your-project-id',
      storageBucket: 'your-project.appspot.com',
      messagingSenderId: 'your-messaging-sender-id',
      appId: 'your-web-app-id',
      measurementId: 'your-measurement-id', // Optional
    );
  }
}
```

### 3. Firebase Security Rules

Update Firestore rules for web access:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow read/write for authenticated users
    match /{document=**} {
      allow read, write: if request.auth != null;
    }

    // Allow read for public emergency data
    match /emergency_reports/{reportId} {
      allow read: if true; // Public read for emergency info
      allow write: if request.auth != null;
    }

    // Allow read for rescue units (public info)
    match /rescue_units/{unitId} {
      allow read: if true;
      allow write: if request.auth != null &&
                   request.auth.token.admin == true;
    }
  }
}
```

## Google Maps Web Setup

### 1. Get API Key

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your project
3. Enable "Maps JavaScript API"
4. Create an API key
5. Restrict the API key to:
   - Maps JavaScript API
   - Your Vercel domain (e.g., `*.vercel.app`)

### 2. Update Configuration

Update `lib/config/google_maps_config.dart`:

```dart
class GoogleMapsConfig {
  // Use your web API key
  static const String apiKey = 'YOUR_GOOGLE_MAPS_WEB_API_KEY';
  // ... rest of configuration stays the same
}
```

## Agora.io Web Setup

### 1. Web Configuration

Agora.io works with web browsers. Update `lib/config/agora_config.dart`:

```dart
class AgoraConfig {
  static const String appId = 'YOUR_AGORA_APP_ID';
  static const String appCertificate = 'YOUR_AGORA_APP_CERTIFICATE';

  // Web-specific settings
  static const bool preferH264 = false; // VP8 works better in web
  static const int maxVideoBitrate = 1000; // Lower for web stability
}
```

### 2. Browser Permissions

Web browsers require explicit user permission for:
- Camera access
- Microphone access
- Geolocation (if used)

## Vercel Environment Variables

### Required Variables

Set these in Vercel dashboard (Project Settings → Environment Variables):

```bash
# Firebase (for web - same as firebase_options.dart)
VITE_FIREBASE_API_KEY=your-api-key
VITE_FIREBASE_AUTH_DOMAIN=your-project.firebaseapp.com
VITE_FIREBASE_PROJECT_ID=your-project-id

# Google Maps
VITE_GOOGLE_MAPS_API_KEY=your-google-maps-api-key

# Agora (optional - can be in code for web)
VITE_AGORA_APP_ID=your-agora-app-id
```

## Web-Specific Features

### What Works in Web:
- ✅ User authentication
- ✅ Firestore database
- ✅ Emergency reporting
- ✅ Basic map display
- ✅ Responsive design
- ✅ Text-based communication

### What Needs Browser Permissions:
- ⚠️ Camera/Microphone (for video calls)
- ⚠️ Geolocation (for location services)
- ⚠️ Notifications (browser notifications instead of push)

### What Doesn't Work in Web:
- ❌ Native push notifications
- ❌ Advanced device features
- ❌ Background location tracking
- ❌ Native file system access

## Testing Web Version

### Local Testing

```bash
# Test locally
flutter run -d chrome

# Build for web
flutter build web --release

# Serve locally
cd build/web
python -m http.server 8000  # or use any web server
```

### Browser Compatibility

Test on:
- ✅ Chrome/Chromium (recommended)
- ✅ Firefox
- ✅ Safari
- ✅ Edge
- ❌ Internet Explorer (not supported)

### Feature Testing Checklist

- [ ] App loads without errors
- [ ] Firebase authentication works
- [ ] Emergency reporting submits
- [ ] Map displays with valid API key
- [ ] Video calling works (with permissions)
- [ ] Responsive design adapts to screen size
- [ ] No console errors in browser dev tools

## Deployment Checklist

### Pre-deployment:
- [ ] Firebase web config updated
- [ ] Google Maps API key configured
- [ ] Agora credentials set
- [ ] Vercel environment variables configured
- [ ] Web build tested locally

### Post-deployment:
- [ ] Test all features on Vercel URL
- [ ] Check browser console for errors
- [ ] Verify HTTPS is working
- [ ] Test on mobile browsers
- [ ] Monitor performance metrics

## Troubleshooting Web Issues

### Common Problems:

1. **Firebase not connecting**:
   - Check `firebase_options.dart` web config
   - Verify authorized domains in Firebase Console
   - Check browser network tab for failed requests

2. **Map not loading**:
   - Verify Google Maps API key
   - Check API key restrictions
   - Ensure Maps JavaScript API is enabled

3. **Video calling failing**:
   - Check Agora credentials
   - Verify HTTPS (required for WebRTC)
   - Check browser permissions
   - Test camera/microphone access

4. **Authentication issues**:
   - Verify Firebase Auth domain configuration
   - Check OAuth redirect URIs
   - Test with different browsers

5. **Performance issues**:
   - Check network tab for large assets
   - Verify code splitting is working
   - Monitor Core Web Vitals

## Performance Optimization

### Web-Specific Optimizations:

1. **Code Splitting**:
   ```dart
   // Flutter automatically handles code splitting for web
   // Large apps benefit from deferred loading
   ```

2. **Asset Optimization**:
   - Use WebP images
   - Enable gzip compression
   - Cache static assets

3. **Bundle Size**:
   - Monitor with `flutter build web --analyze-size`
   - Remove unused dependencies
   - Use tree shaking

4. **Loading Performance**:
   - Optimize initial bundle size
   - Use lazy loading for routes
   - Implement service worker caching

## Security for Web

### Web-Specific Security:

1. **Content Security Policy**:
   ```html
   <!-- Add to web/index.html -->
   <meta http-equiv="Content-Security-Policy" content="...">
   ```

2. **API Key Protection**:
   - Use environment variables
   - Restrict API keys to domains
   - Never expose sensitive keys in client code

3. **HTTPS Enforcement**:
   - Vercel provides SSL automatically
   - All WebRTC requires HTTPS

## Monitoring Web Performance

### Vercel Analytics:
- Page load times
- Error rates
- User engagement
- Core Web Vitals

### Firebase Performance:
- Network request monitoring
- App startup time
- Custom performance traces

### Browser DevTools:
- Network tab for API calls
- Performance tab for bottlenecks
- Console for JavaScript errors

---

**Ready for Web Deployment**: Once configured, run `deploy.bat` (Windows) or `./deploy.sh` (Linux/Mac) to deploy to Vercel.
