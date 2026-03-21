import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:roomora/models/landlord_profile.dart';
import 'models/api_listing.dart';
import 'models/api_profile.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:3000/api/v1';

  String _clerkId = '';
  final http.Client _client = http.Client();

  void setClerkId(String clerkId) {
    _clerkId = clerkId;
  }

  Future<Map<String, String>> _getHeaders() async {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-Dev-Clerk-Id': _clerkId,
    };
  }

  Future<ApiProfile> syncUser({
    required String firstName,
    required String lastName,
    required String email,
    required String role,
    String? phone,
  }) async {
    try {
      final headers = await _getHeaders();
      final body = {
        'user': {
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
          'role': role,
          if (phone != null) 'phone': phone,
        }
      };

      final response = await _client.post(
        Uri.parse('$baseUrl/auth/sync'),
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return ApiProfile.fromJson(data['data']);
      } else {
        final data = json.decode(response.body);
        throw Exception(data['error'] ?? 'Error al crear usuario');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<ApiProfile> getProfile() async {
    try {
      final headers = await _getHeaders();
      final response = await _client.get(
        Uri.parse('$baseUrl/profile'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ApiProfile.fromJson(data['data']);
      } else {
        final data = json.decode(response.body);
        throw Exception(data['error'] ?? 'Error al obtener perfil');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<ApiProfile> updateProfile(ApiProfile profile) async {
    try {
      final headers = await _getHeaders();
      final response = await _client.patch(
        Uri.parse('$baseUrl/profile'),
        headers: headers,
        body: json.encode({'user': profile.toJson()}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ApiProfile.fromJson(data['data']);
      } else {
        final data = json.decode(response.body);
        throw Exception(data['error'] ?? 'Error al actualizar perfil');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<ApiProfile> markOnboarded() async {
  try {
    final headers = await _getHeaders();
    final response = await _client.patch(
      Uri.parse('$baseUrl/profile'),
      headers: headers,
      body: json.encode({'user': {'onboarded': true}}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return ApiProfile.fromJson(data['data']);
    } else {
      final data = json.decode(response.body);
      throw Exception(data['error'] ?? 'Error al actualizar perfil');
    }
  } catch (e) {
    throw Exception('Network error: $e');
  }
}

  Future<LandlordProfile> getLandlordProfile() async {
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

  Future<List<ApiListing>> getListings() async {
    try {
      final headers = await _getHeaders();
      final response = await _client.get(
        Uri.parse('$baseUrl/listings'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> jsonList = data['data'];
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
        final data = json.decode(response.body);
        return ApiListing.fromJson(data['data']);
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
        body: json.encode({'listing': listing.toJson()}),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        return ApiListing.fromJson(data['data']);
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
        body: json.encode({'listing': listing.toJson()}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ApiListing.fromJson(data['data']);
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