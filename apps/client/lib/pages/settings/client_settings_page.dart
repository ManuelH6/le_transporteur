import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_le_transporteur/core/theme/app_theme.dart';

import 'package:shared_le_transporteur/core/widgets/app_button.dart';
import 'package:client_le_transporteur/pages/splash_screen.dart'; // For logout demo

class ClientSettingsPage extends StatelessWidget {
  const ClientSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text("Paramètres", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 24.h),
              child: Column(
                children: [
                   CircleAvatar(
                     radius: 40.r,
                     backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                     child: const Icon(Icons.person, size: 50, color: AppColors.primary),
                   ),
                   SizedBox(height: 12.h),
                   Text("Jean Doe", style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.bold)),
                   Text("+229 90 00 00 00", style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.grey)),
                   SizedBox(height: 8.h),
                   OutlinedButton(
                     onPressed: () {},
                     style: OutlinedButton.styleFrom(
                       padding: EdgeInsets.symmetric(horizontal: 24.w),
                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
                     ),
                     child: Text("Modifier le profil", style: GoogleFonts.poppins(fontSize: 12.sp)),
                   ),
                ],
              ),
            ),
            
            SizedBox(height: 12.h),
            
            // Settings Groups
            _buildSettingsGroup([
              _buildSettingsItem(Icons.payment, "Moyens de paiement", "Visa, Mobile Money"),
              _buildSettingsItem(Icons.location_on_outlined, "Adresses enregistrées", "Domicile, Bureau"),
            ]),
            
            SizedBox(height: 12.h),
            
            _buildSettingsGroup([
              _buildSettingsItem(Icons.notifications_none, "Notifications", null),
              _buildSettingsItem(Icons.security, "Sécurité", "Mot de passe, Biométrie"),
            ]),
            
            SizedBox(height: 12.h),
            
            _buildSettingsGroup([
              _buildSettingsItem(Icons.help_outline, "Aide & Support", null),
              _buildSettingsItem(Icons.info_outline, "À propos", "Version 1.0.0"),
            ]),
            
            SizedBox(height: 32.h),
            
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: AppButton(
                text: "Se déconnecter",
                backgroundColor: Colors.red[50]!,
                textColor: Colors.red,
                onPressed: () {
                   Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const SplashScreen()),
                      (route) => false,
                   );
                },
              ),
            ),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> items) {
    return Container(
      color: Colors.white,
      child: Column(children: items),
    );
  }

  Widget _buildSettingsItem(IconData icon, String title, String? subtitle) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[700]),
      title: Text(title, style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w500)),
      subtitle: subtitle != null ? Text(subtitle, style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.grey)) : null,
      trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
      onTap: () {},
    );
  }
}

