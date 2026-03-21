import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/api_service.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/profile_viewmodel.dart';
import 'viewmodels/listing_viewmodel.dart';
import 'views/pages/landing_page.dart';
import 'views/pages/discover_page.dart';
import 'views/pages/landlord_verification/landlord_verification_page.dart';

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
          create: (_) => AuthViewModel(apiService: apiService),
        ),
        ChangeNotifierProvider(
          create: (_) => ProfileViewModel(apiService: apiService),
        ),
        ChangeNotifierProvider(
          create: (_) => ListingViewModel(apiService: apiService),
        ),
      ],
      child: MaterialApp(
        title: 'Roomora',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: const Color(0xFF7B5BF2),
          scaffoldBackgroundColor: const Color(0xFFFCFCFD),
          fontFamily: 'Sora',
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFFFCFCFD),
            elevation: 0,
            iconTheme: IconThemeData(color: Color(0xFF212327)),
            titleTextStyle: TextStyle(
              color: Color(0xFF212327),
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontFamily: 'Sora',
            ),
          ),
          colorScheme: ColorScheme.fromSwatch().copyWith(
            primary: const Color(0xFF7B5BF2),
            secondary: const Color(0xFF4B31A8),
          ),
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkSession());
  }

  Future<void> _checkSession() async {
    final auth = context.read<AuthViewModel>();
    final hasSession = await auth.restoreSession();
    if (!mounted) return;

    if (hasSession) {
      if (auth.isLandlord) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LandlordVerificationPage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DiscoverPage()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const LandingPage();
  }
}