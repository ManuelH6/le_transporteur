// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_le_transporteur/core/theme/app_theme.dart';
import 'package:shared_le_transporteur/core/widgets/app_button.dart';
import 'package:shared_le_transporteur/core/widgets/app_image.dart';
import 'package:shared_le_transporteur/core/widgets/app_text_field.dart';
import 'package:shared_le_transporteur/core/widgets/legal_notice_widget.dart';

class LoginScreen extends StatefulWidget {
  final String backgroundImage;
  final String title;
  final String nextRoute;
  final TextEditingController? emailController;
  final TextEditingController? passwordController;
  final VoidCallback? onLogin;
  final bool isLoading;

  const LoginScreen({
    super.key,
    required this.backgroundImage,
    required this.title,
    this.nextRoute = '/dashboard',
    this.emailController,
    this.passwordController,
    this.onLogin,
    this.isLoading = false,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Image Section
            SizedBox(
              height: 0.4.sh,
              width: double.infinity,
              child: AppImage(
                assetPath: widget.backgroundImage,
                fit: BoxFit.cover,
              ),
            ),
            // Bottom Form Section
            Transform.translate(
              offset: Offset(0, -40.r),
              child: Container(
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(40.r)),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.title, style: Theme.of(context).textTheme.displayMedium),
                      SizedBox(height: 32.h),
                      AppTextField(
                        controller: widget.emailController,
                        hintText: "Email ou Téléphone",
                        prefixIcon: Icons.email_outlined,
                      ),
                      SizedBox(height: 16.h),
                      AppTextField(
                        controller: widget.passwordController,
                        hintText: "Mot de passe",
                        prefixIcon: Icons.lock_outline,
                        isPassword: true,
                      ),
                      SizedBox(height: 16.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Se rappeler", style: Theme.of(context).textTheme.bodyMedium),
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              "Mot de passe oublié ?",
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.primary),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24.h),
                      widget.isLoading 
                        ? const Center(child: CircularProgressIndicator())
                        : AppButton(
                            text: "Se connecter",
                            onPressed: () {
                              if (_formKey.currentState?.validate() ?? false) {
                                if (widget.onLogin != null) {
                                  widget.onLogin!();
                                }
                              }
                            },
                          ),
                      SizedBox(height: 24.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Pas de compte ? ", style: Theme.of(context).textTheme.bodyMedium),
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              "S'inscrire",
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      const LegalNoticeWidget(),
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

// Example of how to use it in your navigation:
// import 'package:shared_le_transporteur/core/constants/assets.dart';
// Navigator.push(context, MaterialPageRoute(builder: (_) => LoginScreen(
//   backgroundImage: AppAssets.backgroundMotoLivreur,
//   title: "Connectez-vous !\nUne livraison vous attend !!"
// )));
