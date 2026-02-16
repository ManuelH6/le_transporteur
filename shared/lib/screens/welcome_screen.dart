// lib/screens/welcome_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_le_transporteur/core/constants/assets.dart';
import 'package:shared_le_transporteur/core/theme/app_theme.dart';
import 'package:shared_le_transporteur/core/widgets/app_button.dart';
import 'package:shared_le_transporteur/core/widgets/app_image.dart';
import 'package:shared_le_transporteur/screens/login_screen.dart';
import 'package:shared_le_transporteur/screens/register_driver_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Decorative circles
            // Positioned(
            //   top: 100.h,
            //   right: 20.w,
            //   child: Container(
            //     width: 60.r,
            //     height: 60.r,
            //     decoration: const BoxDecoration(
            //       color: AppColors.primary,
            //       shape: BoxShape.circle,
            //     ),
            //   ),
            // ),
            // Positioned(
            //   bottom: 220.h,
            //   left: 30.w,
            //   child: Container(
            //     width: 80.r,
            //     height: 80.r,
            //     decoration: BoxDecoration(
            //       color: AppColors.primary.withValues(alpha: 0.9),
            //       shape: BoxShape.circle,
            //     ),
            //   ),
            // ),
            // Main Content
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 60.h),
                  // Header text
                  RichText(
                    textAlign: TextAlign.left,
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text,
                        height: 1.2,
                        fontFamily: 'PlusJakartaSans',
                      ),
                      children: const <TextSpan>[
                        TextSpan(text: 'Bienvenue chez\n'),
                        TextSpan(
                          text: 'LE TRANSPORTEUR',
                          style: TextStyle(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Main image - taking more space
                  Expanded(
                    child: AppImage(
                      assetPath: AppAssets.deuxLivreurs,
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  // Indicator dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      3,
                      (index) => Container(
                        margin: EdgeInsets.symmetric(horizontal: 4.w),
                        width: 8.r,
                        height: 8.r,
                        decoration: BoxDecoration(
                          color: index == 0 ? AppColors.primary : AppColors.grey.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 15.h),
                  // Subtitle
                   Center(
                     child: Text(
                      "Connectez-vous ou inscrivez-vous\npour commencer à livrer.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: AppColors.text.withValues(alpha: 0.7),
                      ),
                                     ),
                   ),
                  SizedBox(height: 30.h),
                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          text: "Inscription",
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const RegisterDriverScreen(),
                              ),
                            );
                          },
                          isPrimary: false,
                          backgroundColor: AppColors.text, // Black background
                          textColor: AppColors.white, // White text
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: AppButton(
                          text: "Connexion",
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => LoginScreen(
                                  backgroundImage: AppAssets.backgroundMotoLivreur,
                                  title: "Connectez-vous !\nUne livraison vous attend !!",
                                ),
                              ),
                            );
                          },
                          // Uses default primary style (orange)
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 40.h), // Bottom padding
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
