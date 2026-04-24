import 'package:flutter/foundation.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:clerk_auth/clerk_auth.dart';
import '/../models/user_session.dart';

class SignInViewModel extends ChangeNotifier {
  String email = '';
  String password = '';
  bool isLoading = false;
  String? errorMessage;

  String get buttonTitle => isLoading ? 'Signing in...' : 'Sign In';

  Future<bool> signIn(ClerkAuthState auth, UserSession session) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await auth.attemptSignIn(
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
      debugPrint('[SignIn] failed: $e');
      errorMessage = _friendlyError(e);
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  String _friendlyError(Object e) {
    final msg = e.toString().toLowerCase();
    if (msg.contains('password') || msg.contains('identifier')) {
      return 'Email o contraseña incorrectos.';
    }
    if (msg.contains('network') || msg.contains('socket')) {
      return 'Sin conexión. Revisá tu internet.';
    }
    return 'Algo salió mal. Intentá de nuevo.';
  }
}
