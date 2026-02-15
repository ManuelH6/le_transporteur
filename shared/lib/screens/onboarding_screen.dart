// lib/screens/onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_le_transporteur/core/constants/assets.dart';
import 'package:shared_le_transporteur/core/theme/app_theme.dart';
import 'package:shared_le_transporteur/core/widgets/app_button.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              SizedBox(height: 30.h),
              Text(
                "Bienvenue chez\nLE TRANSPORTEUR",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayLarge,
              ),
              SizedBox(height: 30.h),
              Expanded(
                child: Image.asset(AppAssets.backgroundDeuxLivreurs), // Using the provided image name
              ),
              SizedBox(height: 20.h),
              Text(
                "Connectez-vous ou inscrivez-vous pour commencer à livrer.",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.text.withOpacity(0.7)),
              ),
              SizedBox(height: 30.h),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: "Inscription",
                      onPressed: () {
                        // TODO: Navigate to Register Screen
                      },
                      isPrimary: false, // Secondary style
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: AppButton(
                      text: "Connexion",
                      onPressed: () {
                        // TODO: Navigate to Login Screen
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }
}
