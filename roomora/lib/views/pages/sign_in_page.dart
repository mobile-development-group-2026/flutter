import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '/../theme/colors.dart';
import '../widgets/custom_button.dart';
import '../widgets/social_button.dart';
import '/../views/pages/sign_up_page.dart';

class SignInSheet extends StatefulWidget {
  const SignInSheet({super.key});

  @override
  State<SignInSheet> createState() => _SignInSheetState();
}

class _SignInSheetState extends State<SignInSheet> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHandle(),
            _buildHeader(),
            const SizedBox(height: 20),
            _buildSocialProof(),
            const SizedBox(height: 28),
            _buildFieldLabel('EMAIL ADDRESS'),
            const SizedBox(height: 8),
            _buildEmailField(),
            const SizedBox(height: 16),
            _buildFieldLabel('PASSWORD'),
            const SizedBox(height: 8),
            _buildPasswordField(),
            _buildForgotPassword(),
            const SizedBox(height: 18),
            CustomButton(text: 'Sign In →', onPressed: () {}),
            const SizedBox(height: 28),
            _buildDivider(),
            const SizedBox(height: 20),
            _buildSocialButtons(),
            const SizedBox(height: 24),
            _buildSignUpRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Center(
      child: Container(
        width: 36,
        height: 4,
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          color: AppColors.neutral400,
          borderRadius: BorderRadius.circular(100),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: const TextStyle(
              fontFamily: 'Sora',
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
            children: [
              const TextSpan(text: 'Welcome '),
              TextSpan(
                text: 'back',
                style: TextStyle(color: AppColors.purple500),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Sign in to continue finding your perfect place.',
          style: TextStyle(
            fontFamily: 'Sora',
            fontSize: 13,
            color: AppColors.neutral700,
          ),
        ),
      ],
    );
  }

  Widget _buildSocialProof() {
    final initials = ['M', 'L', 'A'];
    final colors = [
      AppColors.purple300,
      AppColors.purple400,
      AppColors.purple500,
    ];

    return Row(
      children: [
        SizedBox(
          width: 88,
          height: 32,
          child: Stack(
            children: [
              ...List.generate(initials.length, (i) {
                return Positioned(
                  left: i * 20.0,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: colors[i],
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        initials[i],
                        style: const TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                );
              }),
              Positioned(
                left: initials.length * 20.0,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.purple200,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      '+',
                      style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.purple600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 12,
              color: AppColors.neutral700,
            ),
            children: const [
              TextSpan(
                text: '2,400+ students ',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              TextSpan(text: 'found housing\nthrough Roomora this semester'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontFamily: 'Sora',
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.neutral700,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildEmailField() {
    return TextField(
      keyboardType: TextInputType.emailAddress,
      style: TextStyle(
        fontFamily: 'Sora',
        fontSize: 14,
        color: AppColors.neutral900,
      ),
      decoration: InputDecoration(
        hintText: 'you@university.edu',
        hintStyle: TextStyle(
          fontFamily: 'Sora',
          fontSize: 14,
          color: AppColors.neutral500,
        ),
        prefixIcon: Icon(LucideIcons.mail, size: 18, color: AppColors.neutral600),
        filled: true,
        fillColor: AppColors.neutral200,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.neutral400),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.neutral400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.purple500, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      obscureText: _obscurePassword,
      style: TextStyle(
        fontFamily: 'Sora',
        fontSize: 14,
        color: AppColors.neutral900,
      ),
      decoration: InputDecoration(
        hintText: 'Enter your password',
        hintStyle: TextStyle(
          fontFamily: 'Sora',
          fontSize: 14,
          color: AppColors.neutral500,
        ),
        prefixIcon: Icon(LucideIcons.lockKeyhole, size: 18, color: AppColors.neutral600),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? LucideIcons.eye : LucideIcons.eyeOff,
            size: 18,
            color: AppColors.neutral600,
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
        filled: true,
        fillColor: AppColors.neutral200,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.neutral400),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.neutral400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.purple500, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {},
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
        ),
        child: Text(
          'Forgot password?',
          style: TextStyle(
            fontFamily: 'Sora',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.purple500,
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: AppColors.neutral400, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'or continue with',
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 12,
              color: AppColors.neutral600,
            ),
          ),
        ),
        Expanded(child: Divider(color: AppColors.neutral400, thickness: 1)),
      ],
    );
  }

  Widget _buildSocialButtons() {
    return Row(
      children: [
        Expanded(
          child: SocialButton(
            provider: SocialProvider.google,
            onPressed: () {},
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SocialButton(
            provider: SocialProvider.apple,
            onPressed: () {},
          ),
        ),
      ],
    );
  }

 Widget _buildSignUpRow() {
  return Center(
    child: GestureDetector(
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SignUpPage()),
        );
      },
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            fontFamily: 'Sora',
            fontSize: 13,
            color: AppColors.neutral700,
          ),
          children: [
            const TextSpan(text: "Don't have an account? "),
            TextSpan(
              text: 'Sign up free',
              style: TextStyle(
                color: AppColors.purple500,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}