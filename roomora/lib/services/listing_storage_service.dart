import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
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
        return listingsJson.map((json) => Listing.fromJson(json.decode(json))).toList();
      }
    }
    return [];
  }

  Future<void> saveSingleListing(Listing listing) async {
    await init();
    await _listingsBox?.put('listing_${listing.id}', json.encode(listing.toJson()));
  }

  Future<Listing?> getSingleListing(String id) async {
    await init();
    final cached = _listingsBox?.get('listing_$id');
    if (cached != null) {
      return Listing.fromJson(json.decode(cached));
    }
    return null;
  }

  Future<void> deleteListing(String id) async {
    await init();
    await _listingsBox?.delete('listing_$id');
    
    final allListings = await getCachedListings();
    final updatedListings = allListings.where((l) => l.id.toString() != id).toList();
    await saveListings(updatedListings);
  }

  Future<void> clearCache() async {
    await init();
    await _listingsBox?.clear();
    _cacheTimestamps.clear();
  }
}