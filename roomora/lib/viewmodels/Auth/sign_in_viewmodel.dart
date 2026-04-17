import 'package:flutter/material.dart';
import 'package:clerk_auth/clerk_auth.dart';
import '../../state/user_session.dart';

class SignInViewModel extends ChangeNotifier {
  String email = "";
  String password = "";
  bool isLoading = false;
  String? errorMessage;

  String get buttonTitle => isLoading ? "Iniciando sesión..." : "Iniciar Sesión  →";

  Future<bool> signIn(Auth clerkAuth, UserSession session) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await clerkAuth.attemptSignIn(
        strategy: Strategy.password,
        identifier: email,
        password: password,
      );

      session.isLoaded = false;
      session.pendingSync = null;

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