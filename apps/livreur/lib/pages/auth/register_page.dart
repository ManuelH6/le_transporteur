import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:shared_le_transporteur/core/constants/assets.dart';
import 'package:shared_le_transporteur/core/theme/app_theme.dart';
import 'package:shared_le_transporteur/core/widgets/app_text_field.dart';
import 'package:livreur_le_transporteur/models/registration_data.dart';
import 'package:livreur_le_transporteur/pages/profile_creation/zone_couverture_page.dart';
import 'package:shared_le_transporteur/screens/auth/otp_verification_screen.dart';
import 'package:livreur_le_transporteur/pages/auth/login_page.dart';
import 'package:shared_le_transporteur/core/widgets/app_image.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  String initialCountry = 'BJ';
  PhoneNumber number = PhoneNumber(isoCode: 'BJ');

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
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
                // Top Section (Image + Title)
                SizedBox(
                  height: 0.35.sh, // Slightly smaller for register to give more room for fields
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
                             assetPath: AppAssets.backgroundLivreurMotoDeuxPersonnes,
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
                          child: Text(
                            "Inscription",
                            style: GoogleFonts.poppins(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Bottom Section (Form)
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           Text(
                            "Créez votre compte livreur pour rejoindre notre équipe.",
                            style: GoogleFonts.poppins(
                              fontSize: 14.sp,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 24.h),

                          // Name
                          AppTextField(
                            controller: _nameController,
                            hintText: "Nom Complet",
                            prefixIcon: Icons.person_outline,
                          ),
                          SizedBox(height: 16.h),

                          // Phone Number Field
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.08),
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
                                hintText: 'Numéro de téléphone',
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

                          // Email
                          AppTextField(
                            controller: _emailController,
                            hintText: "Adresse email",
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          SizedBox(height: 16.h),

                          // Password
                          AppTextField(
                            controller: _passwordController,
                            hintText: "Mot de passe",
                            prefixIcon: Icons.lock_outline,
                            isPassword: true,
                          ),
                          SizedBox(height: 16.h),

                          // Confirm Password
                          const AppTextField(
                            hintText: "Confirmer mot de passe",
                            prefixIcon: Icons.lock_outline,
                            isPassword: true,
                          ),
                          SizedBox(height: 24.h),

                          // Register Button
                          SizedBox(
                            width: double.infinity,
                            height: 50.h,
                            child: ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  // Create RegistrationData
                                  final registrationData = RegistrationData(
                                    nomComplet: _nameController.text,
                                    email: _emailController.text,
                                    telephone: _phoneController.text, // or full phone from input
                                    password: _passwordController.text,
                                  );

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => OtpVerificationScreen(
                                        phoneNumber: _phoneController.text, // Use actual input
                                        onVerified: (code) {
                                          // Navigate to Profile Creation Flow Step 2
                                          Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => ZoneCouverturePage(registrationData: registrationData),
                                            ),
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
                                "S'inscrire",
                                style: GoogleFonts.poppins(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          
                          SizedBox(height: 16.h),
                          
                          // Login Link
                           Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Vous avez deja un compte ?",
                                style: GoogleFonts.poppins(
                                  fontSize: 12.sp,
                                  color: Colors.grey,
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
                                Navigator.pop(context); // Go back to login
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary.withOpacity(0.1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                "Se connecter",
                                style: GoogleFonts.poppins(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 24.h),
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
