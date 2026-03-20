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
        home: const LandlordProfilePage(),
      ),
    );
  }
}