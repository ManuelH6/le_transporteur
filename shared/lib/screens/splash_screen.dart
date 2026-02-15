// lib/screens/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:shared_le_transporteur/core/constants/assets.dart';
import 'package:shared_le_transporteur/core/theme/app_theme.dart';
import 'package:shared_le_transporteur/core/widgets/app_image.dart';
import 'dart:async';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'onboarding_screen.dart'; // Navigate to onboarding after splash

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOutQuint);
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();

    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // To use the orange splash, change backgroundColor and the logo asset.
    const bool useOrangeSplash = false;

    return Scaffold(
      backgroundColor: useOrangeSplash ? AppColors.primary : AppColors.background,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: AppImage(
              assetPath: useOrangeSplash ? AppAssets.logoWhite : AppAssets.logoOrange,
              width: 200.w,
            ),
          ),
        ),
      ),
    );
  }
}
