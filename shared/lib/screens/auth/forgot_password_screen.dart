import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_le_transporteur/api/v1/auth_api.dart';
import 'package:shared_le_transporteur/core/theme/app_theme.dart';
import 'package:shared_le_transporteur/core/widgets/app_text_field.dart';
import 'package:shared_le_transporteur/services/notification_service.dart';

/// Écran "Mot de passe oublié" partagé entre les apps client et livreur.
///
/// Flow :
///   Étape 1 – L'utilisateur saisit son email → on appelle POST /api/v1/auth/forgot-password
///   Étape 2 – L'utilisateur saisit le code reçu par mail + son nouveau mot de passe
///             → on appelle POST /api/v1/auth/reset-password
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  // ─── Step 1 ───────────────────────────────────────────────────────────────
  final _emailController = TextEditingController();
  bool _isLoadingEmail = false;

  // ─── Step 2 ───────────────────────────────────────────────────────────────
  final _tokenController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoadingReset = false;

  bool _emailSent = false; // toggles between step 1 and step 2

  @override
  void dispose() {
    _emailController.dispose();
    _tokenController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ─── Actions ──────────────────────────────────────────────────────────────

  Future<void> _sendResetEmail() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      NotificationService().showError('Veuillez saisir votre adresse email.');
      return;
    }

    setState(() => _isLoadingEmail = true);
    try {
      await AuthApi().forgotPassword(email);
      if (mounted) {
        setState(() {
          _isLoadingEmail = false;
          _emailSent = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingEmail = false);
        NotificationService().showError(e);
      }
    }
  }

  Future<void> _resetPassword() async {
    final token = _tokenController.text.trim();
    final newPwd = _newPasswordController.text;
    final confirmPwd = _confirmPasswordController.text;
    final email = _emailController.text.trim();

    if (token.isEmpty || newPwd.isEmpty || confirmPwd.isEmpty) {
      NotificationService().showError('Veuillez remplir tous les champs.');
      return;
    }
    if (newPwd != confirmPwd) {
      NotificationService().showError('Les mots de passe ne correspondent pas.');
      return;
    }
    if (newPwd.length < 8) {
      NotificationService().showError('Le mot de passe doit contenir au moins 8 caractères.');
      return;
    }

    setState(() => _isLoadingReset = true);
    try {
      await AuthApi().resetPassword(email, token, newPwd);
      if (mounted) {
        setState(() => _isLoadingReset = false);
        NotificationService().showSuccessDialog(
          title: 'Mot de passe réinitialisé',
          message: 'Votre mot de passe a été modifié avec succès. Vous pouvez maintenant vous connecter.',
          onConfirm: () => Navigator.of(context).pop(),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingReset = false);
        NotificationService().showError(e);
      }
    }
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 20.sp),
          onPressed: () {
            if (_emailSent) {
              // Retour à l'étape 1 sans quitter l'écran
              setState(() => _emailSent = false);
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.08, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
            child: _emailSent ? _buildStep2() : _buildStep1(),
          ),
        ),
      ),
    );
  }

  // ── Step 1 : email ──────────────────────────────────────────────────────

  Widget _buildStep1() {
    return Column(
      key: const ValueKey('step1'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 12.h),

        // Icon
        Container(
          width: 64.w,
          height: 64.w,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.lock_reset_rounded, color: AppColors.primary, size: 32.sp),
        ),
        SizedBox(height: 24.h),

        Text(
          'Mot de passe oublié ?',
          style: GoogleFonts.poppins(
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.text,
          ),
        ),
        SizedBox(height: 10.h),
        Text(
          'Entrez votre adresse email. Nous vous enverrons un code pour réinitialiser votre mot de passe.',
          style: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.grey[600]),
        ),
        SizedBox(height: 32.h),

        AppTextField(
          controller: _emailController,
          hintText: 'Adresse email',
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        SizedBox(height: 28.h),

        SizedBox(
          width: double.infinity,
          height: 50.h,
          child: _isLoadingEmail
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton(
                  onPressed: _sendResetEmail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'Envoyer le code',
                    style: GoogleFonts.poppins(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
        ),
        SizedBox(height: 40.h),
      ],
    );
  }

  // ── Step 2 : token + nouveau mot de passe ────────────────────────────────

  Widget _buildStep2() {
    return Column(
      key: const ValueKey('step2'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 12.h),

        // Icon
        Container(
          width: 64.w,
          height: 64.w,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.mark_email_read_outlined, color: AppColors.primary, size: 32.sp),
        ),
        SizedBox(height: 24.h),

        Text(
          'Vérifiez votre email',
          style: GoogleFonts.poppins(
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.text,
          ),
        ),
        SizedBox(height: 10.h),
        RichText(
          text: TextSpan(
            text: 'Un code a été envoyé à ',
            style: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.grey[600]),
            children: [
              TextSpan(
                text: _emailController.text.trim(),
                style: GoogleFonts.poppins(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
              ),
              TextSpan(
                text: '. Saisissez-le ci-dessous avec votre nouveau mot de passe.',
                style: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        SizedBox(height: 32.h),

        AppTextField(
          controller: _tokenController,
          hintText: 'Code de réinitialisation',
          prefixIcon: Icons.vpn_key_outlined,
          keyboardType: TextInputType.text,
        ),
        SizedBox(height: 16.h),

        AppTextField(
          controller: _newPasswordController,
          hintText: 'Nouveau mot de passe',
          prefixIcon: Icons.lock_outline,
          isPassword: true,
        ),
        SizedBox(height: 16.h),

        AppTextField(
          controller: _confirmPasswordController,
          hintText: 'Confirmer le mot de passe',
          prefixIcon: Icons.lock_outline,
          isPassword: true,
        ),
        SizedBox(height: 28.h),

        SizedBox(
          width: double.infinity,
          height: 50.h,
          child: _isLoadingReset
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton(
                  onPressed: _resetPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'Réinitialiser le mot de passe',
                    style: GoogleFonts.poppins(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
        ),

        SizedBox(height: 16.h),

        // Renvoyer le code
        Center(
          child: TextButton(
            onPressed: _isLoadingReset ? null : _sendResetEmail,
            child: Text(
              'Renvoyer le code',
              style: GoogleFonts.poppins(
                fontSize: 13.sp,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        SizedBox(height: 40.h),
      ],
    );
  }
}
