import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:livreur_le_transporteur/pages/intro/onboarding_page.dart';
import 'package:shared_le_transporteur/core/theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context , child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Livreur Le Transporteur',
          theme: AppTheme.theme, // Use the shared theme
          home: const OnboardingPage(),
        );
      },
    );
  }
}
