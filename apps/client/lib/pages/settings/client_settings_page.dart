import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_le_transporteur/core/theme/app_theme.dart';

import 'package:shared_le_transporteur/core/widgets/app_button.dart';
import 'package:client_le_transporteur/pages/splash_screen.dart'; // For logout demo
import 'package:shared_le_transporteur/api/v1/auth_api.dart';
import 'package:shared_le_transporteur/api/v1/api_client.dart';
import 'package:shared_le_transporteur/models/user.dart';
import 'package:shared_le_transporteur/screens/settings/change_password_screen.dart';
import 'package:shared_le_transporteur/screens/settings/notifications_settings_screen.dart';
import 'package:shared_le_transporteur/screens/settings/pdf_viewer_screen.dart';
import 'package:shared_le_transporteur/screens/settings/user_manual_screen.dart';
import 'package:shared_le_transporteur/screens/settings/edit_profile_screen.dart';
import 'package:shared_le_transporteur/screens/settings/legal_documents_screen.dart';
import 'package:shared_le_transporteur/services/report_service.dart';

class ClientSettingsPage extends StatefulWidget {
  const ClientSettingsPage({super.key});

  @override
  State<ClientSettingsPage> createState() => _ClientSettingsPageState();
}

class _ClientSettingsPageState extends State<ClientSettingsPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text("Paramètres", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu, color: AppColors.text, size: 28.sp),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 24.h),
              child: FutureBuilder<User?>(

                  future: ApiClient().user,
                  builder: (context, snapshot) {
                    final user = snapshot.data;
                    final name = user?.name ?? "Chargement...";
                    final phone = user?.phoneNumber ?? "";
                    
                    return Column(
                      children: [
                        CircleAvatar(
                          radius: 40.r,
                          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                          child: const Icon(Icons.person, size: 50, color: AppColors.primary),
                        ),
                        SizedBox(height: 12.h),
                        Text(name, style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.bold)),
                        if (phone.isNotEmpty) 
                          Text(phone, style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.grey)),
                        SizedBox(height: 8.h),
                        OutlinedButton(
                          onPressed: () async {
                            if (user != null) {
                              final updated = await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => EditProfileScreen(user: user)),
                              );
                              if (updated == true) {
                                setState(() {}); // Rafraîchir les infos
                              }
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 24.w),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
                          ),
                          child: Text("Modifier le profil", style: GoogleFonts.poppins(fontSize: 12.sp)),
                        ),
                      ],
                    );
                  },
                ),
              ),
            
            SizedBox(height: 12.h),
            
            // Settings Groups
            // _buildSettingsGroup([
            //   _buildSettingsItem(Icons.payment, "Moyens de paiement", "Visa, Mobile Money", onTap: () {}),
            //   _buildSettingsItem(Icons.location_on_outlined, "Adresses enregistrées", "Domicile, Bureau", onTap: () {}),
            // ]),
            // SizedBox(height: 12.h),
            
            _buildSettingsGroup([
              _buildSettingsItem(
                Icons.picture_as_pdf_outlined, 
                "Mon rapport d'activité", 
                "Récapitulatif de mes courses",
                onTap: () => ReportService().generateAndShareReport(context, isCourier: false),
              ),
              _buildSettingsItem(
                Icons.notifications_none, 
                "Notifications", 
                "Configuration des alertes",
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsSettingsScreen())),
              ),
              _buildSettingsItem(
                Icons.security, 
                "Sécurité", 
                "Modifier mon mot de passe",
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ChangePasswordScreen())),
              ),
            ]),
            
            SizedBox(height: 12.h),
            
            _buildSettingsGroup([
              _buildSettingsItem(
                Icons.help_outline, 
                "Aide & Support", 
                "Manuel d'utilisation",
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const UserManualScreen())),
              ),
              _buildSettingsItem(
                Icons.gavel_outlined, 
                "Documents légaux", 
                "Mentions légales et confidentialité",
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => LegalDocumentsScreen())),
              ),
              _buildSettingsItem(Icons.info_outline, "À propos", "Version 1.0.0", onTap: () {}),
            ]),
            
            SizedBox(height: 32.h),
            
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: AppButton(
                text: "Se déconnecter",
                backgroundColor: Colors.red[50]!,
                textColor: Colors.red,
                onPressed: () async {
                   await AuthApi().logout(null);
                   if (context.mounted) {
                     Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const SplashScreen()),
                        (route) => false,
                     );
                   }
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

  Widget _buildSettingsItem(IconData icon, String title, String? subtitle, {required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[700]),
      title: Text(title, style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w500)),
      subtitle: subtitle != null ? Text(subtitle, style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.grey)) : null,
      trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
      onTap: onTap,
    );
  }
}

