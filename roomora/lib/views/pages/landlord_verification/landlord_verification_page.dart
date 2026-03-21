import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '/../theme/colors.dart';
import '/../viewmodels/auth_viewmodel.dart';
import '/../views/pages/landlord_profile_page.dart';
import 'confirm_identity_page.dart';
import 'sms_verification_page.dart';
import 'proof_address_page.dart';

class LandlordVerificationPage extends StatefulWidget {
  const LandlordVerificationPage({super.key});

  @override
  State<LandlordVerificationPage> createState() =>
      _LandlordVerificationPageState();
}

class _LandlordVerificationPageState extends State<LandlordVerificationPage> {
  int _currentStep = 1;
  final int _totalSteps = 4;

  void _nextStep() {
    if (_currentStep < _totalSteps) {
      setState(() => _currentStep++);
    } else {
      _finishVerification();
    }
  }

  void _previousStep() {
    if (_currentStep > 1) {
      setState(() => _currentStep--);
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _finishVerification() async {
    final auth = context.read<AuthViewModel>();
    await auth.markOnboarded();

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LandlordProfilePage(onNext: () {})),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            const SizedBox(height: 8),
            _buildStepper(),
            const SizedBox(height: 24),
            Expanded(child: _buildCurrentStep()),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: _previousStep,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.neutral400),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                LucideIcons.chevronLeft,
                size: 18,
                color: AppColors.neutral900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepper() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: List.generate(_totalSteps * 2 - 1, (i) {
          if (i.isOdd) {
            final stepIndex = (i ~/ 2) + 1;
            final isCompleted = stepIndex < _currentStep;
            return Expanded(
              child: Container(
                height: 2,
                color: isCompleted ? AppColors.purple500 : AppColors.neutral300,
              ),
            );
          }
          final stepNumber = (i ~/ 2) + 1;
          final isCompleted = stepNumber < _currentStep;
          final isCurrent = stepNumber == _currentStep;
          return _stepDot(
            number: stepNumber,
            isCompleted: isCompleted,
            isCurrent: isCurrent,
          );
        }),
      ),
    );
  }

  Widget _stepDot({
    required int number,
    required bool isCompleted,
    required bool isCurrent,
  }) {
    Color bgColor;
    Color textColor;
    Color borderColor;

    if (isCompleted || isCurrent) {
      bgColor = AppColors.purple500;
      textColor = Colors.white;
      borderColor = AppColors.purple500;
    } else {
      bgColor = Colors.white;
      textColor = AppColors.neutral500;
      borderColor = AppColors.neutral300;
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Center(
        child: isCompleted
            ? const Icon(Icons.check, size: 14, color: Colors.white)
            : Text(
                '$number',
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 1:
        return ConfirmIdentity(onNext: _nextStep);
      case 2:
        return SmsVerification(onNext: _nextStep);
      case 3:
        return ProofOfAddress(onNext: _nextStep);
      case 4:
        return LandlordProfilePage(onNext: _nextStep);
      default:
        return ConfirmIdentity(onNext: _nextStep);
    }
  }
}