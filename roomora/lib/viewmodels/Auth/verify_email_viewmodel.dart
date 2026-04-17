import 'package:flutter/material.dart';
import 'package:clerk_auth/clerk_auth.dart';
import '../../state/user_session.dart';
import '../../models/user_role.dart';

class VerifyEmailViewModel extends ChangeNotifier {
  String code = "";
  bool isLoading = false;
  String? errorMessage;

  Future<bool> verify({
    required Auth clerkAuth,
    required UserSession session,
    required UserRole role,
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await clerkAuth.attemptSignUp(
        strategy: Strategy.emailCode,
        code: code,
      );

      session.pendingSync = PendingSync(
        role: role.value,
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone.isEmpty ? null : phone,
      );

      await session.load(clerkAuth);

      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }
}