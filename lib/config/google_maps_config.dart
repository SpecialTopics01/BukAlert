// Google Maps API Configuration
class GoogleMapsConfig {
  // Replace with your actual Google Maps API key
  static const String apiKey = 'AIzaSyBUV8Ag1aOioVL3SErpMIItjsGAbnE9sR4';

  // Map settings
  static const double defaultZoom = 15.0;
  static const double minZoom = 10.0;
  static const double maxZoom = 20.0;

  // Location update settings
  static const Duration locationUpdateInterval = Duration(seconds: 30);
  static const double locationUpdateDistanceFilter = 10.0; // meters

  // Emergency zone settings
  static const double emergencyRadius = 1000.0; // 1km radius for emergency zones
  static const double unitSearchRadius = 5000.0; // 5km radius for finding units

  // Map styles
  static const String emergencyMapStyle = '''
  [
    {
      "featureType": "poi",
      "stylers": [
        {
          "visibility": "off"
        }
      ]
    },
    {
      "featureType": "transit",
      "stylers": [
        {
          "visibility": "off"
        }
      ]
    }
  ]
  ''';

  // Marker icons
  static const double userMarkerSize = 40.0;
  static const double unitMarkerSize = 35.0;
  static const double emergencyMarkerSize = 45.0;

  // Animation settings
  static const Duration mapAnimationDuration = Duration(milliseconds: 500);
  static const Duration markerAnimationDuration = Duration(milliseconds: 300);

  // Clustering settings
  static const int maxMarkersBeforeClustering = 50;
  static const double clusterRadius = 50.0;
}
