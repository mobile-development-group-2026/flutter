import 'package:flutter/material.dart';
import '../models/listing.dart';
import '../models/landlord_profile.dart';
import '../services/api_service.dart';

class PropertyDetailViewModel extends ChangeNotifier {
  final ApiService _apiService;

  PropertyDetailViewModel({required ApiService apiService})
      : _apiService = apiService;

  Listing? _listing;
  LandlordProfile? _landlordProfile;
  bool _isLoading = false;
  bool _isLoadingProfile = false;
  String? _errorMessage;
  bool _isSaved = false;

  Listing? get listing => _listing;
  LandlordProfile? get landlordProfile => _landlordProfile;
  bool get isLoading => _isLoading;
  bool get isLoadingProfile => _isLoadingProfile;
  String? get errorMessage => _errorMessage;
  bool get isSaved => _isSaved;

  Future<void> fetchListingDetail({
    required String listingId,
    required String token,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final apiListing = await _apiService.getListing(listingId, token: token);
      _listing = apiListing.toListing();
      _fetchLandlordProfile(token: token);
    } catch (e) {
      _errorMessage = 'No se pudo cargar el listing: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchLandlordProfile({required String token}) async {
    _isLoadingProfile = true;
    notifyListeners();

    try {
      final profile = await _apiService.fetchProfile(token: token);
      _landlordProfile = profile;
    } catch (e) {
      _landlordProfile = null;
    } finally {
      _isLoadingProfile = false;
      notifyListeners();
    }
  }

  void initWithListing(Listing listing, String token) {
    _listing = listing;
    notifyListeners();
    _fetchLandlordProfile(token: token);
  }

  void toggleSaved() {
    _isSaved = !_isSaved;
    notifyListeners();
  }
}