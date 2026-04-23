  import 'dart:convert';
  import 'package:http/http.dart' as http;
  import '../models/landlord_profile.dart';
  import 'models/api_listing.dart';
  import 'dart:io';


  class ApiService {
    static const String baseUrl = 'https://roomora-api-omhi.onrender.com/api/v1'; //Api Esteban
    // static const String baseUrl = 'https://roomora-api.onrender.com/api/v1'; //Api Andy
    final http.Client _client = http.Client();

    Map<String, String> _headers(String token) => {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        };

    Map<String, String> _multipartHeaders(String token) => {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        };

    Map<String, dynamic> _unwrap(Map<String, dynamic> body) {
      final inner = body['data'];
      if (inner == null) throw Exception('Missing "data" key in response');
      return inner as Map<String, dynamic>;
    }


    Future<LandlordProfile> syncUser({
      required String token,
      required String role,
      required String firstName,
      required String lastName,
      required String email,
      String? phone,
    }) async {
      final body = {
        'user': {
          'role': role,
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
          if (phone != null && phone.isNotEmpty) 'phone': phone,
        }
      };

      final response = await _client.post(
        Uri.parse('$baseUrl/auth/sync'),
        headers: _headers(token),
        body: json.encode(body),
      );

      final decoded = json.decode(response.body) as Map<String, dynamic>;
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('syncUser ${response.statusCode}: ${decoded['error']}');
      }
      return LandlordProfile.fromJson(_unwrap(decoded));
    }


    Future<LandlordProfile> fetchProfile({required String token}) async {
      final response = await _client.get(
        Uri.parse('$baseUrl/profile'),
        headers: _headers(token),
      );

      if (response.statusCode == 200) {
        final body = json.decode(response.body) as Map<String, dynamic>;
        return LandlordProfile.fromJson(_unwrap(body));
      }

      throw Exception('fetchProfile ${response.statusCode}: ${response.body}');
    }

    Future<LandlordProfile> getProfile({required String token}) async {
      return fetchProfile(token: token);
    }

    // Future<LandlordProfile> updateProfile(
    //   Map<String, dynamic> profileData, {
    //   required String token,
    // }) async {
    //   final userData = {
    //     'user': {
    //       'first_name': profileData['firstName'],
    //       'last_name': profileData['lastName'],
    //       'phone': profileData['phone'],
    //       'avatar_url': profileData['profilePhoto'],
    //       'onboarded': true,
    //     }
    //   };

    //   final response = await _client.patch(
    //     Uri.parse('$baseUrl/profile'),
    //     headers: _headers(token),
    //     body: json.encode(userData),
    //   );

    //   if (response.statusCode == 200) {
    //     final body = json.decode(response.body) as Map<String, dynamic>;
    //     final userJson = _unwrap(body);
    //     return LandlordProfile(
    //       id: userJson['id']?.toString() ?? '',
    //       bio: profileData['bio'],
    //       profilePhoto: userJson['avatar_url'],
    //       firstName: userJson['first_name'] ?? '',
    //       lastName: userJson['last_name'] ?? '',
    //       email: userJson['email'] ?? '',
    //       phone: userJson['phone'],
    //       university: null,
    //       verified: userJson['verified'] ?? false,
    //       role: userJson['role'] ?? 'landlord',
    //       clerkId: userJson['clerk_id'] ?? '',
    //       createdAt: DateTime.parse(userJson['created_at']),
    //       updatedAt: DateTime.parse(userJson['updated_at']),
    //     );
    //   }

    //   throw Exception('updateProfile ${response.statusCode}: ${response.body}');
    // }

    Future<List<ApiListing>> getListings({
      required String token,
      String? type,
      String? city,
      String status = 'active',
      int? bedrooms,
      double? minPrice,
      double? maxPrice,
      int page = 1,
      int perPage = 20,
    }) async {
      final queryParams = {
        'status': status,
        'page': page.toString(),
        'per_page': perPage.toString(),
        if (type != null) 'type': type,
        if (city != null) 'city': city,
        if (bedrooms != null) 'bedrooms': bedrooms.toString(),
        if (minPrice != null) 'min_price': minPrice.toString(),
        if (maxPrice != null) 'max_price': maxPrice.toString(),
      };

      final uri = Uri.parse('$baseUrl/listings')
          .replace(queryParameters: queryParams);
      final response = await _client.get(uri, headers: _headers(token));

      if (response.statusCode == 200) {
        final body = json.decode(response.body) as Map<String, dynamic>;
        return (body['data'] as List).map((e) => ApiListing.fromJson(e)).toList();
      }

      throw Exception('getListings ${response.statusCode}: ${response.body}');
    }

    Future<ApiListing> getListing(String id, {required String token}) async {
      final response = await _client.get(
          Uri.parse('$baseUrl/listings/$id'), headers: _headers(token));
      if (response.statusCode == 200) {
        return ApiListing.fromJson(
            _unwrap(json.decode(response.body) as Map<String, dynamic>));
      }
      throw Exception('getListing ${response.statusCode}: ${response.body}');
    }

    Future<ApiListing> createListing(ApiListing listing,
        {required String token}) async {
      final response = await _client.post(
        Uri.parse('$baseUrl/listings'),
        headers: _headers(token),
        body: json.encode({'listing': listing.toJson()}),
      );
      if (response.statusCode == 201) {
        return ApiListing.fromJson(
            _unwrap(json.decode(response.body) as Map<String, dynamic>));
      }
      throw Exception('createListing ${response.statusCode}: ${response.body}');
    }

    Future<ApiListing> updateListing(ApiListing listing,
        {required String token}) async {
      final response = await _client.patch(
        Uri.parse('$baseUrl/listings/${listing.id}'),
        headers: _headers(token),
        body: json.encode({'listing': listing.toJson()}),
      );
      if (response.statusCode == 200) {
        return ApiListing.fromJson(
            _unwrap(json.decode(response.body) as Map<String, dynamic>));
      }
      throw Exception('updateListing ${response.statusCode}: ${response.body}');
    }

    Future<void> deleteListing(String id, {required String token}) async {
      final response = await _client.delete(
          Uri.parse('$baseUrl/listings/$id'), headers: _headers(token));
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('deleteListing ${response.statusCode}: ${response.body}');
      }
    }

    Future<void> markListingRented(String id, {required String token}) async {
      final response = await _client.patch(
          Uri.parse('$baseUrl/listings/$id/mark_rented'),
          headers: _headers(token));
      if (response.statusCode != 200) {
        throw Exception(
            'markListingRented ${response.statusCode}: ${response.body}');
      }
    }

    Future<Map<String, dynamic>> addListingPhotoUrl({
      required String listingId,
      required String photoUrl,
      required String token,
      int position = 0,
    }) async {
      final response = await _client.post(
        Uri.parse('$baseUrl/listings/$listingId/photos'),
        headers: _headers(token),
        body: json.encode({
          'photo': {'photo_url': photoUrl, 'position': position}
        }),
      );
      if (response.statusCode == 201) {
        return _unwrap(json.decode(response.body) as Map<String, dynamic>);
      }
      throw Exception('addPhoto ${response.statusCode}: ${response.body}');
    }

    Future<void> uploadListingPhoto({
    required String listingId, 
    required String imagePath, 
    required String token, 
  }) async {
    try {
      final File imageFile = File(imagePath);
      
      if (!await imageFile.exists()) {
        throw Exception('File does not exist: $imagePath');
      }
      
      final uri = Uri.parse('$baseUrl/listings/$listingId/photos');
      final request = http.MultipartRequest('POST', uri);
      
      request.headers.addAll(_multipartHeaders(token));
      
      final multipartFile = await http.MultipartFile.fromPath(
        'photo',
        imagePath,
        filename: imagePath.split('/').last,
      );
      
      request.files.add(multipartFile);
      
      final response = await request.send();
      
      if (response.statusCode != 201 && response.statusCode != 200) {
        final responseBody = await response.stream.bytesToString();
        throw Exception('Failed to upload photo: ${response.statusCode} - $responseBody');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

    Future<void> deleteListingPhoto({
      required String listingId,
      required String photoId,
      required String token,
    }) async {
      final response = await _client.delete(
          Uri.parse('$baseUrl/listings/$listingId/photos/$photoId'),
          headers: _headers(token));
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('deletePhoto ${response.statusCode}: ${response.body}');
      }
    }

    Future<void> patchProfile(
    String path,
    String key,
    Map<String, dynamic> fields, {
    required String token,
  }) async {
    final response = await _client.patch(
      Uri.parse('$baseUrl$path'),
      headers: _headers(token),
      body: json.encode({key: fields}),
    );
 
    if (response.statusCode != 200) {
      final decoded = json.decode(response.body) as Map<String, dynamic>;
      throw Exception('patchProfile $path ${response.statusCode}: ${decoded['error']}');
    }
  }
 
  Future<void> createListingRaw(
    Map<String, dynamic> fields, {
    required String token,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/listings'),
      headers: _headers(token),
      body: json.encode({'listing': fields}),
    );
 
    if (response.statusCode != 201 && response.statusCode != 200) {
      final decoded = json.decode(response.body) as Map<String, dynamic>;
      throw Exception('createListingRaw ${response.statusCode}: ${decoded['error']}');
    }
  }
 
  Future<LandlordProfile> updateProfile(
  Map<String, dynamic> fields, {
  required String token,
}) async {
  final response = await _client.patch(
    Uri.parse('$baseUrl/profile'),
    headers: _headers(token),
    body: json.encode({'user': fields}),
  );

  if (response.statusCode == 200) {
    final body = json.decode(response.body) as Map<String, dynamic>;
    return LandlordProfile.fromJson(_unwrap(body)); // ¡Usa tu modelo!
  }

  throw Exception('updateProfile ${response.statusCode}: ${response.body}');
}

}