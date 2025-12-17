import 'package:flutter/material.dart';
import 'package:neobazaar/themes/theme_data.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NeoBazaar',
      theme: appTheme(),
      home: const SplashScreen(),
    );
  }
}
