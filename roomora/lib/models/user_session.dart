import 'package:flutter/material.dart';
import 'package:clerk_auth/clerk_auth.dart';
import '../services/models/api_profile.dart';
import '../models/user_role.dart';
import '../services/api_service.dart';
import '../services/api_service_auth.dart';

class UserSession extends ChangeNotifier {
  ApiProfile? profile;
  bool isLoaded = false;
  PendingSync? pendingSync;

  String? get role => profile?.role;
  String? get firstName => profile?.firstName;
  bool get isOnboarded => profile?.onboarded ?? false;

  Future<void> load(Auth clerkAuth) async {
    if (isLoaded) return;

    for (int attempt = 1; attempt <= 3; attempt++) {
      await Future.delayed(Duration(seconds: attempt == 1 ? 1 : 2));

      try {
        if (pendingSync != null) {
          profile = await ApiService.shared.syncUser(
            clerkAuth: clerkAuth,
            role: pendingSync!.role,
            firstName: pendingSync!.firstName,
            lastName: pendingSync!.lastName,
            email: pendingSync!.email,
            phone: pendingSync!.phone,
          );
          pendingSync = null;
        } else {
          profile = await ApiService.shared.getProfile(clerkAuth);
        }
        
        isLoaded = true;
        notifyListeners();
        return;
      } catch (e) {
        debugPrint("Intento de carga $attempt fallido: $e");
        if (attempt == 3) {
          debugPrint("Todos los intentos de carga de sesión fallaron.");
        }
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
}

class PendingSync {
  final String role;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;

  PendingSync({
    required this.role,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
  });
}