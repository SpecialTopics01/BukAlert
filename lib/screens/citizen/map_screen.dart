import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../services/location_service.dart';
import '../../models/rescue_unit_model.dart';
import '../../models/location_data_model.dart';
import '../../providers/call_provider.dart';
import '../../providers/location_provider.dart';
import '../../config/google_maps_config.dart';
import 'video_call_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _mapController;
  final LocationService _locationService = LocationService();

  LatLng? _currentPosition;
  bool _isLoading = true;
  Set<Marker> _markers = {};
  Set<Circle> _circles = {};
  BitmapDescriptor? _userMarkerIcon;
  BitmapDescriptor? _unitMarkerIcon;
  BitmapDescriptor? _emergencyMarkerIcon;

  @override
  void initState() {
    super.initState();
    _initializeMap();
    _loadMarkerIcons();
    _listenToProviders();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Load nearby units when the screen is shown
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);
    locationProvider.loadNearbyUnits();
  }

  Future<void> _initializeMap() async {
    try {
      final position = await _locationService.getCurrentLocation();
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });

      // Add current location marker
      _addCurrentLocationMarker();

      // Load nearby rescue units
      _loadNearbyUnits();
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Unable to get current location'),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: _initializeMap,
            ),
          ),
        );
      }
    }
  }

  Future<void> _loadMarkerIcons() async {
    // Load custom marker icons
    _userMarkerIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(40, 40)),
      'assets/icons/user_location.png',
    ) as BitmapDescriptor?;

    _unitMarkerIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(35, 35)),
      'assets/icons/rescue_unit.png',
    ) as BitmapDescriptor?;

    _emergencyMarkerIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(45, 45)),
      'assets/icons/emergency.png',
    ) as BitmapDescriptor?;
  }

  void _listenToProviders() {
    // Listen to location provider for real-time updates
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);
    locationProvider.addListener(_onLocationProviderUpdate);
  }

  void _onLocationProviderUpdate() {
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);

    // Update nearby units markers
    _updateNearbyUnitsMarkers(locationProvider.nearbyUnits);

    // Update unit location markers
    _updateUnitLocationMarkers(locationProvider.unitLocations);
  }

  @override
  void dispose() {
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);
    locationProvider.removeListener(_onLocationProviderUpdate);
    super.dispose();
  }

  void _addCurrentLocationMarker() {
    if (_currentPosition == null) return;

    final marker = Marker(
      markerId: const MarkerId('current_location'),
      position: _currentPosition!,
      icon: _userMarkerIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      infoWindow: const InfoWindow(
        title: 'Your Location',
        snippet: 'Current location',
      ),
    );

    setState(() {
      _markers.add(marker);
    });
  }

  void _loadNearbyUnits() {
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);
    _updateNearbyUnitsMarkers(locationProvider.nearbyUnits);
  }

  void _updateNearbyUnitsMarkers(List<Map<String, dynamic>> units) {
    // Remove existing unit markers
    _markers.removeWhere((marker) => marker.markerId.value.startsWith('unit_'));

    final unitMarkers = units.map((unit) {
      final unitId = unit['id'] as String? ?? 'unknown';
      final name = unit['name'] as String? ?? 'Unknown Unit';
      final type = unit['type'] as String? ?? 'Unknown';
      final latitude = unit['latitude'] as double? ?? 0.0;
      final longitude = unit['longitude'] as double? ?? 0.0;
      final isAvailable = unit['isAvailable'] as bool? ?? false;

      return Marker(
        markerId: MarkerId('unit_$unitId'),
        position: LatLng(latitude, longitude),
        icon: _unitMarkerIcon ?? BitmapDescriptor.defaultMarkerWithHue(
          isAvailable ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueRed,
        ),
        infoWindow: InfoWindow(
          title: name,
          snippet: '$type • ${isAvailable ? 'Available' : 'Busy'}',
        ),
        onTap: () => _showUnitDetailsFromMap(unit),
      );
    });

    setState(() {
      _markers.addAll(unitMarkers);
    });
  }

  void _updateUnitLocationMarkers(Map<String, LocationData> unitLocations) {
    // Remove existing unit location markers
    _markers.removeWhere((marker) => marker.markerId.value.startsWith('unit_location_'));

    final locationMarkers = unitLocations.entries.map((entry) {
      final unitId = entry.key;
      final location = entry.value;

      return Marker(
        markerId: MarkerId('unit_location_$unitId'),
        position: LatLng(location.latitude, location.longitude),
        icon: _unitMarkerIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
        infoWindow: InfoWindow(
          title: 'Unit Location',
          snippet: 'Updated ${location.timeAgo}',
        ),
      );
    });

    setState(() {
      _markers.addAll(locationMarkers);
    });
  }

  void _showUnitDetailsFromMap(Map<String, dynamic> unit) {
    final unitId = unit['id'] as String? ?? 'unknown';
    final name = unit['name'] as String? ?? 'Unknown Unit';
    final type = unit['type'] as String? ?? 'Unknown';
    final phoneNumber = unit['phoneNumber'] as String?;
    final isAvailable = unit['isAvailable'] as bool? ?? false;

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              type,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  isAvailable ? Icons.check_circle : Icons.cancel,
                  color: isAvailable ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  isAvailable ? 'Available' : 'Currently Busy',
                  style: TextStyle(
                    color: isAvailable ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (phoneNumber != null) ...[
              const SizedBox(height: 8),
              Text(
                phoneNumber,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                if (phoneNumber != null)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Calling $name...')),
                        );
                      },
                      icon: const Icon(Icons.call),
                      label: const Text('Call'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                    ),
                  ),
                if (phoneNumber != null) const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      Navigator.of(context).pop();

                      final callProvider = Provider.of<CallProvider>(context, listen: false);

                      // Start video call
                      final success = await callProvider.makeCall(
                        receiverId: unitId,
                        receiverName: name,
                        isVideoCall: true,
                      );

                      if (success && mounted) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => VideoCallScreen(
                              callId: callProvider.currentCallId!,
                              receiverId: unitId,
                              receiverName: name,
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Failed to start video call'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.videocam),
                    label: const Text('Video Call'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD32F2F),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    if (_currentPosition != null) {
      _mapController.animateCamera(
        CameraUpdate.newLatLngZoom(_currentPosition!, 15),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Map'),
        backgroundColor: const Color(0xFFD32F2F),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () {
              if (_currentPosition != null) {
                _mapController.animateCamera(
                  CameraUpdate.newLatLngZoom(_currentPosition!, 15),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _initializeMap,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _currentPosition == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_off,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Unable to get location',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _initializeMap,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: _currentPosition!,
                    zoom: GoogleMapsConfig.defaultZoom,
                  ),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  markers: _markers,
                  circles: _circles,
                  mapType: MapType.normal,
                  minMaxZoomPreference: MinMaxZoomPreference(
                    GoogleMapsConfig.minZoom,
                    GoogleMapsConfig.maxZoom,
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFD32F2F),
        onPressed: () {
          // Quick emergency report
          Navigator.of(context).pushNamed('/emergency_report');
        },
        child: const Icon(Icons.warning),
      ),
    );
  }
}
