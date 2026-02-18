import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_le_transporteur/core/theme/app_theme.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notifNewDeliveries = true;
  bool _notifMessages = true;
  bool _notifAppUpdates = true;
  bool _notifPromotions = false;
  bool _twoFactorAuth = false;
  bool _pinLock = false;
  bool _locationData = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0EB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Paramètres",
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        child: Column(
          children: [
            // Account Section
            _buildAccountSection(),
            SizedBox(height: 16.h),
            
            // Notifications Section
            _buildNotificationsSection(),
            SizedBox(height: 16.h),
            
            // Language & Region Section
            _buildLanguageRegionSection(),
            SizedBox(height: 16.h),
            
            // Security Section
            _buildSecuritySection(),
            SizedBox(height: 16.h),
            
            // Payments Section
            _buildPaymentsSection(),
            SizedBox(height: 16.h),
            
            // Support & About Section
            _buildSupportSection(),
            SizedBox(height: 24.h),
            
            // Critical Actions
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
          onTap: () => _showComingSoon("Modification du profil"),
        ),
        _buildNavigationTile(
          icon: Icons.lock,
          title: "Changer le mot de passe",
          onTap: () => _showComingSoon("Changement de mot de passe"),
        ),
        _buildNavigationTile(
          icon: Icons.phone,
          title: "Numéro de téléphone",
          subtitle: "+237 6XX XXX XXX",
          onTap: () => _showComingSoon("Modification du téléphone"),
        ),
        _buildNavigationTile(
          icon: Icons.email,
          title: "Adresse email",
          subtitle: "sam@example.com",
          onTap: () => _showComingSoon("Modification de l'email"),
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
        _buildSwitchTile(
          icon: Icons.local_shipping,
          title: "Nouvelles livraisons",
          value: _notifNewDeliveries,
          onChanged: (value) => setState(() => _notifNewDeliveries = value),
        ),
        _buildSwitchTile(
          icon: Icons.message,
          title: "Messages clients",
          value: _notifMessages,
          onChanged: (value) => setState(() => _notifMessages = value),
        ),
        _buildSwitchTile(
          icon: Icons.system_update,
          title: "Mises à jour app",
          value: _notifAppUpdates,
          onChanged: (value) => setState(() => _notifAppUpdates = value),
        ),
        _buildSwitchTile(
          icon: Icons.local_offer,
          title: "Promotions",
          value: _notifPromotions,
          onChanged: (value) => setState(() => _notifPromotions = value),
          showDivider: false,
        ),
      ],
    );
  }

  Widget _buildLanguageRegionSection() {
    return _buildSection(
      title: "Langue & Région",
      icon: Icons.language,
      children: [
        _buildNavigationTile(
          icon: Icons.translate,
          title: "Langue",
          subtitle: "Français",
          onTap: () => _showComingSoon("Changement de langue"),
        ),
        _buildNavigationTile(
          icon: Icons.attach_money,
          title: "Devise",
          subtitle: "FCFA",
          onTap: () => _showComingSoon("Changement de devise"),
        ),
        _buildNavigationTile(
          icon: Icons.access_time,
          title: "Fuseau horaire",
          subtitle: "WAT (GMT+1)",
          onTap: () => _showComingSoon("Changement de fuseau horaire"),
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
        _buildSwitchTile(
          icon: Icons.verified_user,
          title: "Authentification 2FA",
          subtitle: "Sécurité renforcée",
          value: _twoFactorAuth,
          onChanged: (value) => setState(() => _twoFactorAuth = value),
        ),
        _buildSwitchTile(
          icon: Icons.pin,
          title: "Verrouillage par code",
          subtitle: "Code PIN à l'ouverture",
          value: _pinLock,
          onChanged: (value) => setState(() => _pinLock = value),
        ),
        _buildSwitchTile(
          icon: Icons.location_on,
          title: "Données de localisation",
          subtitle: "Requis pour les livraisons",
          value: _locationData,
          onChanged: (value) => setState(() => _locationData = value),
        ),
        _buildNavigationTile(
          icon: Icons.history,
          title: "Historique d'activité",
          onTap: () => _showComingSoon("Historique d'activité"),
          showDivider: false,
        ),
      ],
    );
  }

  Widget _buildPaymentsSection() {
    return _buildSection(
      title: "Paiements",
      icon: Icons.payment,
      children: [
        _buildNavigationTile(
          icon: Icons.credit_card,
          title: "Méthode de paiement",
          subtitle: "Mobile Money",
          onTap: () => _showComingSoon("Méthode de paiement"),
        ),
        _buildNavigationTile(
          icon: Icons.receipt_long,
          title: "Historique des paiements",
          onTap: () => _showComingSoon("Historique des paiements"),
        ),
        _buildNavigationTile(
          icon: Icons.description,
          title: "Relevés fiscaux",
          onTap: () => _showComingSoon("Relevés fiscaux"),
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
          title: "Centre d'aide",
          onTap: () => _showComingSoon("Centre d'aide"),
        ),
        _buildNavigationTile(
          icon: Icons.support_agent,
          title: "Contacter le support",
          onTap: () => _showComingSoon("Support"),
        ),
        _buildNavigationTile(
          icon: Icons.article,
          title: "Conditions d'utilisation",
          onTap: () => _showComingSoon("Conditions d'utilisation"),
        ),
        _buildNavigationTile(
          icon: Icons.privacy_tip,
          title: "Politique de confidentialité",
          onTap: () => _showComingSoon("Politique de confidentialité"),
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
        SizedBox(height: 12.h),
        _buildActionButton(
          icon: Icons.delete_forever,
          title: "Supprimer le compte",
          color: const Color(0xFFFF5252),
          onTap: () => _showConfirmDialog(
            "Supprimer le compte",
            "Cette action est irréversible. Êtes-vous sûr ?",
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
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
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
                if (onTap != null)
                  Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16.sp),
              ],
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

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "$feature - À implémenter",
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _showConfirmDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text(
          title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          message,
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Annuler",
              style: GoogleFonts.poppins(color: Colors.grey[600]),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showComingSoon(title);
            },
            child: Text(
              "Confirmer",
              style: GoogleFonts.poppins(
                color: title.contains("Supprimer") 
                    ? const Color(0xFFFF5252) 
                    : AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
