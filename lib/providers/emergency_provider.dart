import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/emergency_report_model.dart';
import '../services/firebase_service.dart';
import '../services/location_service.dart';
import '../providers/location_provider.dart';
import 'package:uuid/uuid.dart';

class EmergencyProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  final LocationService _locationService = LocationService();

  List<EmergencyReport> _userReports = [];
  List<EmergencyReport> _activeReports = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<EmergencyReport> get userReports => _userReports;
  List<EmergencyReport> get activeReports => _activeReports;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Submit emergency report
  Future<bool> submitEmergencyReport({
    required EmergencyType type,
    required String description,
    String? additionalNotes,
    int? priority,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Get current location
      final position = await _locationService.getCurrentLocation();

      // Get address from coordinates
      final address = await _locationService.getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );

      // Get current user
      final currentUser = _firebaseService.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Get user name from Firestore
      final userDoc = await _firebaseService.usersCollection.doc(currentUser.uid).get();
      final userName = userDoc.exists ? userDoc.get('name') ?? 'Unknown User' : 'Unknown User';

      // Create emergency report
      final report = EmergencyReport(
        id: '', // Will be set by Firestore
        userId: currentUser.uid,
        userName: userName,
        type: type,
        description: description,
        location: address,
        latitude: position.latitude,
        longitude: position.longitude,
        status: EmergencyStatus.reported,
        createdAt: DateTime.now(),
        additionalNotes: additionalNotes,
        priority: priority ?? 2,
      );

      // Save to Firestore
      final docRef = await _firebaseService.reportsCollection.add(report.toFirestore());

      // Update report with generated ID
      final reportWithId = report.copyWith(id: docRef.id);
      await docRef.update({'id': docRef.id});

      // Add to local list
      _userReports.insert(0, reportWithId);

      // Start location tracking for this emergency (if provider is available)
      try {
        // Note: LocationProvider would be accessed through a callback or service locator
        // For now, we'll just mark that location tracking should be started
        print('Emergency reported: ${docRef.id} - Location tracking should be started');
      } catch (e) {
        print('Could not start location tracking: $e');
      }

      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to submit report: $e';
      notifyListeners();
      return false;
    }
  }

  // Load user's emergency reports
  Future<void> loadUserReports() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final currentUser = _firebaseService.currentUser;
      if (currentUser == null) return;

      final querySnapshot = await _firebaseService.reportsCollection
          .where('userId', isEqualTo: currentUser.uid)
          .orderBy('createdAt', descending: true)
          .get();

      _userReports = querySnapshot.docs
          .map((doc) => EmergencyReport.fromFirestore(doc))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load reports: $e';
      notifyListeners();
    }
  }

  // Load active emergency reports (for admin)
  Future<void> loadActiveReports() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final querySnapshot = await _firebaseService.reportsCollection
          .where('status', whereIn: [
            EmergencyStatus.reported.index,
            EmergencyStatus.acknowledged.index,
            EmergencyStatus.responding.index,
          ])
          .orderBy('createdAt', descending: true)
          .get();

      _activeReports = querySnapshot.docs
          .map((doc) => EmergencyReport.fromFirestore(doc))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load active reports: $e';
      notifyListeners();
    }
  }

  // Update report status (for admin)
  Future<bool> updateReportStatus(String reportId, EmergencyStatus newStatus) async {
    try {
      await _firebaseService.reportsCollection.doc(reportId).update({
        'status': newStatus.index,
        'updatedAt': Timestamp.now(),
      });

      // Update local lists
      final userReportIndex = _userReports.indexWhere((r) => r.id == reportId);
      if (userReportIndex != -1) {
        _userReports[userReportIndex] = _userReports[userReportIndex].copyWith(
          status: newStatus,
          updatedAt: DateTime.now(),
        );
      }

      final activeReportIndex = _activeReports.indexWhere((r) => r.id == reportId);
      if (activeReportIndex != -1) {
        _activeReports[activeReportIndex] = _activeReports[activeReportIndex].copyWith(
          status: newStatus,
          updatedAt: DateTime.now(),
        );
      }

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update report status: $e';
      notifyListeners();
      return false;
    }
  }

  // Assign unit to report (for admin)
  Future<bool> assignUnitToReport(String reportId, String unitId, String unitName) async {
    try {
      await _firebaseService.reportsCollection.doc(reportId).update({
        'assignedUnitId': unitId,
        'assignedUnitName': unitName,
        'status': EmergencyStatus.acknowledged.index,
        'updatedAt': Timestamp.now(),
      });

      // Update local lists
      final userReportIndex = _userReports.indexWhere((r) => r.id == reportId);
      if (userReportIndex != -1) {
        _userReports[userReportIndex] = _userReports[userReportIndex].copyWith(
          assignedUnitId: unitId,
          assignedUnitName: unitName,
          status: EmergencyStatus.acknowledged,
          updatedAt: DateTime.now(),
        );
      }

      final activeReportIndex = _activeReports.indexWhere((r) => r.id == reportId);
      if (activeReportIndex != -1) {
        _activeReports[activeReportIndex] = _activeReports[activeReportIndex].copyWith(
          assignedUnitId: unitId,
          assignedUnitName: unitName,
          status: EmergencyStatus.acknowledged,
          updatedAt: DateTime.now(),
        );
      }

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to assign unit: $e';
      notifyListeners();
      return false;
    }
  }

  // Get reports by status
  List<EmergencyReport> getReportsByStatus(EmergencyStatus status) {
    return _userReports.where((report) => report.status == status).toList();
  }

  // Get active reports count
  int get activeReportsCount => _activeReports.length;

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Listen to real-time updates for user's reports
  void startListeningToUserReports() {
    final currentUser = _firebaseService.currentUser;
    if (currentUser == null) return;

    _firebaseService.reportsCollection
        .where('userId', isEqualTo: currentUser.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      _userReports = snapshot.docs
          .map((doc) => EmergencyReport.fromFirestore(doc))
          .toList();
      notifyListeners();
    });
  }

  // Listen to real-time updates for active reports (admin)
  void startListeningToActiveReports() {
    _firebaseService.reportsCollection
        .where('status', whereIn: [
          EmergencyStatus.reported.index,
          EmergencyStatus.acknowledged.index,
          EmergencyStatus.responding.index,
        ])
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      _activeReports = snapshot.docs
          .map((doc) => EmergencyReport.fromFirestore(doc))
          .toList();
      notifyListeners();
    });
  }
}
