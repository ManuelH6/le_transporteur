import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ms_undraw/ms_undraw.dart';
import 'package:shared_le_transporteur/core/theme/app_theme.dart';
import 'package:shared_le_transporteur/core/widgets/app_button.dart';
import 'package:livreur_le_transporteur/pages/profile_creation/identite_validee_page.dart';

import 'package:livreur_le_transporteur/models/registration_data.dart';

class PieceIdentitePage extends StatelessWidget {
  final RegistrationData registrationData;
  const PieceIdentitePage({super.key, required this.registrationData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Pièce d'identité",
           style: GoogleFonts.poppins(
             fontSize: 18.sp,
             fontWeight: FontWeight.w600,
             color: AppColors.text,
           ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 20.sp),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              SizedBox(height: 20.h),
              Text(
                "Veuillez télécharger votre pièce d'identité",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 30.h),
              Expanded(
                child: UnDraw(
                  illustration: UnDrawIllustration.resume_folder,
                  color: AppColors.primary,
                  height: 150.h,
                  placeholder: const Center(child: CircularProgressIndicator()),
                  errorWidget: const Icon(Icons.error_outline, color: Colors.red),
                ),
              ),
              SizedBox(height: 30.h),
              _buildUploadButton("Verso de la pièce"),
              SizedBox(height: 16.h),
              _buildUploadButton("Recto de la pièce"),
              
              const Spacer(),
              
              AppButton(
                text: "Soumettre",
                onPressed: () {
                   Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => IdentiteValideePage(registrationData: registrationData)),
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

  Widget _buildUploadButton(String label) {
    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: Icon(Icons.cloud_upload_outlined, color: AppColors.primary, size: 24.sp),
        label: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            color: AppColors.text,
            fontWeight: FontWeight.w500,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.grey.shade300),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.symmetric(horizontal: 20.w),
        ),
      ),
    );
  }
}
