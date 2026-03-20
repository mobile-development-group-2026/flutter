import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '/../views/widgets/login_background.dart';
import '/../theme/colors.dart';
import '/../views/pages/sign_in_page.dart';
import '/../views/pages/sign_up_page.dart';
class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.purple900,
      body: LoginBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const Spacer(flex: 2),

                // Logo
                _buildLogo(),

                const SizedBox(height: 16),

                // Nombre y subtítulo
                const Text(
                  'roomora',
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Your home search, simplified',
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 13,
                    fontWeight: FontWeight.w300,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),

                const Spacer(flex: 2),

                // Headline principal
                const Text(
                  'Housing & roommates',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.25,
                  ),
                ),

                Text(
                  'made for students',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: AppColors.purple400,
                    height: 1.25,
                  ),
                ),

                const SizedBox(height: 16),

                // Subtexto
                Text(
                  'Verified listings, compatible roommates,\nand zero stress.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 13,
                    fontWeight: FontWeight.w300,
                    color: Colors.white.withValues(alpha: 0.5),
                    height: 1.6,
                  ),
                ),

                const SizedBox(height: 28),

                // Pills / chips
                _buildPills(),

                const Spacer(flex: 3),

                // Botones
                _buildButtons(context),

                const SizedBox(height: 16),

                // Texto legal
                Text(
                  'By continuing you agree to our Terms & Privacy Policy',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: AppColors.purple600,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Icon(
        LucideIcons.house,
        color: Colors.white,
        size: 32,
      ),
    );
  }

  Widget _buildPills() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 10,
      runSpacing: 10,
      children: [
        _pill(
          label: 'Verified landlords',
          dotColor: AppColors.green400,
        ),
        _pill(
          label: 'Roommate matching',
          dotColor: AppColors.yellow400,
        ),
        _pill(
          label: 'Map search',
          dotColor: AppColors.purple400,
        ),
      ],
    );
  }

  Widget _pill({required String label, required Color dotColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Sora',
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _openSignIn(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).size.height * 0.35,
      ),
      child: const SignInSheet(),
    ),
  );
}

  Widget _buildButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SignUpPage()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.purple500,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'Get Started — It\'s Free',
              style: TextStyle(
                fontFamily: 'Sora',
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            onPressed: () => _openSignIn(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: BorderSide(
                color: Colors.white.withValues(alpha: 0.15),
                width: 1,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'I already have an account',
              style: TextStyle(
                fontFamily: 'Sora',
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ],
    );
  }
}