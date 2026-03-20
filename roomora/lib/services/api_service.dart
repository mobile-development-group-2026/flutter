import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:roomora/models/landlord_profile.dart';
import 'models/api_listing.dart';
import 'models/api_profile.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.0.19:3000/api/v1';
  static const String clerkId = 'dev_landlord_1';
  
  final http.Client _client = http.Client();

  Future<Map<String, String>> _getHeaders() async {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-Dev-Clerk-Id': 'dev_landlord_1',
    };
  }

  Future<LandlordProfile> getProfile() async {
  try {
    final headers = await _getHeaders();
    final response = await _client.get(
      Uri.parse('$baseUrl/profile'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return LandlordProfile.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to get profile: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Network error: $e');
  }
}

  Future<ApiProfile> updateProfile(ApiProfile profile) async {
  print('ApiService.updateProfile INICIADO');
  print('URL: $baseUrl/profile');
  print('Body: ${profile.toJson()}');
  
  try {
    final headers = await _getHeaders();
    print('Headers: $headers');
    
    final response = await _client.patch(
      Uri.parse('$baseUrl/profile'),
      headers: headers,
      body: json.encode(profile.toJson()),
    );
    
    print('Respuesta status: ${response.statusCode}');
    print('Respuesta body: ${response.body}');
    
    if (response.statusCode == 200) {
      return ApiProfile.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update profile: ${response.statusCode}');
    }
  } catch (e) {
    print('ERROR en updateProfile: $e');
    rethrow;
  }
}

  Future<List<ApiListing>> getListings() async {
    try {
      final headers = await _getHeaders();
      final response = await _client.get(
        Uri.parse('$baseUrl/listings'),
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

  Future<ApiListing> updateListing(ApiListing listing) async {
    try {
      final headers = await _getHeaders();
      final response = await _client.patch(
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

  Future<void> uploadListingPhoto(String listingId, String imagePath) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/listings/$listingId/photos'),
      );
      
      final headers = await _getHeaders();
      request.headers.addAll(headers);
      request.files.add(await http.MultipartFile.fromPath('photo', imagePath));
      
      var response = await request.send();
      
      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception('Failed to upload photo: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}