import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_le_transporteur/core/constants/assets.dart';
import 'package:shared_le_transporteur/core/theme/app_theme.dart';
import 'package:shared_le_transporteur/core/widgets/app_button.dart';
import 'package:shared_le_transporteur/core/widgets/app_image.dart';
import 'package:livreur_le_transporteur/pages/auth/login_page.dart';
import 'package:livreur_le_transporteur/pages/auth/register_page.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Orange decorative circles
            // Positioned(
            //   top: 100.h,
            //   right: -30.w,
            //   child: Container(
            //     width: 120.w,
            //     height: 120.w,
            //     decoration: BoxDecoration(
            //       color: AppColors.primary,
            //       shape: BoxShape.circle,
            //     ),
            //   ),
            // ),
            // Positioned(
            //   bottom: 280.h,
            //   left: -20.w,
            //   child: Container(
            //     width: 100.w,
            //     height: 100.w,
            //     decoration: BoxDecoration(
            //       color: AppColors.primary,
            //       shape: BoxShape.circle,
            //     ),
            //   ),
            // ),
            // Main content
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                children: [
                  SizedBox(height: 40.h),
                  RichText(
                    textAlign: TextAlign.left,
                    text: TextSpan(
                      style: GoogleFonts.poppins(
                        fontSize: 22.sp,
                        color: AppColors.text,
                        fontWeight: FontWeight.bold,
                      ),
                      children: [
                        TextSpan(
                          text: "Bienvenue chez\n",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        TextSpan(
                          text: "LE TRANSPORTEUR",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 40.h),
                  Expanded(
                    child: Center(
                      child: AppImage(
                        assetPath: AppAssets.deuxLivreurs,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  SizedBox(height: 30.h),
                  Text(
                    "Connectez-vous ou inscrivez-vous\npour commencer à livrer.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 13.sp,
                      color: AppColors.text.withOpacity(0.7),
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 30.h),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          text: "Inscription",
                          isPrimary: false,
                          backgroundColor: Color(0xFF3D3D3D),
                          textColor: AppColors.white,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const RegisterPage()),
                            );
                          },
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: AppButton(
                          text: "Connexion",
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const LoginPage()),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
