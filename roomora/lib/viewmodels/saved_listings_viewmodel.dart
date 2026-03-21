import 'package:flutter/material.dart';
import '../models/saved_listing.dart';
import '../services/saved_listings_service.dart';

class SavedListingsViewModel extends ChangeNotifier {
  final SavedListingsService _savedListingsService = SavedListingsService();
  
  String _studentId = 'dev_student_1';
  List<SavedListing> _savedListings = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<SavedListing> get savedListings => _savedListings;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadSavedListings() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _savedListings = await _savedListingsService.getSavedListings(_studentId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsVisited(String listingId) async {
    try {
      SavedListing updated = await _savedListingsService.markListingAsVisited(_studentId, listingId);
      
      int index = _savedListings.indexWhere((l) => l.listingId == listingId);
      if (index != -1) {
        _savedListings[index] = updated;
      }
      
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateNotificationDistance(String listingId, double distance) async {
    try {
      await _savedListingsService.updateNotificationDistance(_studentId, listingId, distance);
      
      int index = _savedListings.indexWhere((l) => l.listingId == listingId);
      if (index != -1) {
        _savedListings[index] = _savedListings[index].copyWith(distance: distance);
      }
      
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  List<SavedListing> get unvisitedListings {
    return _savedListings.where((l) => !l.visited).toList();
  }

  List<SavedListing> get visitedListings {
    return _savedListings.where((l) => l.visited).toList();
  }
}