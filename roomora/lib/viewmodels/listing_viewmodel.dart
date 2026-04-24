import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rxdart/rxdart.dart';
import '../models/listing.dart';
import '../services/api_service.dart';
import '../services/listing_storage_service.dart';
import '../services/models/api_listing.dart';
import '../services/offline_queue_service.dart';
import '../services/connectivity_service.dart';
import 'dart:io';

class ListingViewModel extends ChangeNotifier {
  final ApiService _apiService;
  final ListingStorageService _storageService;
  final OfflineQueueService _offlineQueue;
  final ConnectivityService _connectivity;

  ListingViewModel({
    required ApiService apiService,
    ListingStorageService? storageService,
  }) : _apiService = apiService,
       _storageService = storageService ?? ListingStorageService(),
       _offlineQueue = OfflineQueueService(),
       _connectivity = ConnectivityService() {
    _loadDraft();
    _setupAutoSave();
    _setupConnectivityListener();
    _syncPendingTasksOnStart();
  }

  final _progressSubject = BehaviorSubject<String>();
  Stream<String> get progressStream => _progressSubject.stream;

  final _photosSubject = BehaviorSubject<List<String>>.seeded([]);
  Stream<List<String>> get photosStream => _photosSubject.stream;

  bool _isLoading = false;
  String? _errorMessage;
  Listing? _currentListing;
  List<Listing> _landlordListings = [];
  XFile? _selectedImage;

  bool _isOnline = true;
  String? _currentToken;
  bool get isOnline => _isOnline;

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

  void _setupAutoSave() {
    titleController.addListener(_saveDraft);
    descriptionController.addListener(_saveDraft);
    rentController.addListener(_saveDraft);
    depositController.addListener(_saveDraft);
    leaseLengthController.addListener(_saveDraft);
  }

  Future<void> _saveDraft() async {
    final draft = {
      'title': titleController.text,
      'description': descriptionController.text,
      'rent': rentController.text,
      'deposit': depositController.text,
      'leaseLength': leaseLengthController.text,
      'moveInDate': _moveInDate?.toIso8601String(),
      'selectedHouseRules': _selectedHouseRules,
      'selectedAmenities': _selectedAmenities,
      'selectedPropertyType': _selectedPropertyType,
      'photos': _photos,
      'coverPhoto': _coverPhoto,
    };
    await _offlineQueue.saveListingDraft(draft);
  }

  Future<void> _loadDraft() async {
    final draft = await _offlineQueue.loadListingDraft();
    if (draft != null) {
      titleController.text = draft['title'] ?? '';
      descriptionController.text = draft['description'] ?? '';
      rentController.text = draft['rent'] ?? '';
      depositController.text = draft['deposit'] ?? '';
      leaseLengthController.text = draft['leaseLength'] ?? '';
      if (draft['moveInDate'] != null) {
        _moveInDate = DateTime.parse(draft['moveInDate']);
      }
      _selectedHouseRules = List<String>.from(draft['selectedHouseRules'] ?? []);
      _selectedAmenities = List<String>.from(draft['selectedAmenities'] ?? []);
      _selectedPropertyType = draft['selectedPropertyType'] ?? 'Studio';
      _photos = List<String>.from(draft['photos'] ?? []);
      _coverPhoto = draft['coverPhoto'];
      _photosSubject.add(_photos);
      notifyListeners();
    }
  }

  Future<void> clearDraft() async {
    await _offlineQueue.clearListingDraft();
    clearForm();
  }

  void _setupConnectivityListener() {
    _connectivity.onConnectivityChanged.listen((isOnline) {
      _isOnline = isOnline;
      notifyListeners();
      if (isOnline && _currentToken != null) {
        _syncPendingTasks(token: _currentToken!);
      }
    });
  }

  Future<void> _syncPendingTasksOnStart() async {
    final isOnline = await _connectivity.checkConnection();
    if (isOnline && _currentToken != null) {
      await _syncPendingTasks(token: _currentToken!);
    }
  }

  Future<void> _syncPendingTasks({required String token}) async {
    final tasks = await _offlineQueue.getPendingTasks();
    if (tasks.isEmpty) return;

    _progressSubject.add('Syncing ${tasks.length} pending listings...');
    
    for (final task in tasks) {
      try {
        if (task['type'] == 'create_listing') {
          final data = task['data'] as Map<String, dynamic>;
          
          final listing = Listing(
            id: 0,
            title: data['title'],
            listingType: 'property',
            description: data['description'],
            propertyType: data['propertyType'],
            address: '123 University Ave',
            city: 'Cambridge',
            state: 'MA',
            zipCode: '02139',
            latitude: 42.3736,
            longitude: -71.1097,
            rent: data['rent'],
            securityDeposit: data['deposit'],
            utilitiesIncluded: false,
            utilitiesCost: null,
            availableDate: DateTime.parse(data['moveInDate']),
            leaseTermMonths: data['leaseTermMonths'],
            bedrooms: data['bedrooms'],
            bathrooms: 1,
            petsAllowed: data['petsAllowed'],
            partiesAllowed: data['partiesAllowed'],
            smokingAllowed: data['smokingAllowed'],
            userId: data['landlordId'],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          
          final apiListing = ApiListing.fromListing(listing);
          final result = await _apiService.createListing(apiListing, token: token);
          
          for (String photoPath in data['photos']) {
            if (photoPath.startsWith('/') || photoPath.startsWith('C:')) {
              await _apiService.uploadListingPhoto(
                listingId: result.id.toString(),
                imagePath: photoPath,
                token: token,
              );
            }
          }
          
          await _offlineQueue.removeTask(task['id']);
          _progressSubject.add('Synced: ${listing.title}');
        }
      } catch (e) {
        // Error already handled silently
      }
    }
    
    await loadLandlordListings(token);
    _progressSubject.add('');
  }

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
    _saveDraft();
    notifyListeners();
  }

