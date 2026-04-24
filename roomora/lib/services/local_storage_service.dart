import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/landlord_profile.dart';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  final Map<String, LandlordProfile> _cache = {};
  final List<String> _cacheOrder = [];
  static const int _maxCacheSize = 10;

  void _addToCache(String key, LandlordProfile profile) {
    if (_cache.containsKey(key)) {
      _cacheOrder.remove(key);
    } else if (_cache.length >= _maxCacheSize) {
      final oldestKey = _cacheOrder.removeAt(0);
      _cache.remove(oldestKey);
    }
    _cache[key] = profile;
    _cacheOrder.add(key);
  }

  LandlordProfile? _getFromCache(String key) {
    if (_cache.containsKey(key)) {
      _cacheOrder.remove(key);
      _cacheOrder.add(key);
      return _cache[key];
    }
    return null;
  }

  Future<void> saveProfile(LandlordProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('landlord_profile', json.encode(profile.toJson()));
    _addToCache('current_profile', profile);
  }

  Future<LandlordProfile?> getProfile() async {
    final cached = _getFromCache('current_profile');
    if (cached != null) return cached;

    final prefs = await SharedPreferences.getInstance();
    final String? profileJson = prefs.getString('landlord_profile');
    if (profileJson != null) {
      final profile = LandlordProfile.fromJson(json.decode(profileJson));
      _addToCache('current_profile', profile);
      return profile;
    }
    return null;
  }

  Future<void> clearProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('landlord_profile');
    _cache.clear();
    _cacheOrder.clear();
  }
}