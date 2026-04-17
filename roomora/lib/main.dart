import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clerk_flutter/clerk_flutter.dart'; 
import 'package:clerk_auth/clerk_auth.dart';       
import 'state/user_session.dart'; 
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
    return ClerkAuth(
    config: ClerkAuthConfig(
      publishableKey: const String.fromEnvironment(
        'CLERK_PUBLISHABLE_KEY',
        defaultValue: 'pk_test_...', // Tu llave real aquí
    ),
  ),
      child: MultiProvider(
        providers: [
          // ChangeNotifierProvider(create: (_) => ProfileViewModel()),
          // ChangeNotifierProvider(create: (_) => ListingViewModel()),
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
  Widget build(BuildContext context) {
    final clerkAuth = ClerkAuth.of(context);
    final session = context.watch<UserSession>();

    if (clerkAuth.session == null) {
      return const LandingPage();
    }

    if (!session.isLoaded) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        session.load(clerkAuth);
      });
      
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF7B5BF2)),
        ),
      );
    }

    if (session.role == 'landlord' && !session.isOnboarded) {
      return const LandlordVerificationPage();
    } else {
      return const DiscoverPage();
    }
  }
}