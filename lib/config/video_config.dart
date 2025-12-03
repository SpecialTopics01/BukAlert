import 'package:agora_rtc_engine/agora_rtc_engine.dart';

// Video codec and quality configuration for Agora.io
enum VideoCodec {
  vp8,
  h264,
  auto, // Let Agora choose the best codec
}

class VideoConfig {
  // Default video codec
  static const VideoCodec defaultCodec = VideoCodec.vp8;

  // Video codec settings
  static const Map<VideoCodec, VideoCodecType> codecMap = {
    VideoCodec.vp8: VideoCodecType.videoCodecVp8,
    VideoCodec.h264: VideoCodecType.videoCodecH264,
    VideoCodec.auto: VideoCodecType.videoCodecNone, // Let Agora decide
  };

  // Video encoder configuration for VP8
  static const VideoEncoderConfiguration vp8EncoderConfig = VideoEncoderConfiguration(
    codecType: VideoCodecType.videoCodecVp8,
    dimensions: VideoDimensions(width: 640, height: 360), // 360p for better quality
    frameRate: 30,
    bitrate: 800, // kbps - good balance for VP8
    minBitrate: 400,
    orientationMode: OrientationMode.orientationModeAdaptive,
    degradationPreference: DegradationPreference.maintainFramerate,
    mirrorMode: VideoMirrorModeType.videoMirrorModeDisabled,
  );

  // High quality VP8 configuration
  static const VideoEncoderConfiguration vp8HighQualityConfig = VideoEncoderConfiguration(
    codecType: VideoCodecType.videoCodecVp8,
    dimensions: VideoDimensions(width: 1280, height: 720), // 720p
    frameRate: 30,
    bitrate: 1500, // Higher bitrate for HD
    minBitrate: 800,
    orientationMode: OrientationMode.orientationModeAdaptive,
    degradationPreference: DegradationPreference.maintainQuality,
    mirrorMode: VideoMirrorModeType.videoMirrorModeDisabled,
  );

  // Low bandwidth VP8 configuration
  static const VideoEncoderConfiguration vp8LowBandwidthConfig = VideoEncoderConfiguration(
    codecType: VideoCodecType.videoCodecVp8,
    dimensions: VideoDimensions(width: 480, height: 270), // 270p for low bandwidth
    frameRate: 24,
    bitrate: 400, // Lower bitrate for poor connections
    minBitrate: 200,
    orientationMode: OrientationMode.orientationModeAdaptive,
    degradationPreference: DegradationPreference.maintainFramerate,
    mirrorMode: VideoMirrorModeType.videoMirrorModeDisabled,
  );

  // H264 encoder configuration (fallback)
  static const VideoEncoderConfiguration h264EncoderConfig = VideoEncoderConfiguration(
    codecType: VideoCodecType.videoCodecH264,
    dimensions: VideoDimensions(width: 640, height: 360),
    frameRate: 30,
    bitrate: 800,
    minBitrate: 400,
    orientationMode: OrientationMode.orientationModeAdaptive,
    degradationPreference: DegradationPreference.maintainFramerate,
    mirrorMode: VideoMirrorModeType.videoMirrorModeDisabled,
  );

  // Get encoder configuration based on codec and quality preference
  static VideoEncoderConfiguration getEncoderConfig({
    VideoCodec codec = defaultCodec,
    VideoQuality quality = VideoQuality.medium,
  }) {
    switch (codec) {
      case VideoCodec.vp8:
        switch (quality) {
          case VideoQuality.low:
            return vp8LowBandwidthConfig;
          case VideoQuality.high:
            return vp8HighQualityConfig;
          case VideoQuality.medium:
          default:
            return vp8EncoderConfig;
        }
      case VideoCodec.h264:
        return h264EncoderConfig;
      case VideoCodec.auto:
      default:
        // Return VP8 medium quality as default for auto
        return vp8EncoderConfig;
    }
  }

  // Video quality presets
  static const Map<VideoQuality, String> qualityLabels = {
    VideoQuality.low: 'Low (480p)',
    VideoQuality.medium: 'Medium (360p)',
    VideoQuality.high: 'High (720p)',
  };

  // Codec display names
  static const Map<VideoCodec, String> codecLabels = {
    VideoCodec.vp8: 'VP8 (Recommended)',
    VideoCodec.h264: 'H.264',
    VideoCodec.auto: 'Auto',
  };

  // Check if VP8 is supported on current platform
  static Future<bool> isVp8Supported() async {
    // VP8 is widely supported, but we can add platform-specific checks here
    // For now, assume VP8 is supported on all platforms Agora supports
    return true;
  }

  // Get optimal codec for current network conditions
  static VideoCodec getOptimalCodecForNetwork({
    required int bandwidthKbps,
    required bool preferVp8,
  }) {
    if (preferVp8 && bandwidthKbps >= 500) {
      return VideoCodec.vp8;
    } else if (bandwidthKbps >= 800) {
      return VideoCodec.h264; // H264 performs better at higher bitrates
    } else {
      return VideoCodec.vp8; // VP8 is more efficient at lower bitrates
    }
  }

  // Adaptive quality based on network conditions
  static VideoQuality getAdaptiveQuality({
    required int bandwidthKbps,
    required int latencyMs,
  }) {
    if (bandwidthKbps >= 1500 && latencyMs < 100) {
      return VideoQuality.high;
    } else if (bandwidthKbps >= 600 && latencyMs < 150) {
      return VideoQuality.medium;
    } else {
      return VideoQuality.low;
    }
  }
}

enum VideoQuality {
  low,
  medium,
  high,
}
