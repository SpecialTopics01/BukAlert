// Agora.io Configuration
// Replace these values with your actual Agora.io credentials

class AgoraConfig {
  // Get these from your Agora.io Console
  static const String appId = 'YOUR_AGORA_APP_ID';
  static const String appCertificate = 'YOUR_AGORA_APP_CERTIFICATE';

  // Token generation settings
  static const int tokenExpireTime = 3600; // 1 hour in seconds
  static const int privilegeExpireTime = 3600; // 1 hour in seconds

  // Channel settings
  static const int maxUsersPerChannel = 2; // 1-on-1 calls
  static const int videoProfile = 30; // 480p video quality

  // Quality settings
  static const bool enableDualStream = false;
  static const bool enableAudioVolumeIndication = true;

  // Development mode
  static const bool isProduction = false;

  // For development, you can use temporary tokens from Agora Console
  // For production, implement server-side token generation
  static String getTempToken(String channelName, String uid) {
    // This is just a placeholder - implement proper token generation
    // In production, this should be done server-side
    return 'YOUR_TEMP_TOKEN_FOR_${channelName}_$uid';
  }
}
