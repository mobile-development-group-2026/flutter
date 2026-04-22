import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'views/pages/landlord_profile_page.dart';
import 'viewmodels/profile_viewmodel.dart';
import 'services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
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
        ),
        home: const LandlordProfilePage(),
      ),
    );
  }
}