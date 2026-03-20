import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
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
    _selectedImage = null;
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

  Future<Listing?> submitListing() async {
    if (!validateForm()) {
      _errorMessage = 'Please fill in all required fields';
      notifyListeners();
      return null;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final apiListing = ApiListing(
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
        availableDate: _moveInDate!.toIso8601String().split('T').first,
        leaseTermMonths: int.parse(leaseLengthController.text.split(' ')[0]),
        bedrooms: _getBedroomsFromType(_selectedPropertyType),
        bathrooms: 1,
        petsAllowed: _getPetsAllowed(),
        partiesAllowed: _getPartiesAllowed(),
        smokingAllowed: _getSmokingAllowed(),
        userId: 1,
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );

      final result = await _apiService.createListing(apiListing);
      
      _currentListing = Listing(
        id: result.id,
        title: result.title,
        listingType: result.listingType,
        description: result.description,
        propertyType: result.propertyType,
        address: result.address,
        city: result.city,
        state: result.state,
        zipCode: result.zipCode,
        latitude: result.latitude,
        longitude: result.longitude,
        rent: result.rent,
        securityDeposit: result.securityDeposit,
        utilitiesIncluded: result.utilitiesIncluded,
        utilitiesCost: result.utilitiesCost,
        availableDate: DateTime.parse(result.availableDate),
        leaseTermMonths: result.leaseTermMonths,
        bedrooms: result.bedrooms,
        bathrooms: result.bathrooms,
        petsAllowed: result.petsAllowed,
        partiesAllowed: result.partiesAllowed,
        smokingAllowed: result.smokingAllowed,
        userId: result.userId,
        createdAt: DateTime.parse(result.createdAt),
        updatedAt: DateTime.parse(result.updatedAt),
      );
      
      for (String photoPath in _photos) {
        if (photoPath.startsWith('/') || photoPath.startsWith('C:')) {
          await _apiService.uploadListingPhoto(result.id.toString(), photoPath);
        }
      }
      
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

  Future<void> loadLandlordListings() async {
    _isLoading = true;
    notifyListeners();

    try {
      final listings = await _apiService.getListings();
      _landlordListings = listings.map((apiListing) => Listing(
        id: apiListing.id,
        title: apiListing.title,
        listingType: apiListing.listingType,
        description: apiListing.description,
        propertyType: apiListing.propertyType,
        address: apiListing.address,
        city: apiListing.city,
        state: apiListing.state,
        zipCode: apiListing.zipCode,
        latitude: apiListing.latitude,
        longitude: apiListing.longitude,
        rent: apiListing.rent,
        securityDeposit: apiListing.securityDeposit,
        utilitiesIncluded: apiListing.utilitiesIncluded,
        utilitiesCost: apiListing.utilitiesCost,
        availableDate: DateTime.parse(apiListing.availableDate),
        leaseTermMonths: apiListing.leaseTermMonths,
        bedrooms: apiListing.bedrooms,
        bathrooms: apiListing.bathrooms,
        petsAllowed: apiListing.petsAllowed,
        partiesAllowed: apiListing.partiesAllowed,
        smokingAllowed: apiListing.smokingAllowed,
        userId: apiListing.userId,
        createdAt: DateTime.parse(apiListing.createdAt),
        updatedAt: DateTime.parse(apiListing.updatedAt),
      )).where((l) => l.userId == 1).toList();
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
      final apiListing = await _apiService.getListing(id);
      _currentListing = Listing(
        id: apiListing.id,
        title: apiListing.title,
        listingType: apiListing.listingType,
        description: apiListing.description,
        propertyType: apiListing.propertyType,
        address: apiListing.address,
        city: apiListing.city,
        state: apiListing.state,
        zipCode: apiListing.zipCode,
        latitude: apiListing.latitude,
        longitude: apiListing.longitude,
        rent: apiListing.rent,
        securityDeposit: apiListing.securityDeposit,
        utilitiesIncluded: apiListing.utilitiesIncluded,
        utilitiesCost: apiListing.utilitiesCost,
        availableDate: DateTime.parse(apiListing.availableDate),
        leaseTermMonths: apiListing.leaseTermMonths,
        bedrooms: apiListing.bedrooms,
        bathrooms: apiListing.bathrooms,
        petsAllowed: apiListing.petsAllowed,
        partiesAllowed: apiListing.partiesAllowed,
        smokingAllowed: apiListing.smokingAllowed,
        userId: apiListing.userId,
        createdAt: DateTime.parse(apiListing.createdAt),
        updatedAt: DateTime.parse(apiListing.updatedAt),
      );
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
      final apiListing = ApiListing(
        id: listing.id,
        title: listing.title,
        listingType: listing.listingType,
        description: listing.description,
        propertyType: listing.propertyType,
        address: listing.address,
        city: listing.city,
        state: listing.state,
        zipCode: listing.zipCode,
        latitude: listing.latitude,
        longitude: listing.longitude,
        rent: listing.rent,
        securityDeposit: listing.securityDeposit,
        utilitiesIncluded: listing.utilitiesIncluded,
        utilitiesCost: listing.utilitiesCost,
        availableDate: listing.availableDate.toIso8601String().split('T').first,
        leaseTermMonths: listing.leaseTermMonths,
        bedrooms: listing.bedrooms,
        bathrooms: listing.bathrooms,
        petsAllowed: listing.petsAllowed,
        partiesAllowed: listing.partiesAllowed,
        smokingAllowed: listing.smokingAllowed,
        userId: listing.userId,
        createdAt: listing.createdAt.toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );

      final updated = await _apiService.updateListing(apiListing);
      
      _currentListing = Listing(
        id: updated.id,
        title: updated.title,
        listingType: updated.listingType,
        description: updated.description,
        propertyType: updated.propertyType,
        address: updated.address,
        city: updated.city,
        state: updated.state,
        zipCode: updated.zipCode,
        latitude: updated.latitude,
        longitude: updated.longitude,
        rent: updated.rent,
        securityDeposit: updated.securityDeposit,
        utilitiesIncluded: updated.utilitiesIncluded,
        utilitiesCost: updated.utilitiesCost,
        availableDate: DateTime.parse(updated.availableDate),
        leaseTermMonths: updated.leaseTermMonths,
        bedrooms: updated.bedrooms,
        bathrooms: updated.bathrooms,
        petsAllowed: updated.petsAllowed,
        partiesAllowed: updated.partiesAllowed,
        smokingAllowed: updated.smokingAllowed,
        userId: updated.userId,
        createdAt: DateTime.parse(updated.createdAt),
        updatedAt: DateTime.parse(updated.updatedAt),
      );
      
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
    super.dispose();
  }
}