import 'package:flutter/material.dart';
import 'package:clerk_auth/clerk_auth.dart';
import '../../models/user_role.dart';

class SignUpViewModel extends ChangeNotifier {
  String firstName = "";
  String lastName = "";
  String email = "";
  String phone = "";
  String password = "";
  UserRole role = UserRole.student;
  bool agreedToTerms = false;
  bool isVerifying = false;
  bool isLoading = false;
  String? errorMessage;

  String get buttonTitle {
    if (isLoading) return "Cargando...";
    return role == UserRole.landlord ? "Crear Cuenta de Arrendador" : "Crear Cuenta";
  }

  Future<void> signUp(Auth clerkAuth) async {
    if (!agreedToTerms) {
      errorMessage = "Por favor, acepta los Términos de Servicio.";
      notifyListeners();
      return;
    }
    if (password.length < 8) {
      errorMessage = "La contraseña debe tener al menos 8 caracteres.";
      notifyListeners();
      return;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await clerkAuth.attemptSignUp(
        strategy: Strategy.emailCode,
        emailAddress: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
      );
      
      isVerifying = true;
    } catch (e) {
      errorMessage = e.toString();
    }
    
    isLoading = false;
    notifyListeners();
  }
}