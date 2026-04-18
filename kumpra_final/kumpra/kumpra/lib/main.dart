import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'utils/constants.dart';
import 'services/cart_provider.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getString('token') != null;

  runApp(
    ChangeNotifierProvider(
      create: (_) => CartProvider(),
      child: KumpraApp(isLoggedIn: isLoggedIn),
    ),
  );
}

class KumpraApp extends StatelessWidget {
  final bool isLoggedIn;
  const KumpraApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: AppTheme.theme,
      debugShowCheckedModeBanner: false,
      home: isLoggedIn ? const HomeScreen() : const OnboardingScreen(),
    );
  }
}
