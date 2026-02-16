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
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              Spacer(),
              Text(
                "Bienvenue chez\nLE TRANSPORTEUR",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
              SizedBox(height: 30.h),
              Expanded(
                flex: 3,
                child: AppImage(
                  assetPath: AppAssets.deuxLivreurs,
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                "Connectez-vous ou inscrivez-vous pour commencer à livrer.",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  color: AppColors.text.withOpacity(0.7),
                ),
              ),
              Spacer(),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 50.h,
                      child: OutlinedButton(
                        onPressed: () {
                           Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const RegisterPage()),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(
                          "Inscription",
                          style: GoogleFonts.poppins(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
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
      ),
    );
  }
}
