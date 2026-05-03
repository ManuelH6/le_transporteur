import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_le_transporteur/core/theme/app_theme.dart';
import 'package:shared_le_transporteur/core/widgets/app_button.dart';
import 'package:shared_le_transporteur/core/widgets/app_text_field.dart';
import 'package:shared_le_transporteur/core/widgets/app_image.dart';
import 'package:shared_le_transporteur/core/constants/assets.dart';
import 'package:client_le_transporteur/pages/auth/register_page.dart';
import 'package:client_le_transporteur/pages/home/client_home_page.dart';
import 'package:shared_le_transporteur/api/v1/auth_api.dart';
import 'package:shared_le_transporteur/screens/auth/forgot_password_screen.dart';
import 'package:shared_le_transporteur/services/notification_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _login() async {
    setState(() => _isLoading = true);
    
    try {
      final authApi = AuthApi();
      final response = await authApi.login(
        _emailController.text,
        _passwordController.text,
      );

      if (mounted) {
        if (response.user.role != 'client') {
          await authApi.logout(null);
          throw "Ce compte est un compte Livreur. Veuillez utiliser l'application Le Transporteur Livreur.";
        }

        setState(() => _isLoading = false);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const ClientHomePage()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        NotificationService().showError(e, emailForResend: _emailController.text);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image (Optional, or just solid color/gradient like design)
          // The design shows a clean login.
          Container(color: Colors.white),

          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 40.h),
                  // Back Button
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                       icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                       onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  
                  // Header Image/Illustration
                   Container(
                    height: 200.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.r),
                      // Using AppImage with BoxFit.cover needs wrapping it or using a Stack if we want text over it.
                      // Or we can use DecorationImage with AssetImage if paths are correct.
                      // Since AppAssets paths are relative to package, it's safer to use AppImage inside a Stack 
                      // or just stick to the image container if it's meant to be an image.
                      // Here it's a background image for a container with text.
                      // DecorationImage doesn't support package argument easily without full path.
                      // BUT, we know the full path: "packages/shared_le_transporteur/assets/images/..."
                      // Let's use a Stack with AppImage.
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16.r),
                          child: AppImage(assetPath: AppAssets.backgroundMotoLivreur, fit: BoxFit.cover),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16.r),
                            color: Colors.black.withValues(alpha: 0.3),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            "Connectez-vous pour\ncommander votre course",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),


                  SizedBox(height: 40.h),

                  // Form
                  AppTextField(
                    controller: _emailController,
                    hintText: "Adresse email",
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 16.h),
                  AppTextField(
                    controller: _passwordController,
                    hintText: "Mot de passe",
                    prefixIcon: Icons.lock_outline,
                    keyboardType: TextInputType.visiblePassword,
                    isPassword: true,
                  ),
                  
                  // Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ForgotPasswordScreen(),
                          ),
                        );
                      },
                      child: Text(
                        "Mot de passe oublié ?",
                        style: GoogleFonts.poppins(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 24.h),
                  
                  _isLoading 
                    ? const Center(child: CircularProgressIndicator())
                    : AppButton(
                        text: "Se connecter",
                        onPressed: _login,
                      ),
                  
                  SizedBox(height: 24.h),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Pas de compte ? ", style: GoogleFonts.poppins(color: Colors.grey)),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const RegisterPage()));
                        },
                        child: Text(
                          "S'inscrire",
                          style: GoogleFonts.poppins(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                   SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
