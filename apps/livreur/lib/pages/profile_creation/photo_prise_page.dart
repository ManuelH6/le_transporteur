import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_le_transporteur/core/theme/app_theme.dart';
import 'package:shared_le_transporteur/core/widgets/app_button.dart';
import 'package:livreur_le_transporteur/pages/profile_creation/verification_profil_page.dart';
import 'package:livreur_le_transporteur/models/registration_data.dart';

class PhotoPrisePage extends StatelessWidget {
  final RegistrationData registrationData;
  final String imagePath;

  const PhotoPrisePage({
    super.key,
    required this.registrationData,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
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
               SizedBox(height: 60.h),
              Text(
                "Prenez une photo pour votre profil",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                "Une photo d'identité ou un selfie serait idéal",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 40.h),

              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.r),
                     image: DecorationImage(
                      image: FileImage(File(imagePath)),
                      fit: BoxFit.cover, 
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20.h),

              Text(
                "Votre photo de profil aide les clients à vous reconnaître\n Elle ne peut plus être modifiée une fois envoyée",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 16.h),
              SizedBox(
                width: double.infinity,
                height: 50.h,
                 child: ElevatedButton.icon(
                  onPressed: () {
                     // Retake logic - just pop
                      Navigator.pop(context);
                  },
                  icon: Icon(Icons.camera_alt_outlined, color: Colors.black, size: 24.sp),
                  label: Text(
                    "Reprendre la photo",
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.background,
                    elevation: 0,
                     shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
               AppButton(
                text: "Envoyez",
                onPressed: () {
                   Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VerificationProfilPage(registrationData: registrationData),
                      ),
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
