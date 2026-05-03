import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_le_transporteur/core/theme/app_theme.dart';
import 'package:shared_le_transporteur/api/v1/auth_api.dart';
import 'package:shared_le_transporteur/api/v1/user_api.dart';
import 'package:shared_le_transporteur/models/user.dart';
import 'package:livreur_le_transporteur/pages/intro/onboarding_page.dart';
import 'package:shared_le_transporteur/screens/settings/change_password_screen.dart';
import 'package:shared_le_transporteur/screens/settings/edit_profile_screen.dart';
import 'package:shared_le_transporteur/screens/settings/notifications_settings_screen.dart';
import 'package:shared_le_transporteur/screens/settings/pdf_viewer_screen.dart';
import 'package:shared_le_transporteur/screens/settings/user_manual_screen.dart';
import 'package:shared_le_transporteur/screens/settings/legal_documents_screen.dart';
import 'package:shared_le_transporteur/services/report_service.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  User? _user;
  bool _locationData = false;
  Timer? _locationTimer;

  @override
  void initState() {
    super.initState();
    _fetchUser();
    _checkLocationStatus();
    // Refresh location status every 5 seconds to sync with system
    _locationTimer = Timer.periodic(const Duration(seconds: 5), (_) => _checkLocationStatus());
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchUser() async {
    try {
      final user = await UserApi().getMe();
      if (mounted) setState(() => _user = user);
    } catch (e) {}
  }

  Future<void> _checkLocationStatus() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (mounted && _locationData != enabled) {
      setState(() => _locationData = enabled);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0EB),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        child: Column(
          children: [
            _buildAccountSection(),
            SizedBox(height: 16.h),
            _buildReportSection(),
            SizedBox(height: 16.h),
            _buildNotificationsSection(),
            SizedBox(height: 16.h),
            // Language & Region Commented out
            // _buildLanguageRegionSection(),
            // SizedBox(height: 16.h),
            _buildSecuritySection(),
            SizedBox(height: 16.h),
            // Payments Commented out
            // _buildPaymentsSection(),
            // SizedBox(height: 16.h),
            _buildSupportSection(),
            SizedBox(height: 24.h),
            _buildCriticalActions(),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSection() {
    return _buildSection(
      title: "Compte",
      icon: Icons.person,
      children: [
        _buildNavigationTile(
          icon: Icons.edit,
          title: "Modifier le profil",
          onTap: () async {
            if (_user != null) {
              final updated = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditProfileScreen(user: _user!)),
              );
              if (updated == true) _fetchUser();
            }
          },
        ),
        _buildNavigationTile(
          icon: Icons.lock,
          title: "Changer le mot de passe",
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ChangePasswordScreen())),
          showDivider: false,
        ),
      ],
    );
  }

  Widget _buildReportSection() {
    return _buildSection(
      title: "Statistiques & Rapports",
      icon: Icons.bar_chart_rounded,
      children: [
        _buildNavigationTile(
          icon: Icons.picture_as_pdf_rounded,
          title: "Télécharger mon rapport",
          subtitle: "Bilan complet d'activité (PDF)",
          onTap: () => ReportService().generateAndShareReport(context, isCourier: true),
          showDivider: false,
        ),
      ],
    );
  }

  Widget _buildNotificationsSection() {
    return _buildSection(
      title: "Notifications",
      icon: Icons.notifications,
      children: [
        _buildNavigationTile(
          icon: Icons.notifications_active_outlined,
          title: "Gérer les notifications",
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsSettingsScreen())),
          showDivider: false,
        ),
      ],
    );
  }

  Widget _buildSecuritySection() {
    return _buildSection(
      title: "Sécurité & Confidentialité",
      icon: Icons.security,
      children: [
        // 2FA and PIN lock commented out
        _buildSwitchTile(
          icon: Icons.location_on,
          title: "Données de localisation",
          subtitle: "Synchronisé avec le système",
          value: _locationData,
          onChanged: (value) async {
            if (!value) {
               // User wants to disable, but it's system-linked
               ScaffoldMessenger.of(context).showSnackBar(
                 const SnackBar(content: Text("Veuillez désactiver la localisation dans les paramètres de votre smartphone."))
               );
            } else {
               await Geolocator.openLocationSettings();
            }
          },
        ),
        _buildNavigationTile(
          icon: Icons.history,
          title: "Historique d'activité",
          subtitle: "Bientôt disponible",
          onTap: null,
          showDivider: false,
        ),
      ],
    );
  }

  Widget _buildSupportSection() {
    return _buildSection(
      title: "Support & À propos",
      icon: Icons.info,
      children: [
        _buildNavigationTile(
          icon: Icons.help,
          title: "Manuel d'utilisation",
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const UserManualScreen())),
        ),
        _buildNavigationTile(
          icon: Icons.gavel,
          title: "Documents légaux",
          subtitle: "CGU, Confidentialité, Mentions légales",
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => LegalDocumentsScreen())),
        ),
        _buildNavigationTile(
          icon: Icons.info_outline,
          title: "Version de l'app",
          subtitle: "v1.0.0",
          onTap: null,
          showDivider: false,
        ),
      ],
    );
  }

  Widget _buildCriticalActions() {
    return Column(
      children: [
        _buildActionButton(
          icon: Icons.logout,
          title: "Déconnexion",
          color: AppColors.primary,
          onTap: () => _showConfirmDialog(
            "Déconnexion",
            "Êtes-vous sûr de vouloir vous déconnecter ?",
          ),
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 24.sp),
                SizedBox(width: 12.w),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildNavigationTile({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
    bool showDivider = true,
  }) {
    final bool isDisabled = onTap == null && subtitle == "Bientôt disponible";
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Opacity(
            opacity: isDisabled ? 0.5 : 1.0,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              child: Row(
                children: [
                  Icon(icon, color: isDisabled ? Colors.grey : Colors.grey[600], size: 22.sp),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.text,
                          ),
                        ),
                        if (subtitle != null) ...[
                          SizedBox(height: 2.h),
                          Text(
                            subtitle,
                            style: GoogleFonts.poppins(
                              fontSize: 12.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (onTap != null)
                    Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16.sp),
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
          Padding(
            padding: EdgeInsets.only(left: 58.w),
            child: Divider(color: Colors.grey[200], height: 1, thickness: 1),
          ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
          child: Row(
            children: [
              Icon(icon, color: Colors.grey[600], size: 22.sp),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.text,
                      ),
                    ),
                    if (subtitle != null) ...[
                      SizedBox(height: 2.h),
                      Text(
                        subtitle,
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Switch(
                value: value,
                onChanged: onChanged,
                activeColor: AppColors.primary,
              ),
            ],
          ),
        ),
        if (showDivider)
          Padding(
            padding: EdgeInsets.only(left: 58.w),
            child: Divider(color: Colors.grey[200], height: 1, thickness: 1),
          ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22.sp),
            SizedBox(width: 12.w),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showConfirmDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Text(message, style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Annuler", style: GoogleFonts.poppins(color: Colors.grey[600])),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              if (title == "Déconnexion") {
                await AuthApi().logout(null);
                if (mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const OnboardingPage()),
                    (route) => false,
                  );
                }
              }
            },
            child: Text(
              "Confirmer",
              style: GoogleFonts.poppins(color: AppColors.primary, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
