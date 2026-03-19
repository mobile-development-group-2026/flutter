import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'models/api_listing.dart';
import 'models/api_profile.dart';

class ApiService {
  static const String baseUrl = 'https://github.com/mobile-development-group-2026/api'; 
  final http.Client _client = http.Client();

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return {
      'Content-Type': 'application/json',
      'Authorization': token != null ? 'Bearer $token' : '',
    };
  }

  Future<ApiListing> createListing(ApiListing listing) async {
    try {
      final headers = await _getHeaders();
      final response = await _client.post(
        Uri.parse('$baseUrl/listings'),
        headers: headers,
        body: json.encode(listing.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return ApiListing.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create listing: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<ApiListing> getListing(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await _client.get(
        Uri.parse('$baseUrl/listings/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return ApiListing.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to get listing: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<ApiListing> updateListing(ApiListing listing) async {
    try {
      final headers = await _getHeaders();
      final response = await _client.put(
        Uri.parse('$baseUrl/listings/${listing.id}'),
        headers: headers,
        body: json.encode(listing.toJson()),
      );

      if (response.statusCode == 200) {
        return ApiListing.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update listing: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<List<ApiListing>> getLandlordListings(String landlordId) async {
    try {
      final headers = await _getHeaders();
      final response = await _client.get(
        Uri.parse('$baseUrl/listings/landlord/$landlordId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => ApiListing.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get listings: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<void> deleteListing(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await _client.delete(
        Uri.parse('$baseUrl/listings/$id'),
        headers: headers,
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete listing: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<ApiProfile> createProfile(ApiProfile profile) async {
    try {
      final headers = await _getHeaders();
      final response = await _client.post(
        Uri.parse('$baseUrl/profiles'),
        headers: headers,
        body: json.encode(profile.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return ApiProfile.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create profile: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<ApiProfile> getProfile(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await _client.get(
        Uri.parse('$baseUrl/profiles/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return ApiProfile.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to get profile: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<ApiProfile> updateProfile(ApiProfile profile) async {
    try {
      final headers = await _getHeaders();
      final response = await _client.put(
        Uri.parse('$baseUrl/profiles/${profile.id}'),
        headers: headers,
        body: json.encode(profile.toJson()),
      );

      if (response.statusCode == 200) {
        return ApiProfile.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update profile: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}