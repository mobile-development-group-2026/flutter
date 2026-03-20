import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '/../theme/colors.dart';
import '/../views/widgets/custom_button.dart';

class ConfirmIdentity extends StatefulWidget {
  final VoidCallback onNext;
  const ConfirmIdentity({super.key, required this.onNext});

  @override
  State<ConfirmIdentity> createState() => _ConfirmIdentityState();
}

class _ConfirmIdentityState extends State<ConfirmIdentity> {
  void _onSkipPressed() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SkipWarningSheet(onVerify: () {
        Navigator.pop(context);
        widget.onNext();
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.purple100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              LucideIcons.shieldCheck,
              size: 36,
              color: AppColors.purple500,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Confirm your identity',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No documents or selfies — just two quick steps.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 13,
              color: AppColors.neutral700,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),
          _buildVerificationOption(),
          const SizedBox(height: 24),
          _buildWhatYoullDo(),
          const SizedBox(height: 32),
          CustomButton(text: '☆  Start verification', onPressed: widget.onNext),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _onSkipPressed,
            child: Text(
              'Skip for now',
              style: TextStyle(
                fontFamily: 'Sora',
                fontSize: 14,
                color: AppColors.neutral600,
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildVerificationOption() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.purple500,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(LucideIcons.creditCard, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Identity verification',
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Necessary for online safety',
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWhatYoullDo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.neutral300),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.clipboardList, size: 16, color: AppColors.neutral700),
              const SizedBox(width: 8),
              Text(
                'What you\'ll do',
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.neutral800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildStep(
            number: '1',
            title: 'Verify your phone',
            subtitle: 'We\'ll text you a 6-digit code to confirm you\'re real',
          ),
          const SizedBox(height: 12),
          _buildStep(
            number: '2',
            title: 'Proof of property ownership',
            subtitle: 'Utility bill, deed, or tax record with your name',
          ),
        ],
      ),
    );
  }

  Widget _buildStep({
    required String number,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: AppColors.purple100,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                fontFamily: 'Sora',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.purple600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.neutral900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 12,
                  color: AppColors.neutral600,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SkipWarningSheet extends StatelessWidget {
  final VoidCallback onVerify;
  const _SkipWarningSheet({required this.onVerify});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 28),
              decoration: BoxDecoration(
                color: AppColors.neutral400,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.yellow100,
                shape: BoxShape.circle,
              ),
              child: Icon(LucideIcons.triangleAlert, color: AppColors.yellow500, size: 26),
            ),
            const SizedBox(height: 16),
            const Text(
              'Your listings won\'t show up',
              style: TextStyle(
                fontFamily: 'Sora',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Students can only see and contact verified landlords. Skipping now means your profile and listings stay hidden until you complete verification.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Sora',
                fontSize: 13,
                color: AppColors.neutral700,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.yellow100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(LucideIcons.info, size: 16, color: AppColors.yellow600),
                  const SizedBox(width: 10),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 12,
                          color: AppColors.neutral800,
                          height: 1.5,
                        ),
                        children: [
                          TextSpan(
                            text: 'What happens if you skip\n',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.yellow700,
                            ),
                          ),
                          const TextSpan(
                            text: 'Your listings will be created in draft mode and won\'t appear in any student search until verification is complete. You can verify anytime from your profile.',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            CustomButton(text: 'Okay, let me verify', onPressed: onVerify),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Got it, skip for now',
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 14,
                  color: AppColors.neutral600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}