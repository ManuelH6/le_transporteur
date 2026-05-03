import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ms_undraw/ms_undraw.dart';
import 'package:shared_le_transporteur/core/theme/app_theme.dart';
import 'package:shared_le_transporteur/core/widgets/app_button.dart';
import 'package:livreur_le_transporteur/pages/profile_creation/immatriculation_page.dart';
import 'package:livreur_le_transporteur/pages/profile_creation/analyse_encours_page.dart';

import 'package:livreur_le_transporteur/models/registration_data.dart';
import 'package:livreur_le_transporteur/services/profile_submission_service.dart';

class IdentiteValideePage extends StatelessWidget {
  final RegistrationData registrationData;
  const IdentiteValideePage({super.key, required this.registrationData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 60.h),
                UnDraw(
                  illustration: UnDrawIllustration.confirmed,
                  color: Colors.green, // Success color
                  height: 200.h,
                  placeholder: const Center(child: CircularProgressIndicator()),
                  errorWidget: const Icon(Icons.check_circle, color: Colors.green, size: 100),
                ),
                SizedBox(height: 40.h),
                Text(
                  "Identité Validée !",
                  style: GoogleFonts.poppins(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  "Vos documents d'identité ont été enregistrés avec succès.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 60.h),
                 AppButton(
                  text: "Continuer",
                  onPressed: () async {
                     if (registrationData.vehiculeType == 'none') {
                       final success = await ProfileSubmissionService.submitProfile(context, registrationData);
                       if (success && context.mounted) {
                         Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => AnalyseEncoursPage(registrationData: registrationData)),
                            (route) => false,
                          );
                       }
                     } else {
                       Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ImmatriculationPage(registrationData: registrationData)),
                        );
                     }
                  },
                ),
                SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
