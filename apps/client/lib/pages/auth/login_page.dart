import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_le_transporteur/core/theme/app_theme.dart';
import 'package:shared_le_transporteur/core/widgets/app_button.dart';
import 'package:shared_le_transporteur/core/widgets/app_text_field.dart';
import 'package:shared_le_transporteur/core/widgets/app_image.dart';
import 'package:shared_le_transporteur/core/constants/assets.dart';
import 'package:shared_le_transporteur/models/user_role.dart';
import 'package:shared_le_transporteur/screens/auth/otp_verification_screen.dart';
import 'package:client_le_transporteur/pages/auth/register_page.dart';
import 'package:client_le_transporteur/pages/home/client_home_page.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _login() {
    setState(() => _isLoading = true);
    
    // Simulate API Call
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isLoading = false);
        // Ensure phone number is valid before navigating logic typically
        // Navigate to Home directly for demo or OTP if needed
        // Requirement said Login -> OTP -> Home? Usually OTP is for registration or 2FA.
        // Let's assume standard login for now, or OTP if new device.
        
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const ClientHomePage()),
          (route) => false,
        );
      }
    });
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
                            color: Colors.black.withOpacity(0.3),
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
                    controller: _phoneController,
                    hintText: "Numéro de téléphone",
                    prefixIcon: Icons.phone_android,
                    keyboardType: TextInputType.phone,
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
                      onPressed: () {},
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
