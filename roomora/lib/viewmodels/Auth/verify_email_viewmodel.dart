import 'package:flutter/foundation.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:clerk_auth/clerk_auth.dart' as clerk;
import '/../models/user_session.dart';
import '/../services/api_service.dart';

class VerifyEmailViewModel extends ChangeNotifier {
  String code = '';
  bool isLoading = false;
  String? errorMessage;

  String get buttonTitle => isLoading ? 'Verificando...' : 'Verificar email';

  Future<bool> verify({
    required ClerkAuthState auth,
    required UserSession session,
    required String role,
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await auth.attemptSignUp(
        strategy: clerk.Strategy.emailCode,
        emailAddress: email,
        code: code,
      );

      session.setPendingSync(PendingSync(
        role: role,
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone.isEmpty ? null : phone,
      ));

      await Future.delayed(const Duration(seconds: 1));

      final token = await session.getTokenFromAuth(auth);
      if (token == null) throw Exception('No se pudo obtener el token de sesión');

      final profile = await ApiService().syncUser(
        token: token,
        role: role,
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone.isEmpty ? null : phone,
      );
      session.setLoaded(profile);

      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('[VerifyEmail] failed: $e');
      errorMessage = _friendlyError(e);
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  String _friendlyError(Object e) {
    final msg = e.toString().toLowerCase();
    if (msg.contains('code') || msg.contains('verification')) {
      return 'Código incorrecto. Revisá el email y volvé a intentar.';
    }
    if (msg.contains('expired')) return 'El código expiró. Solicitá uno nuevo.';
    if (msg.contains('network') || msg.contains('socket')) {
      return 'Sin conexión. Revisá tu internet.';
    }
    return 'Algo salió mal. Intentá de nuevo.';
  }
}
