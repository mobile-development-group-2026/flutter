import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/landlord_profile.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';

class ProfileViewModel extends ChangeNotifier {
  final ApiService _apiService;
  final LocalStorageService _storageService;

  ProfileViewModel({
    required ApiService apiService,
    LocalStorageService? storageService,
  }) : _apiService = apiService,
       _storageService = storageService ?? LocalStorageService();

  bool _isLoading = false;
  String? _errorMessage;
  LandlordProfile? _currentProfile;
  String? _profilePhoto;
  XFile? _selectedImage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  LandlordProfile? get currentProfile => _currentProfile;
  String? get profilePhoto => _profilePhoto;
  XFile? get selectedImage => _selectedImage;

  final bioController = TextEditingController();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  final Map<String, String> _fieldErrors = {};
  Map<String, String> get fieldErrors => _fieldErrors;

  final List<String> _reservedSqlKeywords = [
    'SELECT', 'INSERT', 'UPDATE', 'DELETE', 'DROP', 'CREATE', 'ALTER',
    'UNION', 'JOIN', 'WHERE', 'FROM', 'TABLE', 'DATABASE', 'OR', 'AND',
    'SCRIPT', 'JAVASCRIPT', 'ALERT', 'ONLOAD', 'IMG', 'SRC'
  ];

  final List<String> _dangerousCharacters = [
    '\'', '"', ';', '--', '/*', '*/', 'xp_', 'sp_', '\\x'
  ];

