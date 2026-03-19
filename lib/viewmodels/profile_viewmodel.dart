import 'package:flutter/material.dart';
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

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  LandlordProfile? get currentProfile => _currentProfile;
  String? get profilePhoto => _profilePhoto;

  final bioController = TextEditingController();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

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
    notifyListeners();
  }

  void loadProfileToForm(LandlordProfile profile) {
    bioController.text = profile.bio;
    nameController.text = profile.name;
    emailController.text = profile.email;
    phoneController.text = profile.phone;
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
    if (!validateForm()) {
      _errorMessage = 'Please fill in all required fields';
      notifyListeners();
      return null;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final profile = LandlordProfile(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        bio: bioController.text,
        profilePhoto: _profilePhoto!,
        name: nameController.text,
        email: emailController.text,
        phone: phoneController.text,
        responseRate: 100.0,
        responseTime: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final apiProfile = ApiProfile.fromProfile(profile);
      final result = await _apiService.createProfile(apiProfile);
      _currentProfile = result.toProfile();
      
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

  Future<void> loadProfile(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      final profile = await _apiService.getProfile(id);
      _currentProfile = profile.toProfile();
      loadProfileToForm(_currentProfile!);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile() async {
    if (_currentProfile == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final updatedProfile = _currentProfile!.copyWith(
        bio: bioController.text,
        profilePhoto: _profilePhoto,
        name: nameController.text,
        email: emailController.text,
        phone: phoneController.text,
        updatedAt: DateTime.now(),
      );

      final apiProfile = ApiProfile.fromProfile(updatedProfile);
      final result = await _apiService.updateProfile(apiProfile);
      _currentProfile = result.toProfile();
      
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