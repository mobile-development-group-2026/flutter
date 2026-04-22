import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import '/../../theme/colors.dart';
import '/../../models/user_session.dart';
import '/../../viewmodels/Auth/verify_email_viewmodel.dart';
import '../../widgets/custom_button.dart';

class VerifyEmailView extends StatefulWidget {
  final String email;
  final String role;
  final String firstName;
  final String lastName;
  final String phone;

  const VerifyEmailView({
    super.key,
    required this.email,
    required this.role,
    required this.firstName,
    required this.lastName,
    required this.phone,
  });

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  final _vm = VerifyEmailViewModel();
  final _codeCtrl = TextEditingController();

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ClerkAuth.of(context);
    final session = context.read<UserSession>();

    return ListenableBuilder(
      listenable: _vm,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.neutral100,
          appBar: AppBar(
            backgroundColor: AppColors.neutral100,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.neutral900),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  const Text(
                    'Verificá tu',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: AppColors.neutral900,
                      fontFamily: 'Sora',
                      letterSpacing: -0.5,
                    ),
                  ),
                  const Text(
                    'email',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: AppColors.purple500,
                      fontFamily: 'Sora',
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.neutral700,
                          fontFamily: 'Sora'),
                      children: [
                        const TextSpan(text: 'Ingresá el código enviado a '),
                        TextSpan(
                          text: widget.email,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.neutral900),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Código
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'CÓDIGO DE VERIFICACIÓN',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.neutral700,
                          letterSpacing: 0.8,
                          fontFamily: 'Sora',
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _codeCtrl,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 6,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 8,
                          color: AppColors.neutral900,
                          fontFamily: 'Sora',
                        ),
                        decoration: InputDecoration(
                          hintText: '------',
                          hintStyle: TextStyle(
                            color: AppColors.neutral500,
                            fontSize: 22,
                            letterSpacing: 8,
                          ),
                          counterText: '',
                          filled: true,
                          fillColor: AppColors.neutral200,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: AppColors.purple500, width: 1.5),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 18),
                        ),
                        onChanged: (v) => _vm.code = v,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

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

                  const Spacer(),

                  // Botón
                  _vm.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: AppColors.purple500))
                      : CustomButton(
                          text: _vm.buttonTitle,
                          onPressed: () async {
                            final ok = await _vm.verify(
                              auth: auth,
                              session: session,
                              role: widget.role,
                              firstName: widget.firstName,
                              lastName: widget.lastName,
                              email: widget.email,
                              phone: widget.phone,
                            );
                            if (ok && context.mounted) {
                              Navigator.of(context)
                                  .popUntil((r) => r.isFirst);
                            }
                          },
                        ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
