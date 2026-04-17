import 'package:clerk_auth/clerk_auth.dart';
import 'api_service.dart';
import '../services/models/api_profile.dart';

extension ApiServiceAuth on ApiService {
  
  Future<ApiProfile> syncUser({
    required Auth clerkAuth,
    required String firstName,
    required String lastName,
    required String email,
    required String role,
    String? phone,
  }) async {
    final body = {
      'user': {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'role': role,
        if (phone != null) 'phone': phone,
      }
    };
    final data = await request('POST', '/auth/sync', clerkAuth, body: body);
    return ApiProfile.fromJson(data);
  }

  Future<ApiProfile> getProfile(Auth clerkAuth) async {
    final data = await request('GET', '/profile', clerkAuth);
    return ApiProfile.fromJson(data);
  }

  Future<ApiProfile> updateProfile(Auth clerkAuth, ApiProfile profile) async {
    final data = await request('PATCH', '/profile', clerkAuth, body: {'user': profile.toJson()});
    return ApiProfile.fromJson(data);
  }

  Future<ApiProfile> markOnboarded(Auth clerkAuth) async {
    final data = await request('PATCH', '/profile', clerkAuth, body: {'user': {'onboarded': true}});
    return ApiProfile.fromJson(data);
  }
}