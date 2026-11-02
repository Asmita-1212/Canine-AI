import 'package:flutter/material.dart';

import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const green = Color(0xFF287A65);
  static const darkGreen = Color(0xFF193B31);

  @override
  void initState() {
    super.initState();
    _openLoginAfterDelay();
  }

  Future<void> _openLoginAfterDelay() async {
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F6),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: SizedBox(
                      height: 230,
                      width: double.infinity,
                      child: Image.network(
                        'https://images.pexels.com/photos/3752119/pexels-photo-3752119.jpeg',
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(color: green),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const ColoredBox(
                            color: Color(0xFFE0F1E9),
                            child: Center(
                              child: Icon(
                                Icons.pets_rounded,
                                size: 80,
                                color: green,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Container(
                    height: 72,
                    width: 72,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F1E9),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(
                      Icons.pets_rounded,
                      size: 42,
                      color: green,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'CanineCare AI',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: darkGreen,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Smarter skin health for your best friend.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF65756E), fontSize: 15),
                  ),
                  const SizedBox(height: 32),
                  const SizedBox(
                    height: 25,
                    width: 25,
                    child: CircularProgressIndicator(
                      color: green,
                      strokeWidth: 2.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'MADE WITH CARE FOR EVERY PAW',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: green,
                      fontSize: 10,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
