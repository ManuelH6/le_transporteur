import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_le_transporteur/core/theme/app_theme.dart';

class UserManualScreen extends StatelessWidget {
  const UserManualScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Manuel d'utilisation",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.all(24.w),
        children: [
          _buildStep(
            "1",
            "Créez votre compte",
            "Inscrivez-vous en tant que client ou livreur et validez votre email.",
            Icons.person_add_outlined,
          ),
          _buildStep(
            "2",
            "Passez une commande",
            "Indiquez le point de départ, la destination et le type de colis.",
            Icons.shopping_cart_outlined,
          ),
          _buildStep(
            "3",
            "Suivez votre livraison",
            "Suivez en temps réel la position de votre colis sur la carte.",
            Icons.map_outlined,
          ),
          _buildStep(
            "4",
            "Confirmez la réception",
            "Une fois le colis livré, validez la réception et notez le livreur.",
            Icons.check_circle_outline,
          ),
          SizedBox(height: 32.h),
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
            ),
            child: Column(
              children: [
                const Icon(Icons.support_agent, color: AppColors.primary, size: 40),
                SizedBox(height: 12.h),
                Text(
                  "Besoin d'aide supplémentaire ?",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16.sp),
                ),
                SizedBox(height: 8.h),
                Text(
                  "Notre support est disponible 24h/7j pour répondre à vos questions.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.grey[600]),
                ),
                SizedBox(height: 16.h),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                  child: Text("Contacter le support", style: GoogleFonts.poppins(color: Colors.white)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(String number, String title, String description, IconData icon) {
    return Padding(
      padding: EdgeInsets.only(bottom: 24.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              number,
              style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 20, color: AppColors.primary),
                    SizedBox(width: 8.w),
                    Text(
                      title,
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15.sp),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  description,
                  style: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.grey[600], height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
