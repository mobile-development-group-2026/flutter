import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import '/../../theme/colors.dart';
import '/../../models/user_session.dart';
import '/../../viewmodels/Onboarding/onboarding_viewmodel.dart';
import '../../widgets/custom_button.dart';
import 'build_your_profile_page.dart';
import 'roommate_situation_page.dart';
import 'roommate_preferences_page.dart';
import 'listing_preferences_page.dart';
import 'new_listing_page.dart';
import 'onboarding_complete_page.dart';
import '../discover_page.dart';


class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  late final OnboardingViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = OnboardingViewModel();
    final session = context.read<UserSession>();
    _vm.isLandlord = session.role == 'landlord';

    _vm.addListener(_onVmChanged);
  }

  void _onVmChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _vm.removeListener(_onVmChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ClerkAuth.of(context);
    final session = context.read<UserSession>();

    if (_vm.showCelebration) {
      return OnboardingCompleteView(
        firstName: _vm.completedProfile?.firstName ?? 'there',
        role: _vm.completedProfile?.role ?? 'student',
        onContinue: () {
          _vm.finishOnboarding(session);
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const DiscoverPage()), 
          );
        },
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  AnimatedOpacity(
                    opacity: _vm.step > 0 ? 1 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: GestureDetector(
                      onTap: _vm.step > 0 ? _vm.previousStep : null,
                      child: const Icon(Icons.chevron_left,
                          color: AppColors.neutral700, size: 24),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: List.generate(_vm.totalSteps, (i) {
                          return Expanded(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              height: 4,
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              decoration: BoxDecoration(
                                color: i <= _vm.step
                                    ? AppColors.purple500
                                    : AppColors.neutral300,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                ],
              ),
            ),

            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _buildStepContent(key: ValueKey(_vm.step)),
              ),
            ),

            if (_vm.errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Container(
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
                        child: Text(_vm.errorMessage!,
                            style: const TextStyle(
                                color: AppColors.red500,
                                fontSize: 13,
                                fontFamily: 'Sora')),
                      ),
                    ],
                  ),
                ),
              ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: AnimatedOpacity(
                opacity: _vm.canContinue ? 1.0 : 0.4,
                duration: const Duration(milliseconds: 200),
                child: _vm.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.purple500))
                    : CustomButton(
                        text: _vm.isLastStep
                            ? (_vm.isLoading
                                ? 'Finalizando...'
                                : 'Completar setup')
                            : 'Continuar  →',
                        onPressed: _vm.canContinue
                            ? () async {
                                if (_vm.isLastStep) {
                                  await _vm.complete(auth);
                                } else {
                                  await _vm.nextStep(auth);
                                }
                              }
                            : () {},
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent({required Key key}) {
    switch (_vm.step) {
      case 0:
        return BuildYourProfileView(
          key: key,
          vm: _vm.buildProfile,
          role: _vm.isLandlord ? 'landlord' : 'student',
        );
      case 1:
        if (_vm.isLandlord) {
          return NewListingView(key: key, vm: _vm.newListing);
        }
        return RoommateSituationView(key: key, vm: _vm.situation);
      default:
        if (_vm.needsPlace) {
          return ListingPreferencesView(key: key, vm: _vm.listingPrefs);
        }
        return RoommatePreferencesView(
            key: key, vm: _vm.preferences, role: 'student');
    }
  }
}