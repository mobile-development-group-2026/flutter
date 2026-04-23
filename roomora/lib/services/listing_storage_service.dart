import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import '../models/listing.dart';

class ListingStorageService {
  static final ListingStorageService _instance = ListingStorageService._internal();
  factory ListingStorageService() => _instance;
  ListingStorageService._internal();

  Box? _listingsBox;
  final Map<String, DateTime> _cacheTimestamps = {};
  static const int _maxCacheAgeMinutes = 30;

  Future<void> init() async {
    if (_listingsBox == null) {
      final appDocumentDir = await getApplicationDocumentsDirectory();
      Hive.init(appDocumentDir.path);
      _listingsBox = await Hive.openBox('listings_cache');
    }
  }

  Future<void> saveListings(List<Listing> listings) async {
    await init();
    final listingsJson = listings.map((l) => json.encode(l.toJson())).toList();
    await _listingsBox?.put('cached_listings', listingsJson);
    await _listingsBox?.put('cached_timestamp', DateTime.now().toIso8601String());
    _cacheTimestamps['listings'] = DateTime.now();
  }

  Future<List<Listing>> getCachedListings() async {
    await init();
    final cachedData = _listingsBox?.get('cached_listings');
    final timestampStr = _listingsBox?.get('cached_timestamp');
    
    if (cachedData != null && timestampStr != null) {
      final timestamp = DateTime.parse(timestampStr);
      final ageMinutes = DateTime.now().difference(timestamp).inMinutes;
      
      if (ageMinutes <= _maxCacheAgeMinutes) {
        final List<String> listingsJson = List<String>.from(cachedData);
        return listingsJson.map((jsonString) => Listing.fromJson(json.decode(jsonString))).toList();
      }
    }
    return [];
  }

  Future<void> saveSingleListing(Listing listing) async {
    await init();
    final key = 'listing_${listing.id}';
    await _listingsBox?.put(key, json.encode(listing.toJson()));
  }

  Future<Listing?> getSingleListing(String id) async {
    await init();
    final key = 'listing_$id';
    final cached = _listingsBox?.get(key);
    if (cached != null) {
      return Listing.fromJson(json.decode(cached));
    }
    return null;
  }

  Future<void> deleteListing(int id) async {
    await init();
    final key = 'listing_$id';
    await _listingsBox?.delete(key);
    
    final allListings = await getCachedListings();
    final updatedListings = allListings.where((l) => l.id != id).toList();
    await saveListings(updatedListings);
  }

  Future<void> clearCache() async {
    await init();
    await _listingsBox?.clear();
    _cacheTimestamps.clear();
  }
}