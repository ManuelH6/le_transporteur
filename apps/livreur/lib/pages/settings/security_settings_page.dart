import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_le_transporteur/core/theme/app_theme.dart';
import 'package:shared_le_transporteur/services/security_service.dart';
import 'package:pinput/pinput.dart';
import 'package:flutter/services.dart';

class SecuritySettingsPage extends StatefulWidget {
  const SecuritySettingsPage({super.key});

  @override
  State<SecuritySettingsPage> createState() => _SecuritySettingsPageState();
}

class _SecuritySettingsPageState extends State<SecuritySettingsPage> {
  final _securityService = SecurityService();
  bool _canCheckBiometrics = false;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    final can = await _securityService.canCheckBiometrics();
    if (mounted) setState(() => _canCheckBiometrics = can);
  }

  void _toggleLock(bool enabled) async {
    HapticFeedback.mediumImpact();
    if (enabled) {
      final pin = await _showPinSetupDialog();
      if (pin != null) {
        await _securityService.setPinCode(pin);
        await _securityService.setLockEnabled(true);
        if (mounted) setState(() {});
      }
    } else {
      await _securityService.setLockEnabled(false);
      await _securityService.setBiometricEnabled(false);
      if (mounted) setState(() {});
    }
  }

  Future<String?> _showPinSetupDialog() async {
    String? pin;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
        title: Text("Définir un code PIN", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: isDark ? AppColors.darkText : AppColors.text)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Ce code sera demandé à l'ouverture de l'application.",
              style: GoogleFonts.poppins(fontSize: 13.sp, color: isDark ? Colors.grey[400] : Colors.grey[600]),
            ),
            SizedBox(height: 24.h),
            Pinput(
              length: 4,
              obscureText: true,
              onCompleted: (val) {
                HapticFeedback.mediumImpact();
                pin = val;
              },
              defaultPinTheme: PinTheme(
                width: 50.w,
                height: 50.w,
                textStyle: GoogleFonts.poppins(fontSize: 20.sp, fontWeight: FontWeight.bold, color: isDark ? AppColors.darkText : AppColors.text),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[850] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Annuler", style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              elevation: 0,
            ),
            child: Text("Valider", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    return pin;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text("Sécurité", style: GoogleFonts.poppins(color: isDark ? AppColors.darkText : AppColors.text, fontWeight: FontWeight.bold, fontSize: 18.sp)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: isDark ? AppColors.darkText : AppColors.text, size: 20.sp),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(24.w),
        children: [
          _buildInfoCard(
            icon: Icons.security_rounded,
            title: "Protection de l'accès",
            description: "Sécurisez l'accès à vos données et à votre portefeuille.",
          ),
          SizedBox(height: 24.h),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                if (!isDark)
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              children: [
                SwitchListTile(
                  title: Text("Verrouillage PIN", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: isDark ? AppColors.darkText : AppColors.text)),
                  subtitle: Text("Demander un code à l'ouverture", style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.grey)),
                  value: _securityService.isLockEnabled,
                  activeColor: AppColors.primary,
                  onChanged: _toggleLock,
                ),
                if (_securityService.isLockEnabled && _canCheckBiometrics) ...[
                  Divider(color: isDark ? Colors.grey[800] : Colors.grey[200], indent: 16, endIndent: 16),
                  SwitchListTile(
                    title: Text("Empreinte / FaceID", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: isDark ? AppColors.darkText : AppColors.text)),
                    subtitle: Text("Authentification biométrique", style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.grey)),
                    value: _securityService.isBiometricEnabled,
                    activeColor: AppColors.primary,
                    onChanged: (val) async {
                      HapticFeedback.lightImpact();
                      await _securityService.setBiometricEnabled(val);
                      setState(() {});
                    },
                  ),
                ],
              ],
            ),
          ),
          if (_securityService.isLockEnabled) ...[
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: () async {
                final pin = await _showPinSetupDialog();
                if (pin != null) {
                  await _securityService.setPinCode(pin);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Code PIN mis à jour avec succès")),
                    );
                  }
                }
              },
              icon: const Icon(Icons.edit_rounded, size: 18),
              label: Text("Modifier le code PIN", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary.withOpacity(0.1),
                foregroundColor: AppColors.primary,
                elevation: 0,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoCard({required IconData icon, required String title, required String description}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 32.sp),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14.sp, color: isDark ? AppColors.darkText : AppColors.text)),
                Text(description, style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.grey[600])),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