  void toggleAmenity(String amenity) {
    if (_selectedAmenities.contains(amenity)) {
      _selectedAmenities.remove(amenity);
    } else {
      _selectedAmenities.add(amenity);
    }
    validateField('amenities', '');
    _saveDraft();
    notifyListeners();
  }

  void setPropertyType(String type) {
    _selectedPropertyType = type;
    validateField('propertyType', type);
    _saveDraft();
    notifyListeners();
  }

  void setMoveInDate(DateTime date) {
    _moveInDate = date;
    validateField('moveInDate', '');
    _saveDraft();
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
    _saveDraft();
    notifyListeners();
  }

  void removePhoto(String photoPath) {
    _photos.remove(photoPath);
    _photosSubject.add(_photos);
    if (_coverPhoto == photoPath) {
      _coverPhoto = _photos.isNotEmpty ? _photos.first : null;
    }
    validateField('photos', '');
    _saveDraft();
    notifyListeners();
  }

  void setCoverPhoto(String photoPath) {
    _coverPhoto = photoPath;
    _saveDraft();
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

  String _cleanImagePath(String path) {
    if (path.startsWith('file://')) {
      return path.replaceFirst('file://', '');
    }
    return path;
  }

  String _getPropertyTypeValue() {
    switch (_selectedPropertyType) {
      case 'Shared room':
        return 'shared_room';
      case 'Studio':
        return 'studio';
      case '1 bedroom':
        return 'one_bedroom';
      case '2 bedrooms':
        return 'two_bedrooms';
      case '3+ bedrooms':
        return 'three_plus_bedrooms';
      default:
        return 'studio';
    }
  }

  Future<Listing?> submitListing(String token) async {
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
      final apiListing = ApiListing(
        id: 0,
        title: titleController.text.trim(),
        listingType: 'property',
        description: descriptionController.text.trim(),
        propertyType: _getPropertyTypeValue(),
        address: '123 University Ave',
        city: 'Cambridge',
        state: 'MA',
        zipCode: '02139',
        latitude: 42.3736,
        longitude: -71.1097,
        rent: double.parse(rentController.text),
        securityDeposit: double.parse(depositController.text),
        utilitiesIncluded: _selectedAmenities.isNotEmpty,
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

      _progressSubject.add('Sending to server...');
      final result = await _apiService.createListing(apiListing, token: token);
      
      _progressSubject.add('Uploading photos...');
      for (String photoPath in _photos) {
        final cleanPath = _cleanImagePath(photoPath);
        final file = File(cleanPath);
        if (await file.exists()) {
          try {
            await _apiService.uploadListingPhoto(
              listingId: result.id.toString(),
              imagePath: cleanPath,
              token: token,
            );
          } catch (e) {
            print('Error uploading photo $cleanPath: $e');
          }
        }
      }
      
      _progressSubject.add('Saving to local cache...');
      _currentListing = result.toListing();
      await _storageService.saveSingleListing(_currentListing!);
      
      final updatedListings = List<Listing>.from(_landlordListings)..add(_currentListing!);
      await _storageService.saveListings(updatedListings);
      
      _landlordListings = updatedListings;
      _isLoading = false;
      _progressSubject.add('Listing published!');
      
      clearForm();
      await _offlineQueue.clearListingDraft();
      
      await Future.delayed(const Duration(milliseconds: 500));
      _progressSubject.add('');
      
      notifyListeners();
      return _currentListing;
    } catch (e) {
      final errorStr = e.toString();
      
      // Fallback para conexión offline
      if (errorStr.contains('SocketException') || 
          errorStr.contains('Connection refused') ||
          errorStr.contains('Failed to connect')) {
        
        final taskData = {
          'title': titleController.text.trim(),
          'description': descriptionController.text.trim(),
          'rent': double.parse(rentController.text),
          'deposit': double.parse(depositController.text),
          'leaseTermMonths': int.parse(leaseLengthController.text.split(' ')[0]),
          'moveInDate': _moveInDate!.toIso8601String(),
          'propertyType': _getPropertyTypeValue(),
          'bedrooms': _getBedroomsFromType(_selectedPropertyType),
          'petsAllowed': _getPetsAllowed(),
          'partiesAllowed': _getPartiesAllowed(),
          'smokingAllowed': _getSmokingAllowed(),
          'photos': _photos,
          'landlordId': '', // O el ID real si lo tenés
        };
        
        await _offlineQueue.addTask('create_listing', taskData);
        _errorMessage = 'No internet connection. Listing saved offline and will sync later.';
        _progressSubject.add('Saved offline');
      } else {
        _errorMessage = errorStr;
        _progressSubject.add('Error: $errorStr');
      }
      
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<void> loadLandlordListings(String token) async {
    _currentToken = token;
    _isLoading = true;
    notifyListeners();

    try {
      final listings = await _apiService.getListings(token: token);
      _landlordListings = listings.map((apiListing) => apiListing.toListing()).toList();
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

  Future<void> loadListing(String id, String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      final apiListing = await _apiService.getListing(id, token: token);
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

  Future<bool> updateListing(Listing listing, String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      final apiListing = ApiListing.fromListing(listing);
      final updated = await _apiService.updateListing(apiListing, token: token);
      
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

  Future<bool> deleteListing(String id, String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.deleteListing(id, token: token);
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