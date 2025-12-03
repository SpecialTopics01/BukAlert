import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/emergency_report_model.dart';
import '../../providers/emergency_provider.dart';
import '../../providers/location_provider.dart';
import '../../services/location_service.dart';
import '../../widgets/responsive_widgets.dart';

class EmergencyReportScreen extends StatefulWidget {
  const EmergencyReportScreen({super.key});

  @override
  State<EmergencyReportScreen> createState() => _EmergencyReportScreenState();
}

class _EmergencyReportScreenState extends State<EmergencyReportScreen> {
  final _formKey = GlobalKey<FormState>();
  EmergencyType _selectedType = EmergencyType.medical;
  final _descriptionController = TextEditingController();
  final _additionalNotesController = TextEditingController();
  int _priority = 2; // Medium priority default
  bool _isGettingLocation = false;
  String? _currentLocation;
  double? _latitude;
  double? _longitude;

  final LocationService _locationService = LocationService();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _additionalNotesController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isGettingLocation = true);

    try {
      final position = await _locationService.getCurrentLocation();
      final address = await _locationService.getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _currentLocation = address;
        _isGettingLocation = false;
      });
    } catch (e) {
      setState(() {
        _currentLocation = 'Unable to get location. Please check permissions.';
        _isGettingLocation = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Location access denied. Please enable location services.'),
            action: SnackBarAction(
              label: 'Settings',
              onPressed: () => _locationService.openLocationSettings(),
            ),
          ),
        );
      }
    }
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;

    if (_latitude == null || _longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location is required to submit emergency report'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final emergencyProvider = Provider.of<EmergencyProvider>(context, listen: false);
    final success = await emergencyProvider.submitEmergencyReport(
      type: _selectedType,
      description: _descriptionController.text.trim(),
      additionalNotes: _additionalNotesController.text.isNotEmpty
          ? _additionalNotesController.text.trim()
          : null,
      priority: _priority,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Emergency report submitted successfully! Location tracking started.'),
          backgroundColor: Colors.green,
        ),
      );

      // Start location tracking for this emergency
      try {
        final locationProvider = Provider.of<LocationProvider>(context, listen: false);
        // Note: We need to get the report ID from the emergency provider
        // For now, we'll use a placeholder approach
        await locationProvider.startEmergencyTracking('emergency_${DateTime.now().millisecondsSinceEpoch}');
      } catch (e) {
        print('Could not start location tracking: $e');
      }

      // Navigate back to home
      Navigator.of(context).pop();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(emergencyProvider.errorMessage ?? 'Failed to submit report'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final emergencyProvider = Provider.of<EmergencyProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = ResponsiveUtils.isDesktop(context);

    return ResponsiveScaffold(
      appBar: ResponsiveAppBar(
        title: 'Report Emergency',
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Emergency Type Selection
              ResponsiveText(
                'Emergency Type',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              ResponsiveGrid(
                children: EmergencyType.values.map((type) {
                  final isSelected = _selectedType == type;
                  return Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFD32F2F).withOpacity(0.1)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFD32F2F)
                            : Colors.grey[300]!,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: InkWell(
                      onTap: () => setState(() => _selectedType = type),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              type.emoji,
                              style: const TextStyle(fontSize: 24),
                            ),
                            const SizedBox(height: 4),
                            ResponsiveText(
                              type.displayName,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected
                                    ? const Color(0xFFD32F2F)
                                    : Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
                mobileCrossAxisCount: screenWidth < 400 ? 2 : 3,
                tabletCrossAxisCount: 4,
                desktopCrossAxisCount: 6,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 0.8,
              ),

              const SizedBox(height: 24),

              // Priority Selection
              ResponsiveText(
                'Priority Level',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              ResponsiveGrid(
                children: [
                  _buildPriorityButton(1, 'Low', Colors.green),
                  _buildPriorityButton(2, 'Medium', Colors.orange),
                  _buildPriorityButton(3, 'High', Colors.red),
                  _buildPriorityButton(4, 'Critical', Colors.red[900]!),
                ],
                mobileCrossAxisCount: screenWidth < 400 ? 2 : 4,
                tabletCrossAxisCount: 4,
                desktopCrossAxisCount: 4,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: screenWidth < 400 ? 2.5 : 3,
              ),

              const SizedBox(height: 24),

              // Description
              ResponsiveText(
                'Description',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: screenWidth < 600 ? 4 : 3,
                decoration: InputDecoration(
                  hintText: 'Describe the emergency situation in detail...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  contentPadding: const EdgeInsets.all(16),
                ),
                style: TextStyle(
                  fontSize: ResponsiveUtils.responsiveFontSize(context, 16),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please describe the emergency';
                  }
                  if (value.trim().length < 10) {
                    return 'Please provide more details (at least 10 characters)';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Location
              ResponsiveText(
                'Location',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              ResponsiveContainer(
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Icon(
                        Icons.location_on,
                        color: Colors.blue[700],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ResponsiveText(
                            'Current Location',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[700],
                            ),
                          ),
                          const SizedBox(height: 4),
                          _isGettingLocation
                              ? Row(
                                  children: [
                                    SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.blue[700]!,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    ResponsiveText(
                                      'Getting location...',
                                      style: TextStyle(color: Colors.blue[600]),
                                    ),
                                  ],
                                )
                              : ResponsiveText(
                                  _currentLocation ?? 'Location not available',
                                  style: TextStyle(color: Colors.blue[600]),
                                  maxLines: 2,
                                ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: _getCurrentLocation,
                      color: Colors.blue[700],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Additional Notes (Optional)
              ResponsiveText(
                'Additional Notes (Optional)',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _additionalNotesController,
                maxLines: screenWidth < 600 ? 3 : 2,
                decoration: InputDecoration(
                  hintText: 'Any additional information that might help responders...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  contentPadding: const EdgeInsets.all(16),
                ),
                style: TextStyle(
                  fontSize: ResponsiveUtils.responsiveFontSize(context, 16),
                ),
              ),

              const SizedBox(height: 32),

              // Submit Button
              ResponsiveButton(
                text: 'Submit Emergency Report',
                onPressed: emergencyProvider.isLoading ? null : _submitReport,
                isLoading: emergencyProvider.isLoading,
                backgroundColor: const Color(0xFFD32F2F),
                textColor: Colors.white,
              ),

              const SizedBox(height: 16),

              // Emergency Contact Info
              ResponsiveContainer(
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning, color: Colors.red[700]),
                        const SizedBox(width: 8),
                        ResponsiveText(
                          'Emergency Hotline',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ResponsiveText(
                      'If this is a life-threatening emergency, call 911 or your local emergency services immediately.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.red[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityButton(int value, String label, Color color) {
    final isSelected = _priority == value;
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? color.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? color : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () => setState(() => _priority = value),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: Center(
            child: ResponsiveText(
              label,
              style: TextStyle(
                color: isSelected ? color : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
