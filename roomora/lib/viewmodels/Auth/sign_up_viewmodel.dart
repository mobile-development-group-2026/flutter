import 'package:flutter/foundation.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:clerk_auth/clerk_auth.dart' as clerk;

class SignUpViewModel extends ChangeNotifier {
  String firstName = '';
  String lastName = '';
  String email = '';
  String phone = '';
  String password = '';
  String role = 'student';
  bool agreedToTerms = false;
  bool isLoading = false;
  bool isVerifying = false; 
  String? errorMessage;

  String get buttonTitle {
    if (isLoading) return 'Cargando...';
    return role == 'landlord' ? 'Crear cuenta landlord' : 'Crear cuenta';
  }

  void setRole(String r) {
    role = r;
    notifyListeners();
  }

  Future<void> signUp(ClerkAuthState auth) async {
    if (!agreedToTerms) {
      errorMessage = 'Aceptá los Términos y Condiciones para continuar.';
      notifyListeners();
      return;
    }
    if (password.length < 8) {
      errorMessage = 'La contraseña debe tener al menos 8 caracteres.';
      notifyListeners();
      return;
    }
    if (firstName.trim().isEmpty || lastName.trim().isEmpty) {
      errorMessage = 'Completá tu nombre y apellido.';
      notifyListeners();
      return;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await auth.attemptSignUp(
        strategy: clerk.Strategy.emailCode,
        emailAddress: email,
        password: password,
        passwordConfirmation: password,
        firstName: firstName,
        lastName: lastName,
      );
      isVerifying = true;
    } catch (e) {
      debugPrint('[SignUp] failed: $e');
      errorMessage = _friendlyError(e);
    }

    isLoading = false;
    notifyListeners();
  }

  String _friendlyError(Object e) {
    final msg = e.toString().toLowerCase();
    if (msg.contains('email') && msg.contains('exist')) {
      return 'Este email ya está registrado.';
    }
    if (msg.contains('password')) return 'La contraseña no cumple los requisitos.';
    if (msg.contains('network') || msg.contains('socket')) {
      return 'Sin conexión. Revisá tu internet.';
    }
    return 'Algo salió mal. Intentá de nuevo.';
  }
}
