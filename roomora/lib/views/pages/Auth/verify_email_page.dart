import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import '/../../theme/colors.dart';
import '/../../models/user_session.dart';
import '/../../viewmodels/Auth/verify_email_viewmodel.dart';
import '../../widgets/custom_button.dart';
import '../Onboarding/onboarding_page.dart';

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

  // 6 controllers + focus nodes, uno por caja
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  late Timer _timer;
  int _secondsLeft = 600;
  bool _codeSent = false; // snackbar "Code resent"

  String get _timerLabel {
    final m = (_secondsLeft ~/ 60).toString().padLeft(1, '0');
    final s = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      if (_secondsLeft > 0) {
        setState(() => _secondsLeft--);
      } else {
        t.cancel();
      }
    });
  }

  void _onBoxChanged(String value, int index) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    final code = _controllers.map((c) => c.text).join();
    _vm.code = code;

    if (code.length == 6) {
      _focusNodes[index].unfocus();
      _submit();
    }
  }

  void _onBoxKeyDown(RawKeyEvent event, int index) {
    if (event.logicalKey.keyLabel == 'Backspace' &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  Future<void> _submit() async {
    final auth = ClerkAuth.of(context);
    final session = context.read<UserSession>();

    final ok = await _vm.verify(
      auth: auth,
      session: session,
      role: widget.role,
      firstName: widget.firstName,
      lastName: widget.lastName,
      email: widget.email,
      phone: widget.phone,
    );

    if (!mounted) return;

    if (ok) {
      // Navegar al onboarding reemplazando toda la pila de auth
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const OnboardingView()),
        (route) => route.isFirst,
      );
    }
  }

  Future<void> _resendCode() async {
    if (_secondsLeft > 540) return;

    setState(() {
      _secondsLeft = 600;
      _codeSent = true;
    });
    _timer.cancel();
    _startTimer();

    // Mostrar snackbar "Code resent"
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF1C1C1E),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        duration: const Duration(seconds: 3),
        content: Row(
          children: const [
            CircleAvatar(
              radius: 12,
              backgroundColor: AppColors.green500,
              child: Icon(Icons.check, color: Colors.white, size: 14),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Code resent',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        fontFamily: 'Sora')),
                Text('Check your inbox',
                    style: TextStyle(
                        color: Color(0xFF8E8E93),
                        fontSize: 12,
                        fontFamily: 'Sora')),
              ],
            ),
          ],
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _codeSent = false);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    for (final c in _controllers) { c.dispose(); }
    for (final f in _focusNodes) { f.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _vm,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.chevron_left,
                  color: AppColors.neutral900, size: 28),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),

                  // ── Ilustración de sobre
                  _EmailIllustration(),
                  const SizedBox(height: 28),

                  // ── Título
                  RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                      style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Sora',
                          color: AppColors.neutral900),
                      children: [
                        TextSpan(text: 'Check your '),
                        TextSpan(
                            text: 'email',
                            style: TextStyle(color: AppColors.purple500)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── Email badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.neutral200,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircleAvatar(
                          radius: 12,
                          backgroundColor: AppColors.purple500,
                          child: Icon(Icons.email_outlined,
                              color: Colors.white, size: 12),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.email,
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.neutral900,
                              fontFamily: 'Sora'),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: const Text(
                            'Edit',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.purple500,
                                fontFamily: 'Sora'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── Subtítulo
                  RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                      style: TextStyle(
                          fontSize: 13,
                          color: AppColors.neutral700,
                          fontFamily: 'Sora'),
                      children: [
                        TextSpan(text: 'We sent a 6-digit code. '),
                        TextSpan(
                          text: 'Expires in 10 minutes.',
                          style: TextStyle(fontWeight: FontWeight.w600,
                              color: AppColors.neutral900),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── Label del campo
                  const Text(
                    'ENTER YOUR CODE',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.neutral700,
                        letterSpacing: 0.8,
                        fontFamily: 'Sora'),
                  ),
                  const SizedBox(height: 12),

                  // ── 6 cajas de código
                  _CodeBoxes(
                    controllers: _controllers,
                    focusNodes: _focusNodes,
                    hasError: _vm.errorMessage != null,
                    onChanged: _onBoxChanged,
                    onKeyDown: _onBoxKeyDown,
                  ),
                  const SizedBox(height: 16),

                  // ── Error
                  if (_vm.errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: AppColors.red100,
                          borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline,
                              color: AppColors.red500, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(_vm.errorMessage!,
                                style: const TextStyle(
                                    color: AppColors.red500,
                                    fontSize: 13,
                                    fontFamily: 'Sora')),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // ── Didn't get it? Resend + countdown
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Didn't get it? ",
                          style: TextStyle(
                              fontSize: 13,
                              color: AppColors.neutral700,
                              fontFamily: 'Sora')),
                      GestureDetector(
                        onTap: _resendCode,
                        child: const Text(
                          'Resend',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.purple500,
                              fontFamily: 'Sora'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.neutral200,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time,
                                size: 12, color: AppColors.neutral700),
                            const SizedBox(width: 4),
                            Text(
                              _timerLabel,
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.neutral700,
                                  fontFamily: 'Sora',
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // ── Botón principal
                  _vm.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: AppColors.purple500))
                      : CustomButton(
                          text: _vm.buttonTitle,
                          onPressed: _submit,
                        ),
                  const SizedBox(height: 12),

                  // ── Links de ayuda
                  Column(
                    children: [
                      const Text(
                        "Check your spam folder if you don't see it.",
                        style: TextStyle(
                            fontSize: 12,
                            color: AppColors.neutral600,
                            fontFamily: 'Sora'),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: const Text(
                          'Use a different email',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.purple500,
                              fontFamily: 'Sora'),
                        ),
                      ),
                    ],
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

class _CodeBoxes extends StatelessWidget {
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final bool hasError;
  final void Function(String value, int index) onChanged;
  final void Function(RawKeyEvent event, int index) onKeyDown;

  const _CodeBoxes({
    required this.controllers,
    required this.focusNodes,
    required this.hasError,
    required this.onChanged,
    required this.onKeyDown,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (i) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: RawKeyboardListener(
            focusNode: FocusNode(),
            onKey: (e) => onKeyDown(e, i),
            child: SizedBox(
              width: 44,
              height: 52,
              child: TextField(
                controller: controllers[i],
                focusNode: focusNodes[i],
                textAlign: TextAlign.center,
                maxLength: 1,
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.neutral900,
                  fontFamily: 'Sora',
                ),
                decoration: InputDecoration(
                  counterText: '',
                  filled: true,
                  fillColor: focusNodes[i].hasFocus
                      ? AppColors.purple100
                      : AppColors.neutral200,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: hasError
                          ? AppColors.red500
                          : AppColors.purple500,
                      width: 2,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: hasError
                          ? AppColors.red300
                          : Colors.transparent,
                      width: hasError ? 1.5 : 0,
                    ),
                  ),
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (v) {
                  // Si pegan 6 dígitos de una, distribuirlos
                  if (v.length > 1) {
                    final digits = v.replaceAll(RegExp(r'\D'), '');
                    for (int j = 0; j < 6 && j < digits.length; j++) {
                      controllers[j].text = digits[j];
                    }
                    onChanged(digits, digits.length - 1);
                    return;
                  }
                  onChanged(v, i);
                },
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _EmailIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 110,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Fondo difuminado
          Container(
            width: 120,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.purple100,
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          // Sobre
          Container(
            width: 80,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.purple500.withOpacity(0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Líneas de "texto" en el sobre
                Container(height: 4, width: 48,
                    decoration: BoxDecoration(
                        color: AppColors.neutral300,
                        borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 5),
                Container(height: 4, width: 36,
                    decoration: BoxDecoration(
                        color: AppColors.neutral300,
                        borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 5),
                Container(height: 4, width: 42,
                    decoration: BoxDecoration(
                        color: AppColors.neutral300,
                        borderRadius: BorderRadius.circular(2))),
              ],
            ),
          ),
          // Check badge verde
          Positioned(
            right: 8,
            top: 4,
            child: Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: Color(0xFF34C759),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check,
                  color: Colors.white, size: 16),
            ),
          ),
          // Ícono de email dentro del sobre
          Positioned(
            left: 22,
            top: 22,
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: AppColors.purple500,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.email_outlined,
                  color: Colors.white, size: 14),
            ),
          ),
        ],
      ),
    );
  }
}