// apps/admin/lib/pages/auth/admin_register_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_le_transporteur/shared.dart';
import 'package:shared_le_transporteur/api/v1/auth_api.dart';
import 'package:shared_le_transporteur/services/notification_service.dart';

class AdminRegisterPage extends StatefulWidget {
  const AdminRegisterPage({super.key});

  @override
  State<AdminRegisterPage> createState() => _AdminRegisterPageState();
}

class _AdminRegisterPageState extends State<AdminRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  void _handleRegister() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      NotificationService().showError("Les mots de passe ne correspondent pas");
      return;
    }

    setState(() => _isLoading = true);
    try {
      final authApi = AuthApi();
      await authApi.register(
        name: _nameController.text,
        email: _emailController.text,
        phoneNumber: _phoneController.text,
        password: _passwordController.text,
        signupIntent: 'admin', // Use signupIntent as expected by AuthApi
      );

      if (mounted) {
        NotificationService().showSuccess("Compte administrateur créé avec succès !");
        Navigator.pop(context); // Go back to login
      }
    } catch (e) {
      if (mounted) {
        NotificationService().showError(e);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 0.3.sh,
              width: double.infinity,
              child: AppImage(
                assetPath: 'assets/images/background_livreur_colis.jpg',
                fit: BoxFit.cover,
              ),
            ),
            Transform.translate(
              offset: Offset(0, -40.r),
              child: Container(
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(40.r)),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Inscription Admin", style: Theme.of(context).textTheme.displayMedium),
                      SizedBox(height: 24.h),
                      AppTextField(
                        controller: _nameController,
                        hintText: "Nom complet",
                        prefixIcon: Icons.person_outline,
                      ),
                      SizedBox(height: 16.h),
                      AppTextField(
                        controller: _emailController,
                        hintText: "Adresse email",
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      SizedBox(height: 16.h),
                      AppTextField(
                        controller: _phoneController,
                        hintText: "Téléphone",
                        prefixIcon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                      ),
                      SizedBox(height: 16.h),
                      AppTextField(
                        controller: _passwordController,
                        hintText: "Mot de passe",
                        prefixIcon: Icons.lock_outline,
                        isPassword: true,
                      ),
                      SizedBox(height: 16.h),
                      AppTextField(
                        controller: _confirmPasswordController,
                        hintText: "Confirmer mot de passe",
                        prefixIcon: Icons.lock_clock_outlined,
                        isPassword: true,
                      ),
                      SizedBox(height: 32.h),
                      _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : AppButton(
                              text: "Créer mon compte Admin",
                              onPressed: () {
                                if (_formKey.currentState?.validate() ?? false) {
                                  _handleRegister();
                                }
                              },
                            ),
                      SizedBox(height: 24.h),
                      Center(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Déjà un compte ? Se connecter"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
