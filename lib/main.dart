import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/myflight/pages/myflight_page.dart';

void main() {
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
      home: const MyFlightPage(), // MyFlight 페이지로 테스트
    );
  }
}
