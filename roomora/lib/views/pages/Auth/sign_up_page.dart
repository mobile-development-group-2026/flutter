import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import '/../../theme/colors.dart';
import '/../../viewmodels/Auth/sign_up_viewmodel.dart';
import '../../widgets/custom_button.dart';
import 'verify_email_page.dart';
import 'sign_in_page.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final _vm = SignUpViewModel();
  final _firstCtrl = TextEditingController();
  final _lastCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _navigating = false;

  @override
  void dispose() {
    _firstCtrl.dispose();
    _lastCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ClerkAuth.of(context);

    return ListenableBuilder(
      listenable: _vm,
      builder: (context, _) {
        if (_vm.isVerifying && !_navigating) {
          _navigating = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!context.mounted) return;
            Navigator.of(context)
                .push(MaterialPageRoute(
                  builder: (_) => VerifyEmailView(
                    email: _vm.email,
                    role: _vm.role,
                    firstName: _vm.firstName,
                    lastName: _vm.lastName,
                    phone: _vm.phone,
                  ),
                ))
                .then((_) => _navigating = false);
          });
        }

        return Scaffold(
          backgroundColor: AppColors.neutral100,
          appBar: AppBar(
            backgroundColor: AppColors.neutral100,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.neutral900),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: const Text(
              'Crear cuenta',
              style: TextStyle(
                color: AppColors.neutral900,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                fontFamily: 'Sora',
              ),
            ),
            centerTitle: true,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                        fontFamily: 'Sora',
                      ),
                      children: [
                        TextSpan(
                            text: 'Encontrá tu\n',
                            style: TextStyle(color: AppColors.neutral900)),
                        TextSpan(
                            text: 'lugar perfecto',
                            style: TextStyle(color: AppColors.purple500)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Creá tu cuenta gratis para empezar.',
                    style: TextStyle(
                        color: AppColors.neutral700,
                        fontSize: 14,
                        fontFamily: 'Sora'),
                  ),
                  const SizedBox(height: 24),

                  // Role picker
                  Row(
                    children: [
                      _RoleChip(
                        label: 'Estudiante',
                        selected: _vm.role == 'student',
                        onTap: () => _vm.setRole('student'),
                      ),
                      const SizedBox(width: 12),
                      _RoleChip(
                        label: 'Propietario',
                        selected: _vm.role == 'landlord',
                        onTap: () => _vm.setRole('landlord'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Nombre y apellido
                  Row(
                    children: [
                      Expanded(
                        child: _AuthField(
                          controller: _firstCtrl,
                          label: 'NOMBRE',
                          hint: 'Ana',
                          onChanged: (v) => _vm.firstName = v,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _AuthField(
                          controller: _lastCtrl,
                          label: 'APELLIDO',
                          hint: 'García',
                          onChanged: (v) => _vm.lastName = v,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _AuthField(
                    controller: _emailCtrl,
                    label: 'EMAIL',
                    hint: 'vos@universidad.edu',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (v) => _vm.email = v,
                  ),
                  const SizedBox(height: 16),

                  _AuthField(
                    controller: _phoneCtrl,
                    label: 'TELÉFONO (opcional)',
                    hint: '+57 300 000 0000',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    onChanged: (v) => _vm.phone = v,
                  ),
                  const SizedBox(height: 16),

                  _AuthField(
                    controller: _passCtrl,
                    label: 'CONTRASEÑA',
                    hint: 'Mínimo 8 caracteres',
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
                  const SizedBox(height: 16),

                  // Terms
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: _vm.agreedToTerms,
                        activeColor: AppColors.purple500,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4)),
                        onChanged: (v) {
                          _vm.agreedToTerms = v ?? false;
                          _vm.notifyListeners();
                        },
                      ),
                      const Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(top: 12),
                          child: Text(
                            'Acepto los Términos de Servicio y la Política de Privacidad',
                            style: TextStyle(
                                fontSize: 13,
                                color: AppColors.neutral700,
                                fontFamily: 'Sora'),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Error
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

                  // Botón
                  _vm.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: AppColors.purple500))
                      : CustomButton(
                          text: _vm.buttonTitle,
                          onPressed: () => _vm.signUp(auth),
                        ),
                  const SizedBox(height: 16),

                  // Sign in link
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          '¿Ya tenés cuenta?',
                          style: TextStyle(
                              color: AppColors.neutral700,
                              fontSize: 14,
                              fontFamily: 'Sora'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text(
                            'Iniciá sesión',
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
            ),
          ),
        );
      },
    );
  }
}

class _RoleChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RoleChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.purple500 : AppColors.neutral300,
          borderRadius: BorderRadius.circular(12),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.purple500.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.neutral800,
            fontWeight: FontWeight.w600,
            fontSize: 14,
            fontFamily: 'Sora',
          ),
        ),
      ),
    );
  }
}

class _AuthField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData? icon;
  final bool obscure;
  final TextInputType keyboardType;
  final void Function(String) onChanged;
  final Widget? suffix;

  const _AuthField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.onChanged,
    this.icon,
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
            prefixIcon: icon != null
                ? Icon(icon, color: AppColors.neutral600, size: 18)
                : null,
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
