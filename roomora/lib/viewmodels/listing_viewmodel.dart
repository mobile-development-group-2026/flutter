import 'package:flutter/material.dart';
import '../models/listing.dart';
import '../services/api_service.dart';
import '../services/models/api_listing.dart';

class ListingViewModel extends ChangeNotifier {
  final ApiService _apiService;

  ListingViewModel({required ApiService apiService}) : _apiService = apiService;

  bool _isLoading = false;
  String? _errorMessage;
  Listing? _currentListing;
  List<Listing> _landlordListings = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Listing? get currentListing => _currentListing;
  List<Listing> get landlordListings => _landlordListings;

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final rentController = TextEditingController();
  final depositController = TextEditingController();
  final leaseLengthController = TextEditingController();
  
  DateTime? _moveInDate;
  List<String> _selectedHouseRules = [];
  List<String> _selectedAmenities = [];
  String _selectedPropertyType = 'Studio';
  List<String> _photos = [];
  String? _coverPhoto;

  DateTime? get moveInDate => _moveInDate;
  List<String> get selectedHouseRules => List.unmodifiable(_selectedHouseRules);
  List<String> get selectedAmenities => List.unmodifiable(_selectedAmenities);
  String get selectedPropertyType => _selectedPropertyType;
  List<String> get photos => List.unmodifiable(_photos);
  String? get coverPhoto => _coverPhoto;

  final List<String> propertyTypes = const [
    'Shared room',
    'Studio',
    '1 bedroom',
    '2 bedrooms',
    '3+ bedrooms'
  ];

  final List<String> amenitiesList = const [
    'WiFi',
    'Laundry',
    'Parking',
    'AC',
    'Gym',
    'Pool',
    'Balcony',
    'Furnished'
  ];

  final List<String> houseRulesList = const [
    'No smoking',
    'No parties',
    'No pets',
    'No overnight guests',
    'Quiet after 10 pm',
    'Students only'
  ];

  void toggleHouseRule(String rule) {
    if (_selectedHouseRules.contains(rule)) {
      _selectedHouseRules.remove(rule);
    } else {
      _selectedHouseRules.add(rule);
    }
    notifyListeners();
  }

  void toggleAmenity(String amenity) {
    if (_selectedAmenities.contains(amenity)) {
      _selectedAmenities.remove(amenity);
    } else {
      _selectedAmenities.add(amenity);
    }
    notifyListeners();
  }

  void setPropertyType(String type) {
    _selectedPropertyType = type;
    notifyListeners();
  }

  void setMoveInDate(DateTime date) {
    _moveInDate = date;
    notifyListeners();
  }

  void addPhoto(String photoPath) {
    _photos.add(photoPath);
    _coverPhoto ??= photoPath;
    notifyListeners();
  }

  void removePhoto(String photoPath) {
    _photos.remove(photoPath);
    if (_coverPhoto == photoPath) {
      _coverPhoto = _photos.isNotEmpty ? _photos.first : null;
    }
    notifyListeners();
  }

  void setCoverPhoto(String photoPath) {
    _coverPhoto = photoPath;
    notifyListeners();
  }

  void clearForm() {
    titleController.clear();
    descriptionController.clear();
    rentController.clear();
    depositController.clear();
    leaseLengthController.clear();
    _moveInDate = null;
    _selectedHouseRules = [];
    _selectedAmenities = [];
    _selectedPropertyType = 'Studio';
    _photos = [];
    _coverPhoto = null;
    notifyListeners();
  }

  bool validateForm() {
    return titleController.text.isNotEmpty &&
        descriptionController.text.isNotEmpty &&
        rentController.text.isNotEmpty &&
        depositController.text.isNotEmpty &&
        leaseLengthController.text.isNotEmpty &&
        _moveInDate != null &&
        _selectedHouseRules.isNotEmpty &&
        _photos.isNotEmpty;
  }

  Future<Listing?> submitListing(String landlordId) async {
    if (!validateForm()) {
      _errorMessage = 'Please fill in all required fields';
      notifyListeners();
      return null;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final listing = Listing(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: titleController.text,
        description: descriptionController.text,
        rent: double.parse(rentController.text),
        deposit: double.parse(depositController.text),
        leaseLength: leaseLengthController.text,
        moveInDate: _moveInDate!,
        houseRules: _selectedHouseRules,
        amenities: _selectedAmenities,
        propertyType: _selectedPropertyType,
        photos: _photos,
        coverPhoto: _coverPhoto ?? (_photos.isNotEmpty ? _photos.first : ''),
        landlordId: landlordId,
        isPublished: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final apiListing = ApiListing.fromListing(listing);
      final result = await _apiService.createListing(apiListing);
      _currentListing = result.toListing();
      
      _isLoading = false;
      notifyListeners();
      return _currentListing;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<void> loadLandlordListings(String landlordId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final listings = await _apiService.getLandlordListings(landlordId);
      _landlordListings = listings.map((api) => api.toListing()).toList();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadListing(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      final listing = await _apiService.getListing(id);
      _currentListing = listing.toListing();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateListing(Listing listing) async {
    _isLoading = true;
    notifyListeners();

    try {
      final apiListing = ApiListing.fromListing(listing);
      final updated = await _apiService.updateListing(apiListing);
      _currentListing = updated.toListing();
      
      final index = _landlordListings.indexWhere((l) => l.id == listing.id);
      if (index != -1) {
        _landlordListings[index] = _currentListing!;
      }
      
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteListing(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.deleteListing(id);
      _landlordListings.removeWhere((l) => l.id == id);
      if (_currentListing?.id == id) {
        _currentListing = null;
      }
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    rentController.dispose();
    depositController.dispose();
    leaseLengthController.dispose();
    super.dispose();
  }
}