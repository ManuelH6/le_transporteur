import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ms_undraw/ms_undraw.dart';
import 'package:shared_le_transporteur/core/theme/app_theme.dart';
import 'package:shared_le_transporteur/core/widgets/app_button.dart';
import 'package:livreur_le_transporteur/pages/intro/onboarding_page.dart';

import 'package:livreur_le_transporteur/models/registration_data.dart';

class AnalyseEncoursPage extends StatelessWidget {
  final RegistrationData registrationData;
  const AnalyseEncoursPage({super.key, required this.registrationData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              UnDraw(
                illustration: UnDrawIllustration.processing,
                color: AppColors.secondary, // Orange/Yellow for processing
                height: 200.h,
                 placeholder: const Center(child: CircularProgressIndicator()),
                errorWidget: const Icon(Icons.hourglass_empty, color: AppColors.secondary, size: 100),
              ),
              SizedBox(height: 40.h),
              Text(
                "Analyse en cours...",
                style: GoogleFonts.poppins(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                "Votre dossier est en cours d'analyse par nos équipes. Vous serez notifié dès que votre compte sera activé.",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  color: Colors.grey[600],
                ),
              ),
              const Spacer(),
              AppButton(
                text: "Retour à l'accueil",
                onPressed: () {
                   Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const OnboardingPage()),
                      (route) => false,
                    );
                },
              ),
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }
}
