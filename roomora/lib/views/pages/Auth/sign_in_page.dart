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
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
              ),
            ),
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 12, // Reducido para dar espacio a la "pestaña" gris
              bottom: MediaQuery.of(context).viewInsets.bottom + 32,
            ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Sora',
                        letterSpacing: -0.5,
                      ),
                      children: [
                        TextSpan(
                          text: 'Welcome ',
                          style: TextStyle(color: AppColors.neutral900),
                        ),
                        TextSpan(
                          text: 'back',
                          style: TextStyle(color: AppColors.purple500),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Sign in to continue finding your perfect place.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.neutral700,
                      fontFamily: 'Sora',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      SizedBox(
                        width: 72,
                        height: 28,
                        child: Stack(
                          children: [
                            const _AvatarBubble(label: 'M', left: 0),
                            const _AvatarBubble(label: 'L', left: 20),
                            Positioned(
                              left: 40,
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: AppColors.purple400,
                                  shape: BoxShape.circle,
                                  border:
                                      Border.all(color: Colors.white, width: 2),
                                ),
                                child: const Center(
                                  child: Text(
                                    '+',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'Sora',
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      RichText(
                        text: const TextSpan(
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'Sora',
                            color: AppColors.neutral700,
                          ),
                          children: [
                            TextSpan(
                              text: '2,400+ students ',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.neutral900,
                              ),
                            ),
                            TextSpan(
                              text: 'found housing\nthrough Roomora this semester',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _InputField(
                    controller: _emailCtrl,
                    label: 'EMAIL ADDRESS',
                    hint: 'you@university.edu',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (v) => _vm.email = v,
                  ),
                  const SizedBox(height: 16),
                  _InputField(
                    controller: _passCtrl,
                    label: 'PASSWORD',
                    hint: 'Enter your password',
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
                      onPressed: () {},
                      child: const Text(
                        'Forgot password?',
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
                                fontFamily: 'Sora',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  _vm.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: AppColors.purple500))
                      : _SignInButton(
                          text: _vm.buttonTitle,
                          onPressed: () async {
                            final ok = await _vm.signIn(auth, session);
                            if (ok && context.mounted) {
                              Navigator.of(context).pop();
                            }
                          },
                        ),
                  const SizedBox(height: 20),
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Don't have an account? ",
                          style: TextStyle(
                            color: AppColors.neutral700,
                            fontSize: 13,
                            fontFamily: 'Sora',
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: const Text(
                            'Sign up free',
                            style: TextStyle(
                              color: AppColors.purple500,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
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
          ],
        );
      },
    );
  }
}
class _AvatarBubble extends StatelessWidget {
  final String label;
  final double left;

  const _AvatarBubble({required this.label, required this.left});

  static const _colors = [
    Color(0xFF7B5BF2),
    Color(0xFF9E82F7),
    Color(0xFF4B31A8),
  ];

  @override
  Widget build(BuildContext context) {
    final idx = label.codeUnitAt(0) % _colors.length;
    return Positioned(
      left: left,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: _colors[idx],
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              fontFamily: 'Sora',
            ),
          ),
        ),
      ),
    );
  }
}

class _SignInButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const _SignInButton({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8B6FF5), Color(0xFF5535C4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.purple500.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Sora',
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
            ],
          ),
        ),
      ),
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
            fontSize: 14,
            color: AppColors.neutral900,
            fontFamily: 'Sora',
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: AppColors.neutral600,
              fontSize: 14,
              fontFamily: 'Sora',
            ),
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