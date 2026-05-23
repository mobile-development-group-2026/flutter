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
    if (isLoading) return 'Loading...';
    return role == 'landlord' ? 'Create Landlord Account' : 'Create Account';
  }

  void setRole(String r) {
    role = r;
    notifyListeners();
  }

  Future<void> signUp(ClerkAuthState auth) async {
    if (!agreedToTerms) {
      errorMessage = 'Please accept the Terms and Conditions to continue.';
      notifyListeners();
      return;
    }
    if (password.length < 8) {
      errorMessage = 'Password must be at least 8 characters.';
      notifyListeners();
      return;
    }
    if (firstName.trim().isEmpty || lastName.trim().isEmpty) {
      errorMessage = 'Please enter your first and last name.';
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
      return 'This email is already registered.';
    }
    if (msg.contains('password')) return 'Password does not meet requirements.';
    if (msg.contains('network') || msg.contains('socket')) {
      return 'No internet connection. Please check your network.';
    }
    return 'Something went wrong. Please try again.';
  }
}