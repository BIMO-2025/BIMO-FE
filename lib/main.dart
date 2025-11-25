import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/onboarding/pages/splash_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set system UI overlay style
  AppTheme.setSystemUIOverlayStyle();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BIMO',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const SplashPage(),
    );
  }
}
