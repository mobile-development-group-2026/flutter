import 'package:flutter/foundation.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import '../models/landlord_profile.dart';
import '../services/api_service.dart';



class UserSession extends ChangeNotifier {
  LandlordProfile? profile;
  bool isLoaded = false;
  PendingSync? pendingSync;

  String? get role => profile?.role;
  bool get isOnboarded => profile != null;

  Future<void> load(ClerkAuthState auth) async {
    if (isLoaded) return;

    for (int attempt = 1; attempt <= 3; attempt++) {
      await Future.delayed(Duration(seconds: attempt == 1 ? 1 : 2));

      try {
        final token = await _getToken(auth);
        if (token == null) continue;

        if (pendingSync != null) {
          final sync = pendingSync!;
          profile = await ApiService().syncUser(
            token: token,
            role: sync.role,
            firstName: sync.firstName,
            lastName: sync.lastName,
            email: sync.email,
            phone: sync.phone,
          );
          pendingSync = null;
        } else {
          profile = await ApiService().fetchProfile(token: token);
        }

        break;
      } catch (e) {
        debugPrint('[UserSession] load attempt $attempt failed: $e');
      }
    }

    isLoaded = true;
    notifyListeners();
  }

  void clear() {
    profile = null;
    isLoaded = false;
    pendingSync = null;
    notifyListeners();
  }

  void setPendingSync(PendingSync sync) {
    pendingSync = sync;
    notifyListeners();
  }

  void setLoaded(LandlordProfile p) {
    profile = p;
    isLoaded = true;
    pendingSync = null;
    notifyListeners();
  }

  Future<String?> getTokenFromAuth(ClerkAuthState auth) async {
    try {
      final sessionToken = await auth.sessionToken();
      return sessionToken?.jwt; 
    } catch (_) {
      return null;
    }
  }

  Future<String?> _getToken(ClerkAuthState auth) => getTokenFromAuth(auth);
}

class PendingSync {
  final String role;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;

  const PendingSync({
    required this.role,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
  });
}
