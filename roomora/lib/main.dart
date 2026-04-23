import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import 'services/api_service.dart';
import 'viewmodels/profile_viewmodel.dart';
import 'viewmodels/listing_viewmodel.dart';
import 'viewmodels/gps_viewmodel.dart';
import 'viewmodels/map_viewmodel.dart';
import 'models/user_session.dart';
import 'theme/colors.dart';
import 'views/pages/Auth/sign_in_page.dart';
import 'views/pages/Auth/sign_up_page.dart';
import 'views/pages/discover_page.dart';
import 'views/pages/landlord_listing_page.dart';
import 'package:clerk_auth/clerk_auth.dart' as clerk;
import 'views/pages/landlord_profile_page.dart';
import 'views/pages/landing_page.dart';
import 'views/pages/Onboarding/onboarding_page.dart';

void main() {
  runApp(const RoomoraApp());
}

class RoomoraApp extends StatelessWidget {
  const RoomoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    final apiService = ApiService();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ProfileViewModel(apiService: apiService),
        ),
        ChangeNotifierProvider(
          create: (_) => ListingViewModel(apiService: apiService),
        ),
        ChangeNotifierProvider(create: (_) => GPSViewModel()),
        ChangeNotifierProvider(
          create: (_) => MapViewModel(apiService: apiService),
        ),
        ChangeNotifierProvider(create: (_) => UserSession()),
      ],
      child: ClerkAuth(
        //clerk Andy: pk_test_ZXZvbHZpbmctZ2VsZGluZy02MS5jbGVyay5hY2NvdW50cy5kZXYk
        //clerk Esteban: pk_test_YnVyc3RpbmctaGFnZmlzaC05NC5jbGVyay5hY2NvdW50cy5kZXYk
        config: ClerkAuthConfig(publishableKey: 'pk_test_YnVyc3RpbmctaGFnZmlzaC05NC5jbGVyay5hY2NvdW50cy5kZXYk'),
        child: MaterialApp(
          title: 'Roomora',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primaryColor: AppColors.purple500,
            scaffoldBackgroundColor: AppColors.neutral100,
            fontFamily: 'Sora',
            appBarTheme: const AppBarTheme(
              backgroundColor: AppColors.neutral100,
              elevation: 0,
              iconTheme: IconThemeData(color: AppColors.neutral900),
              titleTextStyle: TextStyle(
                color: AppColors.neutral900,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                fontFamily: 'Sora',
              ),
            ),
            colorScheme: ColorScheme.fromSwatch().copyWith(
              primary: AppColors.purple500,
              secondary: AppColors.purple700,
            ),
          ),
          home: const RootView(),
        ),
      ),
    );
  }
}

class RootView extends StatefulWidget {
  const RootView({super.key});

  @override
  State<RootView> createState() => _RootViewState();
}

class _RootViewState extends State<RootView> {
  bool _loadTimedOut = false;
  String? _previousUserId;

  @override
  Widget build(BuildContext context) {
    final auth = ClerkAuth.of(context);
    final session = context.watch<UserSession>();
    final user = auth.user;

    final currentId = user?.id;
    if (currentId != _previousUserId) {
      _previousUserId = currentId;

      if (currentId == null) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (auth.user == null && mounted) {
            session.clear();
            setState(() => _loadTimedOut = false);
          }
        });
      } else {
        // Sign in detectado → cargar perfil
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!session.isLoaded) {
            _startLoad(auth, session);
          }
        });
      }
    }

 
    if (user == null) {
      return const LandingView();
    }

    if (!session.isLoaded) {
      return Scaffold(
        backgroundColor: AppColors.white,
        body: Center(
          child: _loadTimedOut
              ? _RetryView(onRetry: () {
                  setState(() => _loadTimedOut = false);
                  session.isLoaded = false;
                  session.notifyListeners();
                  _startLoad(auth, session);
                })
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: AppColors.purple500),
                    const SizedBox(height: 16),
                    Text(
                      session.pendingSync != null
                          ? 'Creando tu cuenta...'
                          : 'Cargando tu cuenta...',
                      style: const TextStyle(
                        color: AppColors.neutral700,
                        fontFamily: 'Sora',
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
        ),
      );
    }


    if (!session.isOnboarded) {
      return const OnboardingView(); 
    }

    return const DiscoverPage();
  }

  void _startLoad(ClerkAuthState auth, UserSession session) {
    session.load(auth).then((_) {
      if (!session.isLoaded && mounted) {
        Future.delayed(const Duration(seconds: 15), () {
          if (!session.isLoaded && mounted) {
            setState(() => _loadTimedOut = true);
          }
        });
      }
    });
  }
}

class _RetryView extends StatelessWidget {
  final VoidCallback onRetry;
  const _RetryView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_off_rounded,
              size: 40, color: AppColors.neutral600),
          const SizedBox(height: 16),
          const Text(
            'No pudimos conectarnos',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              fontFamily: 'Sora',
              color: AppColors.neutral900,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'El servidor puede estar iniciando.\nTocá para reintentar.',
            style: TextStyle(
                color: AppColors.neutral700,
                fontSize: 14,
                fontFamily: 'Sora',
                height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _GradientButton(text: 'Reintentar', onPressed: onRetry, fullWidth: false),
        ],
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool fullWidth;

  const _GradientButton(
      {required this.text, required this.onPressed, this.fullWidth = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: fullWidth ? double.infinity : null,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.purple500, AppColors.purple700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.purple500.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'Sora',
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const _OutlineButton({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neutral400),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.neutral800,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                fontFamily: 'Sora',
              ),
            ),
          ),
        ),
      ),
    );
  }
}
