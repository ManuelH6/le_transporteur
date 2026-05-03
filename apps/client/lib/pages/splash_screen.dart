import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_le_transporteur/core/widgets/app_image.dart';
import 'package:shared_le_transporteur/core/constants/assets.dart';

import 'package:client_le_transporteur/pages/intro/onboarding_page.dart';
import 'package:client_le_transporteur/pages/home/client_home_page.dart';
import 'package:shared_le_transporteur/api/v1/api_client.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
       duration: const Duration(seconds: 2),
       vsync: this,
    )..forward();

    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    Future.delayed(const Duration(seconds: 3), () async {
      if (mounted) {
        final apiClient = ApiClient();
        final token = await apiClient.token;
        final user = await apiClient.user;

        if (token != null && user != null && user.role == 'client') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ClientHomePage()),
          );
        } else {
          Navigator.pushReplacement(
            context, 
            MaterialPageRoute(builder: (context) => const OnboardingPage())
          );
        }
      }
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
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _opacity,
          child: AppImage(
             assetPath: AppAssets.logoOrangeSlog,
             width: 280.w,
             fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
