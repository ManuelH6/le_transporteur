// lib/screens/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:shared_le_transporteur/core/constants/assets.dart';
import 'package:shared_le_transporteur/core/theme/app_theme.dart';
import 'package:shared_le_transporteur/core/widgets/app_image.dart';
import 'dart:async';
import 'package:flutter_screenutil/flutter_screenutil.dart';

//import 'onboarding_screen.dart'; // Navigate to onboarding after splash
import 'welcome_screen.dart'; // Navigate to welcome screen after splash

class SplashScreen extends StatefulWidget {
  final bool useOrangeSplash;
  const SplashScreen({super.key, this.useOrangeSplash = false});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
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
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
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
    return Scaffold(
      backgroundColor: widget.useOrangeSplash ? AppColors.primary : AppColors.background,
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Center(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: AppImage(
                        assetPath: widget.useOrangeSplash ? AppAssets.logoWhite : AppAssets.logoOrange,
                        width: 200.w,
                      ),
                    ),
                  ),
                ),
              ),
              if (widget.useOrangeSplash)
                Padding(
                  padding: EdgeInsets.only(bottom: 60.h),
                  child: Text(
                    "Pointez vos courses en un clin d'œil",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
