import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import '../services/location_service.dart';
import '../services/notification_service.dart';
import '../services/saved_listings_service.dart';
import '../models/saved_listing.dart';
import '../models/location_alert.dart';
import '../utils/location_calculator.dart';

class GPSViewModel extends ChangeNotifier {
  final LocationService _locationService = LocationService();
  final NotificationService _notificationService = NotificationService();
  final SavedListingsService _savedListingsService = SavedListingsService();
  
  String _studentId = 'dev_student_1';
  List<SavedListing> _savedListings = [];
  List<LocationAlert> _alerts = [];
  Position? _currentPosition;
  bool _isListening = false;
  String? _errorMessage;
  bool _permissionsGranted = false;

  List<SavedListing> get savedListings => _savedListings;
  List<LocationAlert> get alerts => _alerts;
  Position? get currentPosition => _currentPosition;
  bool get isListening => _isListening;
  String? get errorMessage => _errorMessage;
  bool get permissionsGranted => _permissionsGranted;

  GPSViewModel() {
    _initialize();
  }

  Future<void> _initialize() async {
    await _notificationService.initialize();
    _permissionsGranted = await _locationService.checkPermissions();
    notifyListeners();
  }

  Future<bool> requestPermissions() async {
    _permissionsGranted = await _locationService.requestPermissions();
    await _notificationService.requestPermissions();
    notifyListeners();
    return _permissionsGranted;
  }

  Future<void> loadSavedListings() async {
    try {
      _savedListings = await _savedListingsService.getSavedListings(_studentId);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void startLocationMonitoring() {
    if (!_permissionsGranted) {
      _errorMessage = 'Permisos de ubicación no concedidos';
      notifyListeners();
      return;
    }

    _isListening = true;
    _locationService.startListening(_onPositionChanged);
    notifyListeners();
  }

  void stopLocationMonitoring() {
    _isListening = false;
    _locationService.stopListening();
    notifyListeners();
  }

  void _onPositionChanged(Position position) {
    _currentPosition = position;
    
    for (var listing in _savedListings) {
      if (listing.visited) continue;

      double distance = LocationCalculator.calculateDistance(
        position.latitude,
        position.longitude,
        listing.latitude,
        listing.longitude,
      );

      if (distance <= listing.distance) {
        _triggerAlert(listing, distance);
      }
    }
    
    notifyListeners();
  }

  Future<void> _triggerAlert(SavedListing listing, double distance) async {
    bool alreadyAlerted = _alerts.any(
      (a) => a.listingId == listing.listingId && 
             DateTime.now().difference(a.timestamp).inMinutes < 30
    );

    if (alreadyAlerted) return;

    String distanceFormatted = LocationCalculator.formatDistance(distance);
    String message = 'Estás a $distanceFormatted de "${listing.title}". ¿Quieres visitarlo?';

    LocationAlert alert = LocationAlert(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      listingId: listing.listingId,
      listingTitle: listing.title,
      message: message,
      timestamp: DateTime.now(),
      read: false,
      distance: distance,
      address: listing.address,
    );

    _alerts.insert(0, alert);
    
    await _notificationService.showLocationAlert(
      title: 'Listing cercano',
      body: message,
      payload: listing.listingId,
    );

    notifyListeners();
  }

  void markAlertAsRead(String alertId) {
    int index = _alerts.indexWhere((a) => a.id == alertId);
    if (index != -1) {
      _alerts[index] = _alerts[index].markAsRead();
      notifyListeners();
    }
  }

  Future<void> markListingAsVisited(String listingId) async {
    try {
      await _savedListingsService.markListingAsVisited(_studentId, listingId);
      
      int index = _savedListings.indexWhere((l) => l.listingId == listingId);
      if (index != -1) {
        _savedListings[index] = _savedListings[index].copyWith(
          visited: true,
          visitedAt: DateTime.now(),
        );
      }
      
      _alerts.removeWhere((a) => a.listingId == listingId);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void clearOldAlerts() {
    DateTime cutoff = DateTime.now().subtract(const Duration(days: 1));
    _alerts.removeWhere((a) => a.timestamp.isBefore(cutoff));
    notifyListeners();
  }

  @override
  void dispose() {
    stopLocationMonitoring();
    super.dispose();
  }
}