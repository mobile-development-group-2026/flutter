import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:io';
import '../models/listing.dart';
import '../services/api_service.dart';
import '../services/listing_storage_service.dart';

class ListingViewModel extends ChangeNotifier {
  final ApiService _apiService;
  final ListingStorageService _storageService;

  ListingViewModel({
    required ApiService apiService,
    ListingStorageService? storageService,
  }) : _apiService = apiService,
       _storageService = storageService ?? ListingStorageService();

  final _progressSubject = BehaviorSubject<String>();
  Stream<String> get progressStream => _progressSubject.stream;

  final _photosSubject = BehaviorSubject<List<String>>.seeded([]);
  Stream<List<String>> get photosStream => _photosSubject.stream;

  bool _isLoading = false;
  String? _errorMessage;
  Listing? _currentListing;
  List<Listing> _landlordListings = [];
  XFile? _selectedImage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Listing? get currentListing => _currentListing;
  List<Listing> get landlordListings => _landlordListings;
  XFile? get selectedImage => _selectedImage;

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

  Future<void> pickImageFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );

      if (image != null) {
        _selectedImage = image;
        addPhoto(image.path);
      }
    } catch (e) {
      _errorMessage = 'Error selecting image: $e';
      notifyListeners();
    }
  }

  Future<void> takePhotoWithCamera() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );

      if (image != null) {
        _selectedImage = image;
        addPhoto(image.path);
      }
    } catch (e) {
      _errorMessage = 'Error taking photo: $e';
      notifyListeners();
    }
  }

  void showImageSourceOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library, color: Color(0xFF7B5BF2)),
                title: const Text('Choose from gallery'),
                onTap: () {
                  Navigator.pop(context);
                  pickImageFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFF7B5BF2)),
                title: const Text('Take photo'),
                onTap: () {
                  Navigator.pop(context);
                  takePhotoWithCamera();
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel, color: Colors.red),
                title: const Text('Cancel'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  void addPhoto(String photoPath) {
    _photos.add(photoPath);
    _photosSubject.add(_photos);
    _coverPhoto ??= photoPath;
    notifyListeners();
  }

  void removePhoto(String photoPath) {
    _photos.remove(photoPath);
    _photosSubject.add(_photos);
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
    _selectedImage = null;
    _photosSubject.add([]);
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

  int _getBedroomsFromType(String type) {
    if (type.contains('Studio')) return 0;
    if (type.contains('1 bedroom')) return 1;
    if (type.contains('2 bedrooms')) return 2;
    if (type.contains('3+ bedrooms')) return 3;
    return 1;
  }

  bool _getPetsAllowed() {
    return !_selectedHouseRules.contains('No pets');
  }

  bool _getPartiesAllowed() {
    return !_selectedHouseRules.contains('No parties');
  }

  bool _getSmokingAllowed() {
    return !_selectedHouseRules.contains('No smoking');
  }

  Future<void> loadCachedListings() async {
    final cached = await _storageService.getCachedListings();
    if (cached.isNotEmpty) {
      _landlordListings = cached;
      notifyListeners();
    }
  }

  Future<Listing?> submitListing() async {
    if (!validateForm()) {
      _errorMessage = 'Please fill in all required fields';
      notifyListeners();
      return null;
    }

    _isLoading = true;
    _errorMessage = null;
    _progressSubject.add('Validating listing data...');
    notifyListeners();

    try {
      final listing = Listing(
        id: 0,
        title: titleController.text,
        listingType: 'property',
        description: descriptionController.text,
        propertyType: _selectedPropertyType.toLowerCase().replaceAll(' ', '_'),
        address: '123 University Ave',
        city: 'Cambridge',
        state: 'MA',
        zipCode: '02139',
        latitude: 42.3736,
        longitude: -71.1097,
        rent: double.parse(rentController.text),
        securityDeposit: double.parse(depositController.text),
        utilitiesIncluded: false,
        utilitiesCost: null,
        availableDate: _moveInDate!,
        leaseTermMonths: int.parse(leaseLengthController.text.split(' ')[0]),
        bedrooms: _getBedroomsFromType(_selectedPropertyType),
        bathrooms: 1,
        petsAllowed: _getPetsAllowed(),
        partiesAllowed: _getPartiesAllowed(),
        smokingAllowed: _getSmokingAllowed(),
        userId: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      _progressSubject.add('Sending to server...');
      final result = await _apiService.createListing(listing);
      
      _progressSubject.add('Uploading photos...');
      for (String photoPath in _photos) {
        if (photoPath.startsWith('/') || photoPath.startsWith('C:')) {
          await _apiService.uploadListingPhoto(result.id.toString(), photoPath);
        }
      }
      
      _progressSubject.add('Saving to local cache...');
      await _storageService.saveSingleListing(result);
      
      final updatedListings = List<Listing>.from(_landlordListings)..add(result);
      await _storageService.saveListings(updatedListings);
      
      _currentListing = result;
      _landlordListings = updatedListings;
      _isLoading = false;
      _progressSubject.add('Listing published!');
      
      await Future.delayed(const Duration(milliseconds: 500));
      _progressSubject.add('');
      
      notifyListeners();
      return _currentListing;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      _progressSubject.add('Error: ${e.toString()}');
      notifyListeners();
      return null;
    }
  }

  Future<void> loadLandlordListings() async {
    _isLoading = true;
    notifyListeners();

    try {
      final listings = await _apiService.getListings();
      _landlordListings = listings.where((l) => l.userId == 1).toList();
      await _storageService.saveListings(_landlordListings);
      _errorMessage = null;
    } catch (e) {
      final cached = await _storageService.getCachedListings();
      if (cached.isNotEmpty) {
        _landlordListings = cached;
      } else {
        _errorMessage = e.toString();
      }
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
      _currentListing = listing;
      await _storageService.saveSingleListing(listing);
      _errorMessage = null;
    } catch (e) {
      final cached = await _storageService.getSingleListing(id);
      if (cached != null) {
        _currentListing = cached;
      } else {
        _errorMessage = e.toString();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateListing(Listing listing) async {
    _isLoading = true;
    notifyListeners();

    try {
      final updated = await _apiService.updateListing(listing);
      _currentListing = updated;
      await _storageService.saveSingleListing(updated);
      
      final index = _landlordListings.indexWhere((l) => l.id == listing.id);
      if (index != -1) {
        _landlordListings[index] = _currentListing!;
        await _storageService.saveListings(_landlordListings);
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
      await _storageService.deleteListing(id);
      _landlordListings.removeWhere((l) => l.id.toString() == id);
      if (_currentListing?.id.toString() == id) {
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
    _progressSubject.close();
    _photosSubject.close();
    super.dispose();
  }
}