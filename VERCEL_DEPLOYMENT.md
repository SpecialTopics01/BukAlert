# BukAlert Vercel Deployment Guide

This guide explains how to deploy the BukAlert Flutter web app to Vercel for testing purposes.

## Prerequisites

1. **Vercel Account**: Sign up at [vercel.com](https://vercel.com)
2. **Git Repository**: Your BukAlert project should be in a Git repository
3. **Firebase Configuration**: Web version needs Firebase config
4. **Agora Configuration**: Video calling requires Agora setup

## Build Configuration

### 1. Web Build Setup

The Flutter web build has been configured with the following settings:

```json
// vercel.json
{
  "version": 2,
  "builds": [
    {
      "src": "build/web/**",
      "use": "@vercel/static"
    }
  ],
  "routes": [
    {
      "src": "/(.*)",
      "dest": "/index.html"
    }
  ],
  "headers": [
    {
      "source": "/(.*)",
      "headers": [
        {
          "key": "Cache-Control",
          "value": "public, max-age=31536000, immutable"
        }
      ]
    },
    {
      "source": "/index.html",
      "headers": [
        {
          "key": "Cache-Control",
          "value": "public, max-age=0, must-revalidate"
        }
      ]
    }
  ]
}
```

### 2. Firebase Web Configuration

Update `lib/firebase_options.dart` with your Firebase web configuration:

```dart
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    // ... other platforms

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
```

### 3. Web-Specific Configurations

Some features may not work in web browsers:

**Limited Features in Web Version:**
- Push notifications (use browser notifications)
- Camera/microphone (works but needs user permission)
- GPS/location (works with browser geolocation API)
- File system access (limited)
- Native device features (not available)

## Deployment Steps

### Method 1: Vercel CLI (Recommended)

1. **Install Vercel CLI**:
   ```bash
   npm install -g vercel
   ```

2. **Login to Vercel**:
   ```bash
   vercel login
   ```

3. **Deploy from project root**:
   ```bash
   cd bukalert
   vercel --prod
   ```

4. **Follow the prompts**:
   - Link to existing project or create new
   - Set project name (bukalert-web)
   - Configure build settings

### Method 2: GitHub Integration

1. **Push code to GitHub**:
   ```bash
   git add .
   git commit -m "Add Vercel deployment configuration"
   git push origin main
   ```

2. **Connect to Vercel**:
   - Go to [vercel.com](https://vercel.com)
   - Click "Import Project"
   - Connect your GitHub repository
   - Vercel will auto-detect Flutter web project

3. **Configure Build Settings**:
   ```
   Build Command: flutter build web --release
   Output Directory: build/web
   Install Command: flutter pub get
   ```

### Method 3: Manual Upload

1. **Build the web app**:
   ```bash
   flutter build web --release
   ```

2. **Create deployment package**:
   ```bash
   cd build/web
   # The contents of this directory can be uploaded to Vercel
   ```

3. **Upload via Vercel Dashboard**:
   - Go to Vercel dashboard
   - Click "Import Project"
   - Choose "Upload" option
   - Upload the `build/web` folder contents

## Environment Variables

Set these environment variables in Vercel dashboard (Project Settings > Environment Variables):

```bash
# Firebase Configuration (if needed for server-side)
FIREBASE_API_KEY=your-api-key
FIREBASE_PROJECT_ID=your-project-id

# Agora Configuration
AGORA_APP_ID=your-agora-app-id
AGORA_APP_CERTIFICATE=your-agora-certificate

# Google Maps (Web)
GOOGLE_MAPS_API_KEY=your-google-maps-api-key
```

## Custom Domain (Optional)

1. **Add custom domain in Vercel**:
   - Go to Project Settings > Domains
   - Add your domain (e.g., bukalert-web.vercel.app)

2. **Update Firebase**:
   - Add your Vercel domain to Firebase authorized domains
   - Update OAuth redirect URIs if using authentication

## Testing the Web App

### What Works in Web Version:
- ✅ User interface and navigation
- ✅ Firebase authentication
- ✅ Firestore database operations
- ✅ Emergency reporting forms
- ✅ Basic map display (with Google Maps API key)
- ✅ Text-based chat/messaging
- ✅ Responsive design across screen sizes

### What Doesn't Work in Web Version:
- ❌ Native push notifications (use browser notifications)
- ❌ Advanced camera controls (basic camera access works)
- ❌ Native GPS (uses browser geolocation)
- ❌ Background location tracking
- ❌ Native file system access
- ❌ Some device-specific features

### Testing Checklist:
- [ ] App loads without errors
- [ ] Authentication works (login/signup)
- [ ] Navigation between screens works
- [ ] Emergency reporting form submits
- [ ] Map displays (with valid API key)
- [ ] Responsive design on different screen sizes
- [ ] Browser console shows no critical errors

## Troubleshooting

### Common Issues:

1. **Build Fails**:
   ```bash
   # Clear build cache
   flutter clean
   flutter pub cache repair
   flutter build web --release
   ```

2. **Firebase Not Working**:
   - Check Firebase configuration in `firebase_options.dart`
   - Ensure web app is added to Firebase project
   - Verify authorized domains include Vercel domain

3. **Map Not Loading**:
   - Add Google Maps API key to `google_maps_config.dart`
   - Enable Maps JavaScript API in Google Cloud Console
   - Add Vercel domain to API key restrictions

4. **Video Calling Issues**:
   - Video calling requires HTTPS (Vercel provides this)
   - Browser permissions for camera/microphone
   - Valid Agora credentials

5. **404 Errors**:
   - Check `vercel.json` configuration
   - Ensure `index.html` is in build output
   - Verify routing configuration

### Debug Commands:

```bash
# Check Flutter web build
flutter doctor
flutter devices
flutter build web --verbose

# Test locally
flutter run -d chrome

# Check Vercel deployment logs
vercel logs [deployment-url]
```

## Performance Optimization

### Vercel Optimizations:
1. **Caching**: Static assets cached for 1 year
2. **Compression**: Automatic gzip compression
3. **CDN**: Global content delivery network
4. **Edge Functions**: Fast serverless functions

### Flutter Web Optimizations:
1. **Code Splitting**: Reduces initial bundle size
2. **Tree Shaking**: Removes unused code
3. **Lazy Loading**: Loads features on demand
4. **Image Optimization**: WebP format for images

## Security Considerations

### Web-Specific Security:
1. **HTTPS Only**: Vercel provides SSL certificates
2. **Content Security Policy**: Configure CSP headers
3. **API Key Protection**: Don't expose sensitive keys in client code
4. **CORS Configuration**: Configure cross-origin requests

### Firebase Security:
1. **Firestore Rules**: Restrict access based on authentication
2. **Realtime Database Rules**: Secure data access
3. **Storage Rules**: Control file upload/download permissions

## Monitoring & Analytics

### Vercel Analytics:
- Real-time performance monitoring
- Error tracking
- User analytics
- Performance metrics

### Firebase Analytics:
- User engagement tracking
- Crash reporting
- Performance monitoring
- Custom event tracking

## Production Deployment

### Pre-deployment Checklist:
- [ ] Firebase configuration updated
- [ ] API keys configured securely
- [ ] Environment variables set
- [ ] Domain configured (optional)
- [ ] SSL certificate active
- [ ] Performance tested
- [ ] Security audit completed

### Post-deployment:
1. **Monitor Performance**: Check Vercel dashboard
2. **Test Critical Features**: Verify core functionality
3. **Set up Monitoring**: Configure error tracking
4. **User Testing**: Get feedback from test users
5. **Scale as Needed**: Monitor usage and scale resources

## Cost Considerations

### Vercel Pricing:
- **Hobby Plan**: Free for basic usage
- **Pro Plan**: $20/month for advanced features
- **Enterprise**: Custom pricing for large deployments

### Firebase Pricing:
- **Spark Plan**: Free tier with limits
- **Blaze Plan**: Pay-as-you-go for production
- **Monitor usage** to avoid unexpected costs

## Support & Maintenance

### Regular Maintenance:
1. **Update Dependencies**: Keep Flutter and packages updated
2. **Security Updates**: Apply security patches promptly
3. **Performance Monitoring**: Track and optimize performance
4. **User Feedback**: Incorporate user suggestions

### Support Resources:
- [Vercel Documentation](https://vercel.com/docs)
- [Flutter Web Docs](https://flutter.dev/web)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Agora Documentation](https://docs.agora.io)

---

**Deployment URL**: Your app will be available at `https://bukalert-web.vercel.app` (or your custom domain)

**Build Status**: Check Vercel dashboard for build status and logs

**Performance**: Monitor Core Web Vitals in Vercel dashboard
