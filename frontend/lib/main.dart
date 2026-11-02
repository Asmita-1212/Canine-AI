import 'package:flutter/material.dart';
import 'package:frontend/screens/splash_screen.dart';

void main() {
  runApp(const CanineCareApp());
}

class CanineCareApp extends StatelessWidget {
  const CanineCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CanineCare AI',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF4F8FC),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2878D0),
          brightness: Brightness.light,
        ),
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.fixed,
          showCloseIcon: true,
        ),
      ),

      home: const SplashScreen(),
    );
  }
}
