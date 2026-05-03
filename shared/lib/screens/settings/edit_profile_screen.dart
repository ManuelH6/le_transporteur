import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_le_transporteur/core/theme/app_theme.dart';
import 'package:shared_le_transporteur/core/widgets/app_text_field.dart';
import 'package:shared_le_transporteur/core/widgets/app_button.dart';
import 'package:shared_le_transporteur/api/v1/user_api.dart';
import 'package:shared_le_transporteur/models/user.dart';
import 'package:shared_le_transporteur/api/v1/api_client.dart';
import 'package:shared_le_transporteur/services/notification_service.dart';

class EditProfileScreen extends StatefulWidget {
  final User user;
  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);
    _phoneController = TextEditingController(text: widget.user.phoneNumber ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final userApi = UserApi();
        final updatedUser = await userApi.updateUser(widget.user.id!, {
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'phoneNumber': _phoneController.text.trim(),
        });

        // Mettre à jour les données locales
        await ApiClient().saveTokens(
          (await ApiClient().token) ?? '',
          '', // Refresh token non modifié ici
          updatedUser,
        );

        if (mounted) {
          NotificationService().showSuccessDialog(
            title: "Profil mis à jour",
            message: "Vos informations ont été enregistrées avec succès.",
            onConfirm: () => Navigator.pop(context, true),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Modifier le profil", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18.sp)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 50.r,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: Icon(Icons.person, size: 60.sp, color: AppColors.primary),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                      child: Icon(Icons.camera_alt, color: Colors.white, size: 18.sp),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 32.h),
              AppTextField(
                controller: _nameController,
                hintText: "Nom complet",
                prefixIcon: Icons.person_outline,
                validator: (val) => val == null || val.isEmpty ? "Nom requis" : null,
              ),
              SizedBox(height: 16.h),
              AppTextField(
                controller: _emailController,
                hintText: "Email",
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (val) => val == null || !val.contains('@') ? "Email invalide" : null,
              ),
              SizedBox(height: 16.h),
              AppTextField(
                controller: _phoneController,
                hintText: "Téléphone",
                prefixIcon: Icons.phone_android_outlined,
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 40.h),
              AppButton(
                text: "Enregistrer les modifications",
                isLoading: _isLoading,
                onPressed: _updateProfile,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
