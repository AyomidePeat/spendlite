import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:spendlite/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Navigate to Home after 3 seconds
    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // App Icon with fade-in and rotation animation
            Image.asset(
              'assets/spendlite.png',
              width: 150,
              height: 150,
            )
                .animate() // flutter_animate extension
                .fadeIn(duration: 500.ms) // fade in first
                .rotate(
                  duration: 2000.ms,
                  curve: Curves.easeInOut,
                  begin: 0,
                  end: 1, // 1 full turn clockwise
                ),
            const SizedBox(height: 20),
            // Worthy text beneath
            const Text(
              'Smart Spending, Smart Living',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            )
                .animate()
                .fadeIn(delay: 1000.ms, duration: 1500.ms), // fade in after icon
          ],
        ),
      ),
    );
  }
}
