import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:clerk_auth/clerk_auth.dart';
import '/../theme/colors.dart';
import '/../models/user_role.dart';
import '/../state/user_session.dart';
import '/../viewmodels/Auth/verify_email_viewmodel.dart';

class VerifyEmailPage extends StatefulWidget {
  final UserRole role;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final int totalSteps;
  final int currentStep;

  VerifyEmailPage({
    super.key,
    required this.role,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    this.totalSteps = 4,
    this.currentStep = 2,
  });

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> with TickerProviderStateMixin {
  static const _codeLength = 6;
  static const _timerSeconds = 598;

  final VerifyEmailViewModel _viewModel = VerifyEmailViewModel();

  final List<TextEditingController> _controllers = List.generate(_codeLength, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(_codeLength, (_) => FocusNode());

  late int _secondsLeft;
  Timer? _timer;

  bool _showResendToast = false;
  late AnimationController _toastAnim;
  late Animation<double> _toastSlide;
  late Animation<double> _toastFade;

  @override
  void initState() {
    super.initState();
    _secondsLeft = _timerSeconds;
    _startTimer();

    _toastAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _toastSlide = Tween<double>(begin: 40, end: 0).animate(
      CurvedAnimation(parent: _toastAnim, curve: Curves.easeOutCubic),
    );
    _toastFade = CurvedAnimation(parent: _toastAnim, curve: Curves.easeOut);
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_secondsLeft > 0) {
        setState(() => _secondsLeft--);
      } else {
        _timer?.cancel();
      }
    });
  }

  String get _timerDisplay {
    final m = _secondsLeft ~/ 60;
    final s = _secondsLeft % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  String get _fullCode => _controllers.map((c) => c.text).join();

  void _onDigitChanged(int index, String value) {
    if (value.length == 1 && index < _codeLength - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    setState(() {});
  }

  void _onKeyEvent(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
      _controllers[index - 1].clear();
      setState(() {});
    }
  }

  void _resendCode() async {
    setState(() {
      _secondsLeft = _timerSeconds;
      _showResendToast = true;
    });
    
    final clerkAuth = ClerkAuth.of(context);
    try {
      await clerkAuth.attemptSignUp(
        strategy: Strategy.emailCode,
        emailAddress: widget.email,
      );
    } catch (_) {}

    _toastAnim.forward().then((_) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          _toastAnim.reverse().then((_) {
            if (mounted) setState(() => _showResendToast = false);
          });
        }
      });
    });
  }

  Future<void> _handleConfirm() async {
    if (_fullCode.length != _codeLength) return;

    _viewModel.code = _fullCode;

    final clerkAuth = ClerkAuth.of(context);
    final userSession = context.read<UserSession>();

    final success = await _viewModel.verify(
      clerkAuth: clerkAuth,
      session: userSession,
      role: widget.role,
      firstName: widget.firstName,
      lastName: widget.lastName,
      email: widget.email,
      phone: widget.phone ?? "",
    );

    if (!context.mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_viewModel.errorMessage ?? 'Verification failed'),
          backgroundColor: Colors.red.shade400,
        ),
      );
      return;
    }

    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _toastAnim.dispose();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.white,
          body: Stack(
            children: [
              SafeArea(
                child: Column(
                  children: [
                    _buildTopBar(),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            const SizedBox(height: 16),
                            _StepIndicator(
                              total: widget.totalSteps,
                              current: widget.currentStep,
                            ),
                            const SizedBox(height: 32),
                            const _HouseIllustration(),
                            const SizedBox(height: 28),
                            _buildTitle(),
                            const SizedBox(height: 12),
                            _buildEmailChip(),
                            const SizedBox(height: 12),
                            _buildSubtitle(),
                            const SizedBox(height: 24),
                            _buildCodeBox(),
                            const SizedBox(height: 16),
                            _buildResendRow(),
                            const SizedBox(height: 28),
                            _ConfirmButton(
                              enabled: _fullCode.length == _codeLength && !_viewModel.isLoading,
                              isLoading: _viewModel.isLoading,
                              onPressed: _handleConfirm,
                            ),
                            const SizedBox(height: 16),
                            _buildFooterLinks(),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_showResendToast)
                Positioned(
                  bottom: 40,
                  left: 24,
                  right: 24,
                  child: AnimatedBuilder(
                    animation: _toastAnim,
                    builder: (_, __) => Transform.translate(
                      offset: Offset(0, _toastSlide.value),
                      child: FadeTransition(
                        opacity: _toastFade,
                        child: const _ResendToast(),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          _BackButton(onPressed: () => Navigator.pop(context)),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return RichText(
      text: const TextSpan(
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppColors.neutral900,
          fontFamily: 'Sora',
        ),
        children: [
          TextSpan(text: 'Check your '),
          TextSpan(
            text: 'email',
            style: TextStyle(color: AppColors.purple500),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.purple100,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.mail_outline_rounded, color: AppColors.purple500, size: 16),
          const SizedBox(width: 8),
          Text(
            widget.email,
            style: const TextStyle(
              color: AppColors.neutral900,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              fontFamily: 'Sora',
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Text(
              'Edit',
              style: TextStyle(
                color: AppColors.purple500,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                fontFamily: 'Sora',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubtitle() {
    return RichText(
      textAlign: TextAlign.center,
      text: const TextSpan(
        style: TextStyle(
          fontSize: 13,
          color: AppColors.neutral700,
          fontFamily: 'Sora',
        ),
        children: [
          TextSpan(text: 'We sent a 6-digit code. '),
          TextSpan(
            text: 'Expires in 10 minutes.',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.neutral200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text(
            'ENTER YOUR CODE',
            style: TextStyle(
              color: AppColors.neutral700,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
              fontFamily: 'Sora',
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_codeLength, (i) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: i < _codeLength - 1 ? 8 : 0),
                  child: _OtpCell(
                    controller: _controllers[i],
                    focusNode: _focusNodes[i],
                    onChanged: (v) => _onDigitChanged(i, v),
                    onKeyEvent: (e) => _onKeyEvent(i, e),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildResendRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Didn't get it? ",
          style: TextStyle(
            color: AppColors.neutral600,
            fontSize: 13,
            fontFamily: 'Sora',
          ),
        ),
        GestureDetector(
          onTap: _resendCode,
          child: const Text(
            'Resend',
            style: TextStyle(
              color: AppColors.neutral900,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              fontFamily: 'Sora',
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.neutral300,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Row(
            children: [
              const Icon(Icons.access_time_rounded, size: 12, color: AppColors.neutral700),
              const SizedBox(width: 4),
              Text(
                _timerDisplay,
                style: const TextStyle(
                  color: AppColors.neutral700,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Sora',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFooterLinks() {
    return Column(
      children: [
        const Text(
          "Check your spam folder if you don't see it.",
          style: TextStyle(
            color: AppColors.neutral600,
            fontSize: 12,
            fontFamily: 'Sora',
          ),
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Text(
            'Use a different email',
            style: TextStyle(
              color: AppColors.purple500,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              fontFamily: 'Sora',
            ),
          ),
        ),
      ],
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int total;
  final int current;

  const _StepIndicator({required this.total, required this.current});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total * 2 - 1, (i) {
        if (i.isOdd) {
          final stepIndex = i ~/ 2;
          final done = stepIndex + 1 < current;
          return Expanded(
            child: Container(
              height: 2,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: done ? AppColors.purple500 : AppColors.neutral400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }
        final step = i ~/ 2 + 1;
        final isActive = step == current;
        final isDone = step < current;
        return Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive || isDone ? AppColors.purple500 : AppColors.neutral300,
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppColors.purple500.withOpacity(0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    )
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              '$step',
              style: TextStyle(
                color: isActive || isDone ? AppColors.white : AppColors.neutral600,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                fontFamily: 'Sora',
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _HouseIllustration extends StatelessWidget {
  const _HouseIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      height: 140,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: 10,
            left: 0,
            child: Transform.rotate(
              angle: -0.12,
              child: _DocumentCard(
                width: 110,
                height: 85,
                color: AppColors.purple200,
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            child: _DocumentCard(
              width: 120,
              height: 90,
              color: AppColors.white,
              showLines: true,
            ),
          ),
          Positioned(
            bottom: 68,
            child: CustomPaint(
              size: const Size(70, 30),
              painter: _RoofPainter(),
            ),
          ),
          Positioned(
            top: 0,
            right: 20,
            child: Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: AppColors.green500,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded, color: AppColors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentCard extends StatelessWidget {
  final double width;
  final double height;
  final Color color;
  final bool showLines;

  const _DocumentCard({
    required this.width,
    required this.height,
    required this.color,
    this.showLines = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.purple300.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: showLines
          ? Padding(
              padding: const EdgeInsets.fromLTRB(14, 44, 14, 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _Line(width: double.infinity, color: AppColors.purple200),
                  const SizedBox(height: 6),
                  _Line(width: 60, color: AppColors.purple200),
                ],
              ),
            )
          : null,
    );
  }
}

class _Line extends StatelessWidget {
  final double width;
  final Color color;
  const _Line({required this.width, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 6,
      width: width,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class _RoofPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.purple300
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}

class _OtpCell extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final ValueChanged<KeyEvent> onKeyEvent;

  const _OtpCell({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onKeyEvent,
  });

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: onKeyEvent,
      child: ValueListenableBuilder(
        valueListenable: controller,
        builder: (_, value, __) {
          final hasFocus = focusNode.hasFocus;
          final hasText = value.text.isNotEmpty;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hasFocus
                    ? AppColors.purple500
                    : hasText
                        ? AppColors.purple300
                        : AppColors.neutral400,
                width: hasFocus ? 1.5 : 1,
              ),
              boxShadow: hasFocus
                  ? [
                      BoxShadow(
                        color: AppColors.purple500.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      )
                    ]
                  : null,
            ),
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: 1,
              onChanged: onChanged,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.purple700,
                fontFamily: 'Sora',
              ),
              decoration: const InputDecoration(
                counterText: '',
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
          );
        },
      ),
    );
  }
}

class _ConfirmButton extends StatelessWidget {
  final bool enabled;
  final bool isLoading;
  final VoidCallback onPressed;

  const _ConfirmButton({required this.enabled, required this.isLoading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: enabled ? 1.0 : 0.55,
      duration: const Duration(milliseconds: 200),
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: enabled
                ? [AppColors.purple500, AppColors.purple700]
                : [AppColors.purple300, AppColors.purple400],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: AppColors.purple500.withOpacity(0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  )
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: enabled ? onPressed : null,
            borderRadius: BorderRadius.circular(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2),
                  )
                else
                  const Icon(Icons.shield_outlined, color: AppColors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  isLoading ? 'Verifying...' : 'Confirm & verify',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Sora',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _BackButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.neutral200,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.neutral400),
        ),
        child: const Icon(Icons.chevron_left_rounded, color: AppColors.neutral800, size: 22),
      ),
    );
  }
}

class _ResendToast extends StatelessWidget {
  const _ResendToast();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.neutral900,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: AppColors.green500,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_rounded, color: AppColors.white, size: 14),
          ),
          const SizedBox(width: 10),
          const Text(
            'Code resent',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              fontFamily: 'Sora',
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'Check your inbox',
            style: TextStyle(
              color: AppColors.neutral600,
              fontSize: 13,
              fontFamily: 'Sora',
            ),
          ),
        ],
      ),
    );
  }
}