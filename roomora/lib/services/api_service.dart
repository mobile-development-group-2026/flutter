import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:roomora/models/landlord_profile.dart';
import 'models/api_listing.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:3000/api/v1';
  static const String clerkId = 'dev_landlord_1';
  
  final http.Client _client = http.Client();

  Future<Map<String, String>> _getHeaders() async {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-Dev-Clerk-Id': 'dev_landlord_1',
    };
  }

  Future<Map<String, String>> _getMultipartHeaders() async {
    return {
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

  Future<LandlordProfile> updateProfile(Map<String, dynamic> profileData) async {
    final userData = {
      'user': {
        'first_name': profileData['firstName'],
        'last_name': profileData['lastName'],
        'email': profileData['email'],
        'phone': profileData['phone'],
        'avatar_url': profileData['profilePhoto'],
        'onboarded': true,
      }
    };
    
    try {
      final headers = await _getHeaders();
      
      final response = await _client.patch(
        Uri.parse('$baseUrl/profile'),
        headers: headers,
        body: json.encode(userData),
      );
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final userJson = responseData['data'] ?? responseData;
        
        return LandlordProfile(
          id: userJson['id']?.toString() ?? '',
          bio: profileData['bio'],
          profilePhoto: userJson['avatar_url'],
          firstName: userJson['first_name'] ?? '',
          lastName: userJson['last_name'] ?? '',
          email: userJson['email'] ?? '',
          phone: userJson['phone'],
          university: null,
          verified: userJson['verified'] ?? false,
          role: userJson['role'] ?? 'landlord',
          clerkId: userJson['clerk_id'] ?? '',
          createdAt: DateTime.parse(userJson['created_at'] ?? DateTime.now().toIso8601String()),
          updatedAt: DateTime.parse(userJson['updated_at'] ?? DateTime.now().toIso8601String()),
        );
      } else {
        throw Exception('Failed to update profile: ${response.statusCode}');
      }
    } catch (e) {
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
      final body = json.encode(listing.toJson());
      
      final response = await _client.post(
        Uri.parse('$baseUrl/listings'),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData.containsKey('data') && responseData['data'] != null) {
          return ApiListing.fromJson(responseData['data']);
        }
        return ApiListing.fromJson(responseData);
      } else {
        throw Exception('Failed to create listing: ${response.statusCode} - ${response.body}');
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
      final File imageFile = File(imagePath);
      
      if (!await imageFile.exists()) {
        throw Exception('File does not exist: $imagePath');
      }
      
      final uri = Uri.parse('$baseUrl/listings/$listingId/photos');
      final request = http.MultipartRequest('POST', uri);
      
      final headers = await _getMultipartHeaders();
      request.headers.addAll(headers);
      
      final multipartFile = await http.MultipartFile.fromPath(
        'photo',
        imagePath,
        filename: imagePath.split('/').last,
      );
      
      request.files.add(multipartFile);
      
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      
      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception('Failed to upload photo: ${response.statusCode} - $responseBody');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}