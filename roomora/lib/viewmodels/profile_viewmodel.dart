import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/landlord_profile.dart';
import '../services/api_service.dart';
import '../services/models/api_profile.dart';

class ProfileViewModel extends ChangeNotifier {
  final ApiService _apiService;

  ProfileViewModel({required ApiService apiService}) : _apiService = apiService;

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
    notifyListeners();
  }

  void clearForm() {
    bioController.clear();
    nameController.clear();
    emailController.clear();
    phoneController.clear();
    _profilePhoto = null;
    _selectedImage = null;
    notifyListeners();
  }

  void loadProfileToForm(LandlordProfile profile) {
    bioController.text = profile.bio ?? '';
    nameController.text = profile.fullName;
    emailController.text = profile.email;
    phoneController.text = profile.phone ?? '';
    _profilePhoto = profile.profilePhoto;
    notifyListeners();
  }

  bool validateForm() {
    return bioController.text.isNotEmpty &&
        nameController.text.isNotEmpty &&
        emailController.text.isNotEmpty &&
        phoneController.text.isNotEmpty &&
        _profilePhoto != null;
  }

  Future<LandlordProfile?> submitProfile() async {
  print('submitProfile() INICIADO');
  
  if (!validateForm()) {
    print('Formulario invalido');
    _errorMessage = 'Please fill in all required fields and add a photo';
    notifyListeners();
    return null;
  }

  _isLoading = true;
  _errorMessage = null;
  notifyListeners();

  try {
    print('Preparando perfil para enviar...');
    
    final nameParts = nameController.text.trim().split(' ');
    final firstName = nameParts.isNotEmpty ? nameParts[0] : '';
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    final apiProfile = ApiProfile(
      id: 0,
      bio: bioController.text,
      profilePhoto: _profilePhoto,
      firstName: firstName,
      lastName: lastName,
      email: emailController.text.trim(),
      phone: phoneController.text.trim(),
      university: null,
      verified: true,
      role: 'landlord',
      clerkId: 'dev_landlord_1',
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    );

    print('Llamando a _apiService.updateProfile...');
    print('URL: ${ApiService.baseUrl}/profile');
    
    final result = await _apiService.updateProfile(apiProfile);
    
    print('Respuesta recibida: $result');
    
    _currentProfile = LandlordProfile(
      id: result.id,
      bio: result.bio,
      profilePhoto: result.profilePhoto,
      firstName: result.firstName,
      lastName: result.lastName,
      email: result.email,
      phone: result.phone,
      university: result.university,
      verified: result.verified,
      role: result.role,
      clerkId: result.clerkId,
      createdAt: DateTime.parse(result.createdAt),
      updatedAt: DateTime.parse(result.updatedAt),
    );
    
    _isLoading = false;
    notifyListeners();
    return _currentProfile;
  } catch (e) {
    print('ERROR: $e');
    print('Stack trace: ${StackTrace.current}');
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

      final apiProfile = ApiProfile(
        id: _currentProfile!.id,
        bio: bioController.text,
        profilePhoto: _profilePhoto,
        firstName: firstName,
        lastName: lastName,
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        university: _currentProfile!.university,
        verified: _currentProfile!.verified,
        role: _currentProfile!.role,
        clerkId: _currentProfile!.clerkId,
        createdAt: _currentProfile!.createdAt.toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );

      final result = await _apiService.updateProfile(apiProfile);
      
      _currentProfile = LandlordProfile(
        id: result.id,
        bio: result.bio,
        profilePhoto: result.profilePhoto,
        firstName: result.firstName,
        lastName: result.lastName,
        email: result.email,
        phone: result.phone,
        university: result.university,
        verified: result.verified,
        role: result.role,
        clerkId: result.clerkId,
        createdAt: DateTime.parse(result.createdAt),
        updatedAt: DateTime.parse(result.updatedAt),
      );
      
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