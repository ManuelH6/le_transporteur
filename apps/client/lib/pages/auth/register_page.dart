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
import 'package:client_le_transporteur/pages/auth/login_page.dart';
import 'package:client_le_transporteur/pages/home/client_home_page.dart';


class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  void _register() {
    setState(() => _isLoading = true);
    
    // Simulate API Call & OTP Flow
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpVerificationScreen(
              phoneNumber: _phoneController.text,
              onVerified: (otp) {
                 Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const ClientHomePage()),
                    (route) => false,
                 );
              },
              onResend: () {
                // Handle resend logic
              },
            ),
          ),
        );

      }
    });
  }

  @override
  Widget build(BuildContext context) {
     return Scaffold(
      body: Stack(
        children: [
          Container(color: Colors.white),

          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 20.h),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                       icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                       onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  
                  // Header Image/Illustration
                   Container(
                    height: 180.h,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16.r),
                          child: AppImage(assetPath: AppAssets.backgroundLivreurColis, fit: BoxFit.cover),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16.r),
                            color: Colors.black.withOpacity(0.3),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            "Inscrivez-vous",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30.h),

                  AppTextField(controller: _nameController, hintText: "Nom et prénom", prefixIcon: Icons.person),
                  SizedBox(height: 12.h),
                  AppTextField(controller: _phoneController, hintText: "Numéro de téléphone", prefixIcon: Icons.phone, keyboardType: TextInputType.phone),
                  SizedBox(height: 12.h),
                  AppTextField(controller: _passwordController, hintText: "Mot de passe", prefixIcon: Icons.lock_outline, isPassword: true),
                  SizedBox(height: 12.h),
                  AppTextField(controller: _confirmPasswordController, hintText: "Confirmer mot de passe", prefixIcon: Icons.lock_outline, isPassword: true),
                  
                  SizedBox(height: 30.h),
                   
                  _isLoading 
                    ? const Center(child: CircularProgressIndicator())
                    : AppButton(
                        text: "S'inscrire",
                        onPressed: _register,
                      ),
                  
                  SizedBox(height: 24.h),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Vous avez déjà un compte ? ", style: GoogleFonts.poppins(color: Colors.grey)),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
                        },
                        child: Text(
                          "Se connecter",
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
