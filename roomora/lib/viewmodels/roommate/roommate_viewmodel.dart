import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/../models/roommate_profile.dart';
import '/../services/connectivity_service.dart';
import '/../services/api_service.dart';

class RoommateViewModel extends ChangeNotifier {
  final ApiService _apiService;
  final ConnectivityService _connectivity;

  RoommateViewModel({required ApiService apiService})
      : _apiService = apiService,
        _connectivity = ConnectivityService() {
    _loadStarredIds();
  }

  List<RoommateProfile> _allRoommates = [];
  Set<String> _starredIds = {};
  bool _isLoading = false;
  String? _errorMessage;
  bool _isOnline = true;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isOnline => _isOnline;

  /// Roommates ordenados: starred primero, luego el resto
  List<RoommateProfile> get roommates {
    final starred = _allRoommates.where((r) => _starredIds.contains(r.id)).toList();
    final rest = _allRoommates.where((r) => !_starredIds.contains(r.id)).toList();
    return [...starred, ...rest];
  }

  List<RoommateProfile> get starredRoommates =>
      _allRoommates.where((r) => _starredIds.contains(r.id)).toList();

  bool isStarred(String id) => _starredIds.contains(id);

  // ─────────────────────────────────────────────
  // Cargar desde API (o caché si sin conexión)
  // ─────────────────────────────────────────────
  Future<void> loadRoommates(String token) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _isOnline = await _connectivity.checkConnection();

    if (!_isOnline) {
      // Sin conexión: mostrar solo los que están marcados con estrella
      await _loadStarredIds();
      final cached = await _getCachedRoommates();
      _allRoommates = cached.where((r) => _starredIds.contains(r.id)).toList();
      _isLoading = false;
      if (_allRoommates.isEmpty) {
        _errorMessage = 'offline';
      }
      notifyListeners();
      return;
    }

    try {
      final profiles = await _apiService.getRoommates(token: token);
      _allRoommates = profiles;
      await _cacheRoommates(profiles);
      _errorMessage = null;
    } catch (e) {
      // Falló la conexión al back: intentar caché
      final cached = await _getCachedRoommates();
      if (cached.isNotEmpty) {
        // Mostrar solo starred en caché
        _allRoommates = cached.where((r) => _starredIds.contains(r.id)).toList();
        _errorMessage = 'offline';
      } else {
        _errorMessage = e.toString();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─────────────────────────────────────────────
  // Toggle estrella y persistir localmente
  // ─────────────────────────────────────────────
  Future<void> toggleStar(String id) async {
    if (_starredIds.contains(id)) {
      _starredIds.remove(id);
    } else {
      _starredIds.add(id);
    }
    notifyListeners();
    await _persistStarredIds();
  }

  // ─────────────────────────────────────────────
  // Persistencia de IDs con estrella
  // ─────────────────────────────────────────────
  static const _starredKey = 'roommate_starred_ids';

  Future<void> _loadStarredIds() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_starredKey) ?? [];
    _starredIds = raw.toSet();
  }

  Future<void> _persistStarredIds() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_starredKey, _starredIds.toList());
  }

  // ─────────────────────────────────────────────
  // Caché de perfiles
  // ─────────────────────────────────────────────
  static const _cacheKey = 'roommate_profiles_cache';

  Future<void> _cacheRoommates(List<RoommateProfile> profiles) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = profiles.map((p) => json.encode(p.toJson())).toList();
    await prefs.setStringList(_cacheKey, encoded);
  }

  Future<List<RoommateProfile>> _getCachedRoommates() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_cacheKey) ?? [];
    return raw.map((s) => RoommateProfile.fromJson(json.decode(s))).toList();
  }
}