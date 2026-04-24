import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../services/location_service.dart';
import '../services/api_service.dart';
import '../services/models/api_listing.dart';
import '../utils/location_calculator.dart';

class MapViewModel extends ChangeNotifier {
  final LocationService _locationService = LocationService();
  final ApiService _apiService;

  MapViewModel({required ApiService apiService}) : _apiService = apiService;

  Position? _currentPosition;
  List<ApiListing> _allListings = [];
  List<ApiListing> _filteredListings = [];
  ApiListing? _selectedListing;
  bool _isLoading = false;
  String? _errorMessage;
  double _distanceFilter = 1500;
  bool _permissionsGranted = false;

  Position? get currentPosition => _currentPosition;
  List<ApiListing> get filteredListings => _filteredListings;
  ApiListing? get selectedListing => _selectedListing;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  double get distanceFilter => _distanceFilter;
  bool get permissionsGranted => _permissionsGranted;

  static const LatLng defaultCampus = LatLng(4.6016, -74.0665);

  LatLng get campusLocation => defaultCampus;

  LatLng get mapCenter {
    if (_currentPosition != null) {
      return LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
    }
    return defaultCampus;
  }

  Future<void> initialize(String token) async {
    _isLoading = true;
    notifyListeners();

    await _requestPermissions();
    await _getCurrentLocation();
    await loadListings(token);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _requestPermissions() async {
    _permissionsGranted = await _locationService.requestPermissions();
    notifyListeners();
  }

  Future<void> _getCurrentLocation() async {
    final position = await _locationService.getCurrentPosition();
    if (position != null) {
      _currentPosition = position;
      notifyListeners();
    }
  }

  Future<void> loadListings(String token) async {
    try {
      final listings = await _apiService.getListings(token: token); 
      _allListings = listings;
      _applyDistanceFilter();
    } catch (e) {
      _errorMessage = 'Error cargando listings: $e';
      notifyListeners();
    }
  }

  void setDistanceFilter(double meters) {
    _distanceFilter = meters;
    _applyDistanceFilter();
    notifyListeners();
  }

  void _applyDistanceFilter() {
    final reference = _currentPosition != null
        ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
        : defaultCampus;

    _filteredListings = _allListings.where((listing) {
      if (listing.latitude == 0 && listing.longitude == 0) return true;
      final distance = LocationCalculator.calculateDistance(
        reference.latitude,
        reference.longitude,
        listing.latitude,
        listing.longitude,
      );
      return distance <= _distanceFilter;
    }).toList();

    notifyListeners();
  }

  void selectListing(ApiListing? listing) {
    _selectedListing = listing;
    notifyListeners();
  }

  String getWalkingTime(ApiListing listing) {
    final reference = _currentPosition != null
        ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
        : defaultCampus;

    final distance = LocationCalculator.calculateDistance(
      reference.latitude,
      reference.longitude,
      listing.latitude,
      listing.longitude,
    );

    final minutes = (distance / 80).ceil();
    return '${minutes}min walk';
  }

  String getDistance(ApiListing listing) {
    final reference = _currentPosition != null
        ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
        : defaultCampus;

    final distance = LocationCalculator.calculateDistance(
      reference.latitude,
      reference.longitude,
      listing.latitude,
      listing.longitude,
    );

    return LocationCalculator.formatDistance(distance);
  }
}