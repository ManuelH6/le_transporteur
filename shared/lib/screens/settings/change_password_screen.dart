import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_le_transporteur/api/v1/user_api.dart';
import 'package:shared_le_transporteur/api/v1/api_client.dart';
import 'package:shared_le_transporteur/core/theme/app_theme.dart';
import 'package:shared_le_transporteur/core/widgets/app_button.dart';
import 'package:shared_le_transporteur/services/notification_service.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final apiClient = ApiClient();
      final user = await apiClient.user;
      if (user == null) throw Exception("Session expirée");

      // Based on common practices, we use updateUser or a specific endpoint if it exists
      // For now, following the plan to use updateUser with password field
      await UserApi().updateUser(user.id!, {
        'password': _newPasswordController.text,
      });

      if (mounted) {
        NotificationService().showSuccessDialog(
          title: "Succès",
          message: "Votre mot de passe a été modifié avec succès.",
          onConfirm: () => Navigator.pop(context), // Close screen after OK
        );
      }
    } catch (e) {
      if (mounted) {
        NotificationService().showError(e);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
      appBar: AppBar(
        title: Text(
          "Changer le mot de passe",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkText : AppColors.text,
          ),
        ),
        centerTitle: true,
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: isDark ? Colors.white : AppColors.text, size: 20.sp),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Votre nouveau mot de passe doit être différent de l'ancien.",
                style: GoogleFonts.poppins(fontSize: 14.sp, color: isDark ? Colors.grey[400] : Colors.grey[600]),
              ),
              SizedBox(height: 32.h),
              _buildPasswordField(
                controller: _oldPasswordController,
                label: "Ancien mot de passe",
                obscure: _obscureOld,
                onToggle: () => setState(() => _obscureOld = !_obscureOld),
                isDark: isDark,
              ),
              SizedBox(height: 20.h),
              _buildPasswordField(
                controller: _newPasswordController,
                label: "Nouveau mot de passe",
                obscure: _obscureNew,
                onToggle: () => setState(() => _obscureNew = !_obscureNew),
                isDark: isDark,
              ),
              SizedBox(height: 20.h),
              _buildPasswordField(
                controller: _confirmPasswordController,
                label: "Confirmer le mot de passe",
                obscure: _obscureConfirm,
                onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                isDark: isDark,
                validator: (val) {
                  if (val != _newPasswordController.text) {
                    return "Les mots de passe ne correspondent pas";
                  }
                  return null;
                },
              ),
              SizedBox(height: 40.h),
              AppButton(
                text: "Mettre à jour",
                isLoading: _isLoading,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
    required bool isDark,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14.sp, 
            fontWeight: FontWeight.w500, 
            color: isDark ? Colors.grey[300] : Colors.grey[700],
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          style: GoogleFonts.poppins(fontSize: 15.sp, color: isDark ? Colors.white : Colors.black87),
          decoration: InputDecoration(
            hintText: "••••••••",
            hintStyle: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[400]),
            filled: true,
            fillColor: isDark ? Colors.grey[900] : Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: isDark ? Colors.grey[800]! : Colors.grey[200]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: isDark ? Colors.grey[800]! : Colors.grey[200]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            suffixIcon: IconButton(
              icon: Icon(obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.grey),
              onPressed: onToggle,
            ),
          ),
          validator: validator ?? (val) {
            if (val == null || val.isEmpty) return "Ce champ est obligatoire";
            if (val.length < 6) return "6 caractères minimum";
            return null;
          },
        ),
      ],
    );
  }
}
