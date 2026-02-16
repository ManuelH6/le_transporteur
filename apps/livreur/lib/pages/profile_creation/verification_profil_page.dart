import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_le_transporteur/core/constants/assets.dart';
import 'package:shared_le_transporteur/core/theme/app_theme.dart';
import 'package:shared_le_transporteur/core/widgets/app_button.dart';
import 'package:livreur_le_transporteur/pages/profile_creation/piece_identite_page.dart';
import 'package:livreur_le_transporteur/models/registration_data.dart';

class VerificationProfilPage extends StatelessWidget {
  final RegistrationData registrationData;

  const VerificationProfilPage({super.key, required this.registrationData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Vérification de profil",
           style: GoogleFonts.poppins(
             fontSize: 18.sp,
             fontWeight: FontWeight.w600,
             color: AppColors.text,
           ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 20.sp),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          child: Column(
            children: [
               Center(
                 child: Container(
                  width: 100.w,
                  height: 100.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: registrationData.photoProfilePath != null 
                          ? FileImage(File(registrationData.photoProfilePath!)) as ImageProvider
                          : const AssetImage(AppAssets.backgroundMotoLivreur), // Fallback
                      fit: BoxFit.cover,
                    ),
                    border: Border.all(color: AppColors.primary, width: 2),
                  ),
                 ),
               ),
               SizedBox(height: 30.h),
               _buildInfoItem("Nom Complet", registrationData.nomComplet ?? "N/A"),
               _buildInfoItem("Email", registrationData.email ?? "N/A"),
               _buildInfoItem("Téléphone", registrationData.telephone ?? "N/A"), // Assuming phone is stored
               _buildInfoItem("Zone", registrationData.zone ?? "Non définie"),
               _buildInfoItem("Véhicule", registrationData.vehiculeType?.toUpperCase() ?? "Non défini"),
               
               SizedBox(height: 40.h),
               AppButton(
                text: "Continuer vers l'identité",
                onPressed: () {
                   Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PieceIdentitePage()),
                    );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
        ],
      ),
    );
  }
}
