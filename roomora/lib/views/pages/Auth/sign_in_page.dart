import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import '/../../theme/colors.dart';
import '/../../models/user_session.dart';
import '/../viewmodels/Auth/sign_in_viewmodel.dart';
import '../../widgets/custom_button.dart';


class SignInView extends StatefulWidget {
  const SignInView({super.key});

  @override
  State<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  final _vm = SignInViewModel();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ClerkAuth.of(context);
    final session = context.read<UserSession>();

    return ListenableBuilder(
      listenable: _vm,
      builder: (context, _) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 32,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.neutral400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              RichText(
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Sora',
                    letterSpacing: -0.5,
                  ),
                  children: [
                    TextSpan(
                        text: 'Bienvenido ',
                        style: TextStyle(color: AppColors.neutral900)),
                    TextSpan(
                        text: 'de vuelta',
                        style: TextStyle(color: AppColors.purple500)),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Ingresá para continuar encontrando tu lugar perfecto.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.neutral700,
                  fontFamily: 'Sora',
                ),
              ),
              const SizedBox(height: 28),

              _InputField(
                controller: _emailCtrl,
                label: 'EMAIL',
                hint: 'vos@universidad.edu',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                onChanged: (v) => _vm.email = v,
              ),
              const SizedBox(height: 16),

              _InputField(
                controller: _passCtrl,
                label: 'CONTRASEÑA',
                hint: 'Ingresá tu contraseña',
                icon: Icons.lock_outline,
                obscure: _obscurePassword,
                onChanged: (v) => _vm.password = v,
                suffix: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.neutral600,
                    size: 20,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {}, // TODO: implement forgot password
                  child: const Text(
                    '¿Olvidaste tu contraseña?',
                    style: TextStyle(
                      color: AppColors.purple500,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Sora',
                    ),
                  ),
                ),
              ),

              
              if (_vm.errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.red100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: AppColors.red500, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _vm.errorMessage!,
                          style: const TextStyle(
                              color: AppColors.red500,
                              fontSize: 13,
                              fontFamily: 'Sora'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              _vm.isLoading
                  ? const Center(child: CircularProgressIndicator(
                      color: AppColors.purple500))
                  : CustomButton(
                      text: _vm.buttonTitle,
                      onPressed: () async {
                        final ok = await _vm.signIn(auth, session);
                        if (ok && context.mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                    ),
              const SizedBox(height: 16),

              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '¿No tenés cuenta?',
                      style: TextStyle(
                          color: AppColors.neutral700,
                          fontSize: 14,
                          fontFamily: 'Sora'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        'Registrate gratis',
                        style: TextStyle(
                          color: AppColors.purple500,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Sora',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool obscure;
  final TextInputType keyboardType;
  final void Function(String) onChanged;
  final Widget? suffix;

  const _InputField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.onChanged,
    this.obscure = false,
    this.keyboardType = TextInputType.text,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.neutral700,
            letterSpacing: 0.8,
            fontFamily: 'Sora',
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          onChanged: onChanged,
          style: const TextStyle(
              fontSize: 14, color: AppColors.neutral900, fontFamily: 'Sora'),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
                color: AppColors.neutral600, fontSize: 14, fontFamily: 'Sora'),
            prefixIcon: Icon(icon, color: AppColors.neutral600, size: 18),
            suffixIcon: suffix,
            filled: true,
            fillColor: AppColors.neutral200,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.purple500, width: 1.5),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}
