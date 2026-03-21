import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/api_service.dart';
import '../services/models/api_profile.dart';

class AuthViewModel extends ChangeNotifier {
  final ApiService _apiService;
  final FlutterSecureStorage _storage;

  AuthViewModel({
    required ApiService apiService,
    FlutterSecureStorage? storage,
  })  : _apiService = apiService,
        _storage = storage ?? const FlutterSecureStorage();

  bool _isLoading = false;
  String? _errorMessage;
  ApiProfile? _currentUser;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  ApiProfile? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLandlord => _currentUser?.role == 'landlord';
  bool get isStudent => _currentUser?.role == 'student';

  Future<bool> signUp({
    required String firstName,
    required String lastName,
    required String email,
    required String role,
    String? phone,
  }) async {
    _setLoading(true);
    try {
      final clerkId = _buildClerkId(email);
      _apiService.setClerkId(clerkId);

      final user = await _apiService.syncUser(
        firstName: firstName,
        lastName: lastName,
        email: email,
        role: role,
        phone: phone,
      );

      _currentUser = user;
      await _storage.write(key: 'clerk_id', value: clerkId);
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = _parseError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signIn({required String email}) async {
    _setLoading(true);
    try {
      final clerkId = _buildClerkId(email);
      _apiService.setClerkId(clerkId);

      final user = await _apiService.getProfile();
      _currentUser = user;
      await _storage.write(key: 'clerk_id', value: clerkId);
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = _parseError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> restoreSession() async {
    try {
      final clerkId = await _storage.read(key: 'clerk_id');
      if (clerkId == null) return false;

      _apiService.setClerkId(clerkId);
      final user = await _apiService.getProfile();
      _currentUser = user;
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> signOut() async {
    await _storage.delete(key: 'clerk_id');
    _currentUser = null;
    _apiService.setClerkId('');
    notifyListeners();
  }

  Future<void> markOnboarded() async {
  try {
    final updated = await _apiService.markOnboarded();
    _currentUser = updated;
    notifyListeners();
  } catch (e) {
    _errorMessage = _parseError(e);
    notifyListeners();
  }
}

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  String _buildClerkId(String email) {
    return 'dev_${email.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}';
  }

  String _parseError(dynamic e) {
    final msg = e.toString();
    if (msg.contains('401')) return 'Usuario no encontrado. Verifica tu email.';
    if (msg.contains('Network')) return 'Error de conexión. Verifica que el servidor esté corriendo.';
    return 'Ocurrió un error. Intenta de nuevo.';
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}