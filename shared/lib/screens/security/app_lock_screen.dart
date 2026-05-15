import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import 'package:shared_le_transporteur/core/theme/app_theme.dart';
import 'package:shared_le_transporteur/services/security_service.dart';

class AppLockScreen extends StatefulWidget {
  final VoidCallback onAuthenticated;

  const AppLockScreen({super.key, required this.onAuthenticated});

  @override
  State<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends State<AppLockScreen> {
  final _pinController = TextEditingController();
  final _securityService = SecurityService();
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _attemptBiometric();
  }

  Future<void> _attemptBiometric() async {
    if (_securityService.isBiometricEnabled) {
      final success = await _securityService.authenticate();
      if (success) {
        widget.onAuthenticated();
      }
    }
  }

  void _onPinCompleted(String pin) {
    if (pin == _securityService.pinCode) {
      widget.onAuthenticated();
    } else {
      setState(() {
        _error = true;
        _pinController.clear();
      });
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _error = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56.w,
      height: 56.w,
      textStyle: GoogleFonts.poppins(fontSize: 22.sp, color: AppColors.text, fontWeight: FontWeight.bold),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline_rounded, size: 64.sp, color: AppColors.primary),
              SizedBox(height: 24.h),
              Text(
                "Application Verrouillée",
                style: GoogleFonts.poppins(fontSize: 20.sp, fontWeight: FontWeight.bold, color: AppColors.text),
              ),
              SizedBox(height: 8.h),
              Text(
                "Veuillez saisir votre code PIN pour continuer",
                style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.grey[600]),
              ),
              SizedBox(height: 48.h),
              Pinput(
                controller: _pinController,
                length: 4,
                obscureText: true,
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: defaultPinTheme.copyWith(
                  decoration: defaultPinTheme.decoration!.copyWith(
                    border: Border.all(color: AppColors.primary, width: 2),
                  ),
                ),
                errorPinTheme: defaultPinTheme.copyWith(
                  decoration: defaultPinTheme.decoration!.copyWith(
                    border: Border.all(color: Colors.redAccent, width: 2),
                  ),
                ),
                onCompleted: _onPinCompleted,
              ),
              if (_error) ...[
                SizedBox(height: 16.h),
                Text(
                  "Code PIN incorrect",
                  style: GoogleFonts.poppins(color: Colors.redAccent, fontSize: 13.sp, fontWeight: FontWeight.w600),
                ),
              ],
              SizedBox(height: 48.h),
              if (_securityService.isBiometricEnabled)
                IconButton(
                  icon: Icon(Icons.fingerprint, size: 48.sp, color: AppColors.primary),
                  onPressed: _attemptBiometric,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
