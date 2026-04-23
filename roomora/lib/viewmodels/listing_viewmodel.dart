import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rxdart/rxdart.dart';
import '../models/listing.dart';
import '../services/api_service.dart';
import '../services/listing_storage_service.dart';
import '../services/models/api_listing.dart';

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

  final Map<String, String> _fieldErrors = {};
  Map<String, String> get fieldErrors => _fieldErrors;

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

  final List<String> _reservedSqlKeywords = [
    'SELECT', 'INSERT', 'UPDATE', 'DELETE', 'DROP', 'CREATE', 'ALTER',
    'UNION', 'JOIN', 'WHERE', 'FROM', 'TABLE', 'DATABASE'
  ];

  final List<String> _dangerousCharacters = [
    '\'', '"', ';', '--', '/*', '*/'
  ];

  String? _validateTitle(String value) {
    if (value.isEmpty) return 'Title is required';
    if (value.length < 5) return 'Title must be at least 5 characters';
    if (value.length > 100) return 'Title cannot exceed 100 characters';
    return _checkForSqlInjection(value, 'Title');
  }

  String? _validateDescription(String value) {
    if (value.isEmpty) return 'Description is required';
    if (value.length < 20) return 'Description must be at least 20 characters';
    if (value.length > 2000) return 'Description cannot exceed 2000 characters';
    return _checkForSqlInjection(value, 'Description');
  }

  String? _validateRent(String value) {
    if (value.isEmpty) return 'Monthly rent is required';
    final rent = double.tryParse(value);
    if (rent == null) return 'Enter a valid number';
    if (rent < 100) return 'Rent must be at least \$100';
    if (rent > 10000) return 'Rent cannot exceed \$10,000';
    return null;
  }

  String? _validateDeposit(String value) {
    if (value.isEmpty) return 'Security deposit is required';
    final deposit = double.tryParse(value);
    if (deposit == null) return 'Enter a valid number';
    if (deposit < 0) return 'Deposit cannot be negative';
    if (deposit > 5000) return 'Deposit cannot exceed \$5,000';
    return null;
  }

  String? _validateLeaseLength(String value) {
    if (value.isEmpty) return 'Lease length is required';
    final RegExp leaseRegex = RegExp(r'^(\d+)\s*(months?|month|meses?|mes)$', caseSensitive: false);
    if (!leaseRegex.hasMatch(value)) return 'Enter valid format (e.g., "12 months")';
    final int months = int.tryParse(value.split(' ')[0]) ?? 0;
    if (months < 1) return 'Lease must be at least 1 month';
    if (months > 60) return 'Lease cannot exceed 60 months';
    return _checkForSqlInjection(value, 'Lease length');
  }

  String? _validateMoveInDate() {
    if (_moveInDate == null) return 'Move-in date is required';
    if (_moveInDate!.isBefore(DateTime.now())) return 'Move-in date cannot be in the past';
    if (_moveInDate!.isAfter(DateTime.now().add(const Duration(days: 365)))) {
      return 'Move-in date cannot be more than 1 year from now';
    }
    return null;
  }

  String? _validatePhotos() {
    if (_photos.isEmpty) return 'At least one photo is required';
    return null;
  }

  String? _validatePropertyType() {
    if (!propertyTypes.contains(_selectedPropertyType)) return 'Select a valid property type';
    return null;
  }

  String? _validateAmenities() {
    if (_selectedAmenities.isEmpty) return 'Select at least one amenity';
    return null;
  }

  String? _validateHouseRules() {
    if (_selectedHouseRules.isEmpty) return 'Select at least one house rule';
    return null;
  }

  String? _checkForSqlInjection(String value, String fieldName) {
    final upperValue = value.toUpperCase();
    
    for (final keyword in _reservedSqlKeywords) {
      final pattern = RegExp('\\b$keyword\\b', caseSensitive: false);
      if (pattern.hasMatch(upperValue)) {
        return '$fieldName contains invalid characters';
      }
    }
    
    for (final char in _dangerousCharacters) {
      if (value.contains(char)) {
        return '$fieldName contains invalid characters';
      }
    }
    
    if (value.contains('<script') || value.contains('</script>')) {
      return '$fieldName contains invalid script tags';
    }
    
    return null;
  }

  void validateField(String field, String value) {
    String? error;
    switch (field) {
      case 'title':
        error = _validateTitle(value);
        break;
      case 'description':
        error = _validateDescription(value);
        break;
      case 'rent':
        error = _validateRent(value);
        break;
      case 'deposit':
        error = _validateDeposit(value);
        break;
      case 'leaseLength':
        error = _validateLeaseLength(value);
        break;
      case 'moveInDate':
        error = _validateMoveInDate();
        break;
      case 'photos':
        error = _validatePhotos();
        break;
      case 'propertyType':
        error = _validatePropertyType();
        break;
      case 'amenities':
        error = _validateAmenities();
        break;
      case 'houseRules':
        error = _validateHouseRules();
        break;
    }
    if (error != null) {
      _fieldErrors[field] = error;
    } else {
      _fieldErrors.remove(field);
    }
    notifyListeners();
  }

  Map<String, String> validateAllFields() {
    final errors = <String, String>{};
    
    final titleError = _validateTitle(titleController.text);
    if (titleError != null) errors['title'] = titleError;
    
    final descriptionError = _validateDescription(descriptionController.text);
    if (descriptionError != null) errors['description'] = descriptionError;
    
    final rentError = _validateRent(rentController.text);
    if (rentError != null) errors['rent'] = rentError;
    
    final depositError = _validateDeposit(depositController.text);
    if (depositError != null) errors['deposit'] = depositError;
    
    final leaseError = _validateLeaseLength(leaseLengthController.text);
    if (leaseError != null) errors['leaseLength'] = leaseError;
    
    final dateError = _validateMoveInDate();
    if (dateError != null) errors['moveInDate'] = dateError;
    
    final photosError = _validatePhotos();
    if (photosError != null) errors['photos'] = photosError;
    
    final propertyTypeError = _validatePropertyType();
    if (propertyTypeError != null) errors['propertyType'] = propertyTypeError;
    
    final amenitiesError = _validateAmenities();
    if (amenitiesError != null) errors['amenities'] = amenitiesError;
    
    final houseRulesError = _validateHouseRules();
    if (houseRulesError != null) errors['houseRules'] = houseRulesError;
    
    _fieldErrors.addAll(errors);
    notifyListeners();
    return errors;
  }

  bool validateForm() {
    final errors = validateAllFields();
    return errors.isEmpty;
  }

  void showValidationAlert(BuildContext context) {
    final errors = validateAllFields();
    if (errors.isNotEmpty) {
      final errorMessages = errors.values.map((e) => '• $e').join('\n');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Please fix the following errors'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Required fields:', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                const Text('• Property title (5-100 characters)'),
                const Text('• Description (20-2000 characters)'),
                const Text('• Monthly rent (min \$100, max \$10,000)'),
                const Text('• Security deposit (max \$5,000)'),
                const Text('• Lease length (1-60 months)'),
                const Text('• Move-in date (within 1 year)'),
                const Text('• At least one photo'),
                const Text('• Property type'),
                const Text('• At least one amenity'),
                const Text('• At least one house rule'),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Errors found:', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.red)),
                      const SizedBox(height: 4),
                      Text(errorMessages, style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(foregroundColor: const Color(0xFF7B5BF2)),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void toggleHouseRule(String rule) {
    if (_selectedHouseRules.contains(rule)) {
      _selectedHouseRules.remove(rule);
    } else {
      _selectedHouseRules.add(rule);
    }
    validateField('houseRules', '');
    notifyListeners();
  }

  void toggleAmenity(String amenity) {
    if (_selectedAmenities.contains(amenity)) {
      _selectedAmenities.remove(amenity);
    } else {
      _selectedAmenities.add(amenity);
    }
    validateField('amenities', '');
    notifyListeners();
  }

  void setPropertyType(String type) {
    _selectedPropertyType = type;
    validateField('propertyType', type);
    notifyListeners();
  }

  void setMoveInDate(DateTime date) {
    _moveInDate = date;
    validateField('moveInDate', '');
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
    validateField('photos', '');
    notifyListeners();
  }

  void removePhoto(String photoPath) {
    _photos.remove(photoPath);
    _photosSubject.add(_photos);
    if (_coverPhoto == photoPath) {
      _coverPhoto = _photos.isNotEmpty ? _photos.first : null;
    }
    validateField('photos', '');
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
    _fieldErrors.clear();
    _photosSubject.add([]);
    notifyListeners();
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
      return null;
    }

    _isLoading = true;
    _errorMessage = null;
    _progressSubject.add('Validating listing data...');
    notifyListeners();

    try {
      final newListing = Listing(
        id: 0,
        title: titleController.text.trim(),
        listingType: 'property',
        description: descriptionController.text.trim(),
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

      final apiListing = ApiListing.fromListing(newListing);

      _progressSubject.add('Sending to server...');
      final result = await _apiService.createListing(apiListing);
      
      _progressSubject.add('Uploading photos...');
      for (String photoPath in _photos) {
        if (photoPath.startsWith('/') || photoPath.startsWith('C:')) {
          await _apiService.uploadListingPhoto(result.id.toString(), photoPath);
        }
      }
      
      _progressSubject.add('Saving to local cache...');
      await _storageService.saveSingleListing(result.toListing());
      
      final updatedListings = List<Listing>.from(_landlordListings)..add(result.toListing());
      await _storageService.saveListings(updatedListings);
      
      _currentListing = result.toListing();
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
      _landlordListings = listings.map((api) => api.toListing()).toList();
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
      final apiListing = await _apiService.getListing(id);
      _currentListing = apiListing.toListing();
      await _storageService.saveSingleListing(_currentListing!);
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
      final apiListing = ApiListing.fromListing(listing);
      final updated = await _apiService.updateListing(apiListing);
      _currentListing = updated.toListing();
      await _storageService.saveSingleListing(_currentListing!);
      
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

  Future<bool> deleteListing(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.deleteListing(id.toString());
      await _storageService.deleteListing(id);
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
    _progressSubject.close();
    _photosSubject.close();
    super.dispose();
  }
}