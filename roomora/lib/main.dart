import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'views/pages/landlord_profile_page.dart';
import 'viewmodels/profile_viewmodel.dart';
import 'services/api_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ProfileViewModel(apiService: ApiService()),
        ),
      ],
      child: MaterialApp(
        title: 'Landlord App',
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
          textTheme: const TextTheme(
            headlineLarge: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: Color(0xFF212327),
              letterSpacing: -0.64,
              fontFamily: 'Sora',
            ),
            headlineMedium: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Color(0xFF212327),
              letterSpacing: -0.56,
              fontFamily: 'Sora',
            ),
            bodyLarge: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Color(0xFF212327),
              fontFamily: 'Sora',
            ),
            bodyMedium: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF6E7681),
              fontFamily: 'Sora',
            ),
            bodySmall: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Color(0xFFB0B6BF),
              fontFamily: 'Sora',
            ),
          ),
        ),
        home: const LandlordProfilePage(),
      ),
    );
  }
}