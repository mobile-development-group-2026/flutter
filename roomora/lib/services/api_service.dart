import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:clerk_auth/clerk_auth.dart'; 

class ApiException implements Exception {
  final int? statusCode;
  final String message;
  ApiException(this.message, [this.statusCode]);
  @override
  String toString() => message;
}

class ApiService {
  static final ApiService shared = ApiService._internal();
  ApiService._internal();

  final String _baseUrl = "https://roomora-api.onrender.com/api/v1";
  final http.Client _client = http.Client();

  Future<dynamic> request(
    String method,
    String path,
    Auth clerkAuth, {
    Map<String, dynamic>? body,
  }) async {
    final url = Uri.parse('$_baseUrl$path');
    
    final token = await clerkAuth.sessionToken();

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    http.Response response;

    try {
      switch (method) {
        case 'GET':
          response = await _client.get(url, headers: headers);
          break;
        case 'POST':
          response = await _client.post(url, headers: headers, body: jsonEncode(body));
          break;
        case 'PATCH':
          response = await _client.patch(url, headers: headers, body: jsonEncode(body));
          break;
        case 'DELETE':
          response = await _client.delete(url, headers: headers);
          break;
        default:
          throw ApiException('Método no soportado');
      }
    } catch (e) {
      throw ApiException('Error de conexión: $e');
    }

    return _handleResponse(response);
  }

  Future<dynamic> uploadFile(
    String path,
    String fieldName,
    String filePath,
    Auth clerkAuth,
  ) async {
    final url = Uri.parse('$_baseUrl$path');
    final token = await clerkAuth.sessionToken();

    var request = http.MultipartRequest('POST', url);
    
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    
    request.files.add(await http.MultipartFile.fromPath(fieldName, filePath));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    return _handleResponse(response);
  }

  dynamic _handleResponse(http.Response response) {
    final decoded = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode <= 299) {
      return decoded.containsKey('data') ? decoded['data'] : decoded;
    } else {
      throw ApiException(decoded['error'] ?? 'Error del servidor', response.statusCode);
    }
  }
}