import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/saved_listing.dart';

class SavedListingsService {
  static const String baseUrl = 'http://10.0.2.2:3000/api/v1';
  
  final http.Client _client = http.Client();

  Future<Map<String, String>> _getHeaders(String studentId) async {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-Dev-Clerk-Id': studentId,
    };
  }

  Future<List<SavedListing>> getSavedListings(String studentId) async {
    try {
      final headers = await _getHeaders(studentId);
      final response = await _client.get(
        Uri.parse('$baseUrl/students/$studentId/saved_listings'),
        headers: headers,
      );

      print('SavedListings response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => SavedListing.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load saved listings: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting saved listings: $e');
      rethrow;
    }
  }

  Future<SavedListing> markListingAsVisited(String studentId, String listingId) async {
    try {
      final headers = await _getHeaders(studentId);
      final response = await _client.patch(
        Uri.parse('$baseUrl/students/$studentId/saved_listings/$listingId/visit'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return SavedListing.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to mark listing as visited: ${response.statusCode}');
      }
    } catch (e) {
      print('Error marking listing as visited: $e');
      rethrow;
    }
  }

  Future<void> updateNotificationDistance(String studentId, String listingId, double distance) async {
    try {
      final headers = await _getHeaders(studentId);
      await _client.patch(
        Uri.parse('$baseUrl/students/$studentId/saved_listings/$listingId/distance'),
        headers: headers,
        body: json.encode({'distance': distance}),
      );
    } catch (e) {
      print('Error updating distance: $e');
      rethrow;
    }
  }
}