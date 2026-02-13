import 'dart:developer';

import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late Animation<double> _rotationAnimation;

  late AnimationController _textSlideController;
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _textFadeAnimation;

  @override
  void initState() {
    super.initState();

    // Controller for the hammer rotation
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500), // Adjust duration as needed
    );
    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.easeOut),
    );

    // Controller for the text slide and fade
    _textSlideController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 700,
      ), // Adjust duration for text animation
    );
    _textSlideAnimation =
        Tween<Offset>(
          begin: const Offset(-0.5, 0), // Start off-screen to the left
          end: Offset.zero, // End at its original position
        ).animate(
          CurvedAnimation(parent: _textSlideController, curve: Curves.easeOut),
        );

    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textSlideController, curve: Curves.easeIn),
    );

    // Start animations in sequence
    _rotationController.forward().then((_) {
      // After rotation completes, start text animation
      _textSlideController.forward().then((_) {
        // After all animations, navigate to the next screen
        Future.delayed(const Duration(milliseconds: 200), () {
          // Small delay before navigating
          checkForOnboarding();
        });
      });
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _textSlideController.dispose();
    super.dispose();
  }

  void checkForOnboarding() async {
    //here is the logic to check for already logged in
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFFBF8F0,
      ), // The light background color from your GIF
      body: Center(
        child: Row(
          mainAxisSize:
              MainAxisSize.min, // To keep the row as small as its children
          children: [
            // Rotating  Icon
            RotationTransition(
              turns: _rotationAnimation,
              child: Image.asset(
                'assets/logo.png',
                width: 80, // Adjust size as needed
                height: 80,
              ),
            ),
            const SizedBox(width: 10), // Space between icon and text
            //  Text Logo
            SlideTransition(
              position: _textSlideAnimation,
              child: FadeTransition(
                opacity: _textFadeAnimation,
                child: const Text(
                  'Your App Name',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