  String? _checkForSqlInjection(String value, String fieldName) {
    final upperValue = value.toUpperCase();
    
    for (final keyword in _reservedSqlKeywords) {
      if (upperValue.contains(keyword) && value.length == keyword.length) {
        return '$fieldName contains invalid characters';
      }
      if (upperValue.contains(keyword) && keyword.length > 3) {
        final pattern = RegExp('\\b$keyword\\b', caseSensitive: false);
        if (pattern.hasMatch(upperValue)) {
          return '$fieldName contains invalid SQL keywords';
        }
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

  String? _validateName(String value) {
    if (value.isEmpty) {
      return 'Full name is required';
    }
    if (value.trim().split(' ').length < 2) {
      return 'Please enter both first and last name';
    }
    if (value.length < 3) {
      return 'Name must be at least 3 characters';
    }
    if (value.length > 100) {
      return 'Name cannot exceed 100 characters';
    }
    return _checkForSqlInjection(value, 'Name');
  }

  String? _validateEmail(String value) {
    if (value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email (e.g., name@example.com)';
    }
    if (value.length > 100) {
      return 'Email cannot exceed 100 characters';
    }
    return _checkForSqlInjection(value, 'Email');
  }

  String? _validatePhone(String value) {
    if (value.isEmpty) {
      return 'Phone number is required';
    }
    final phoneRegex = RegExp(r'^[\+]?[(]?[0-9]{1,3}[)]?[-\s\.]?[(]?[0-9]{1,4}[)]?[-\s\.]?[0-9]{1,4}[-\s\.]?[0-9]{1,9}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Enter a valid phone number';
    }
    if (value.length < 10) {
      return 'Phone number must be at least 10 digits';
    }
    if (value.length > 20) {
      return 'Phone number cannot exceed 20 digits';
    }
    return _checkForSqlInjection(value, 'Phone');
  }

  String? _validateBio(String value) {
    if (value.isEmpty) {
      return 'Bio is required';
    }
    if (value.length < 20) {
      return 'Bio must be at least 20 characters';
    }
    if (value.length > 500) {
      return 'Bio cannot exceed 500 characters';
    }
    return _checkForSqlInjection(value, 'Bio');
  }

  String? _validateProfilePhoto() {
    if (_profilePhoto == null) {
      return 'Profile photo is required';
    }
    return null;
  }

  void validateField(String field, String value) {
    String? error;
    switch (field) {
      case 'name':
        error = _validateName(value);
        break;
      case 'email':
        error = _validateEmail(value);
        break;
      case 'phone':
        error = _validatePhone(value);
        break;
      case 'bio':
        error = _validateBio(value);
        break;
      case 'photo':
        error = _validateProfilePhoto();
        break;
    }
    if (error != null) {
      _fieldErrors[field] = error;
    } else {
      _fieldErrors.remove(field);
    }
    notifyListeners();
  }

  void clearFieldError(String field) {
    _fieldErrors.remove(field);
    notifyListeners();
  }

  Map<String, String> validateAllFields() {
    final errors = <String, String>{};
    
    final nameError = _validateName(nameController.text);
    if (nameError != null) errors['name'] = nameError;
    
    final emailError = _validateEmail(emailController.text);
    if (emailError != null) errors['email'] = emailError;
    
    final phoneError = _validatePhone(phoneController.text);
    if (phoneError != null) errors['phone'] = phoneError;
    
    final bioError = _validateBio(bioController.text);
    if (bioError != null) errors['bio'] = bioError;
    
    final photoError = _validateProfilePhoto();
    if (photoError != null) errors['photo'] = photoError;
    
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
          title: const Text(
            'Please fix the following errors',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Required fields:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                const Text('• Full name (3-100 characters)'),
                const Text('• Email address (valid format)'),
                const Text('• Phone number (10-20 digits)'),
                const Text('• Bio (20-500 characters)'),
                const Text('• Profile photo'),
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
                      const Text(
                        'Errors found:',
                        style: TextStyle(fontWeight: FontWeight.w600, color: Colors.red),
                      ),
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
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF7B5BF2),
              ),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> pickImageFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        _selectedImage = image;
        _profilePhoto = image.path;
        validateField('photo', image.path);
        notifyListeners();
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
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        _selectedImage = image;
        _profilePhoto = image.path;
        validateField('photo', image.path);
        notifyListeners();
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

  void setProfilePhoto(String path) {
    _profilePhoto = path;
    validateField('photo', path);
    notifyListeners();
  }

  void clearForm() {
    bioController.clear();
    nameController.clear();
    emailController.clear();
    phoneController.clear();
    _profilePhoto = null;
    _selectedImage = null;
    _fieldErrors.clear();
    notifyListeners();
  }

  void loadProfileToForm(LandlordProfile profile) {
    bioController.text = profile.bio ?? '';
    nameController.text = profile.fullName;
    emailController.text = profile.email;
    phoneController.text = profile.phone ?? '';
    _profilePhoto = profile.profilePhoto;
    _fieldErrors.clear();
    notifyListeners();
  }

  Future<void> loadCachedProfile() async {
    final cached = await _storageService.getProfile();
    if (cached != null) {
      _currentProfile = cached;
      loadProfileToForm(cached);
      notifyListeners();
    }
  }

  Future<LandlordProfile?> submitProfile() async {
    if (!validateForm()) {
      return null;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final nameParts = nameController.text.trim().split(' ');
      final firstName = nameParts.isNotEmpty ? nameParts[0] : '';
      final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

      final profileData = {
        'firstName': firstName,
        'lastName': lastName,
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
        'profilePhoto': _profilePhoto,
        'bio': bioController.text,
      };

      final result = await _apiService.updateProfile(profileData);
      
      await _storageService.saveProfile(result);
      
      _currentProfile = result;
      _isLoading = false;
      notifyListeners();
      return _currentProfile;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<bool> updateProfile() async {
    if (_currentProfile == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final nameParts = nameController.text.trim().split(' ');
      final firstName = nameParts.isNotEmpty ? nameParts[0] : '';
      final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

      final profileData = {
        'firstName': firstName,
        'lastName': lastName,
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
        'profilePhoto': _profilePhoto,
        'bio': bioController.text,
      };

      final result = await _apiService.updateProfile(profileData);
      
      await _storageService.saveProfile(result);
      _currentProfile = result;
      
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
    bioController.dispose();
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }
}