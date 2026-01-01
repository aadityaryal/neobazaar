import 'package:flutter/material.dart';
import 'package:neobazaar/app/theme/theme_data.dart';
import 'package:neobazaar/features/splash/presentation/pages/splash_screen.dart';

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
