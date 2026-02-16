import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:shared_le_transporteur/core/constants/assets.dart';
import 'package:shared_le_transporteur/core/theme/app_theme.dart';
import 'package:shared_le_transporteur/core/widgets/app_text_field.dart';
import 'package:livreur_le_transporteur/pages/home/home_page.dart';
import 'package:shared_le_transporteur/screens/auth/otp_verification_screen.dart';
import 'package:livreur_le_transporteur/pages/auth/register_page.dart';
import 'package:shared_le_transporteur/core/widgets/app_image.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController(); // Assuming password field exists too
  bool _rememberMe = false;
  String initialCountry = 'BJ';
  PhoneNumber number = PhoneNumber(isoCode: 'BJ');

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              children: [
                // Top Section (Image + Text)
                SizedBox(
                  height: 0.45.sh,
                  child: Stack(
                    children: [
                      // Background Image
                      Positioned.fill(
                        child: ColorFiltered(
                          colorFilter: ColorFilter.mode(
                            Colors.black.withOpacity(0.3),
                            BlendMode.darken,
                          ),
                          child: AppImage(
                            assetPath: AppAssets.backgroundMotoLivreur,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      // Overlay Text
                      Positioned(
                        top: 0,
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Connectez-vous",
                                style: GoogleFonts.poppins(
                                  fontSize: 24.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                "Une livraison vous attends !!",
                                style: GoogleFonts.poppins(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Bottom Section (Form) - takes remaining space
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           // Phone Number Field
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: InternationalPhoneNumberInput(
                            onInputChanged: (PhoneNumber number) {
                              print(number.phoneNumber);
                            },
                            onInputValidated: (bool value) {
                              print(value);
                            },
                            selectorConfig: const SelectorConfig(
                              selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                              useEmoji: true,
                            ),
                            ignoreBlank: false,
                            autoValidateMode: AutovalidateMode.disabled,
                            selectorTextStyle: TextStyle(color: Colors.black, fontSize: 14.sp),
                            initialValue: number,
                            textFieldController: _phoneController,
                            formatInput: false,
                             textStyle: TextStyle(fontSize: 14.sp, color: Colors.black),
                            keyboardType:
                                const TextInputType.numberWithOptions(signed: true, decimal: true),
                            inputDecoration: InputDecoration(
                              hintText: 'Numéro de téléphone ...',
                              hintStyle: TextStyle(fontSize: 14.sp),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.only(bottom: 12.h), // Align text
                            ),
                            onSaved: (PhoneNumber number) {
                              print('On Saved: $number');
                            },
                          ),
                        ),
                        SizedBox(height: 16.h),

                        // Password Field
                          AppTextField(
                            controller: _passwordController,
                            hintText: "Mot de passe",
                            prefixIcon: Icons.lock_outline,
                            isPassword: true,
                          ),
                        
                        SizedBox(height: 12.h),

                        // Remember Me & Forgot Password
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  height: 24.h,
                                  width: 24.w,
                                  child: Checkbox(
                                    value: _rememberMe,
                                    onChanged: (value) {
                                      setState(() {
                                        _rememberMe = value!;
                                      });
                                    },
                                    activeColor: AppColors.primary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4.r),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  "se rappeler",
                                  style: GoogleFonts.poppins(
                                    fontSize: 12.sp,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            TextButton(
                              onPressed: () {},
                              child: Text(
                                "Mot de passe oublié ?",
                                style: GoogleFonts.poppins(
                                  fontSize: 12.sp,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                  decorationColor: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 24.h),

                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          height: 50.h,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                 // Login logic simulated
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => OtpVerificationScreen(
                                        phoneNumber: _phoneController.text, // Use actual input
                                        onVerified: (code) {
                                          // Navigate to Home
                                          Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(builder: (context) => const HomePage()),
                                            (route) => false,
                                          );
                                        },
                                        onResend: () {
                                          // Resend logic
                                        },
                                      ),
                                    ),
                                  );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            child: Text(
                              "Se connecter",
                              style: GoogleFonts.poppins(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 20.h),

                        // Register Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Pas de compte ?",
                              style: GoogleFonts.poppins(
                                fontSize: 12.sp,
                                color: Colors.grey,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                         SizedBox(height: 8.h),
                         SizedBox(
                          width: double.infinity,
                          height: 50.h,
                          child: ElevatedButton(
                            onPressed: () {
                               Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const RegisterPage()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary.withOpacity(0.1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              "S'inscrire",
                              style: GoogleFonts.poppins(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20.h),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
