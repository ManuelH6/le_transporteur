import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:shared_le_transporteur/core/constants/assets.dart';
import 'package:shared_le_transporteur/core/theme/app_theme.dart';
import 'package:shared_le_transporteur/core/widgets/app_text_field.dart';
import 'package:livreur_le_transporteur/models/registration_data.dart';
import 'package:shared_le_transporteur/api/v1/auth_api.dart';
import 'package:shared_le_transporteur/services/notification_service.dart';
import 'package:livreur_le_transporteur/pages/auth/login_page.dart';
import 'package:shared_le_transporteur/screens/auth/unavailable_country_screen.dart';
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
  String _selectedIsoCode = 'BJ';
  String _selectedGender = 'other';
  String _fullPhoneNumber = '';

  final List<Map<String, String>> _genders = [
    {'display': 'Homme', 'value': 'man'},
    {'display': 'Femme', 'value': 'women'},
    {'display': 'Autre', 'value': 'other'},
  ];


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
                            Colors.black.withValues(alpha: 0.3),
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
                              color: AppColors.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: InternationalPhoneNumberInput(
                              onInputChanged: (PhoneNumber number) {
                                setState(() {
                                  _selectedIsoCode = number.isoCode ?? 'BJ';
                                  _fullPhoneNumber = number.phoneNumber ?? '';

                                });
                              },
                              onInputValidated: (bool value) {
                                // Debug: print(value);
                              },
                              countries: const ['BJ', 'TG', 'CG', 'CI', 'NG', 'GH'],
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
                                // Debug: print('On Saved: $number');
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

                          _buildGenderToggle(),
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
                              onPressed: () async {
                                if (['CI', 'NG', 'GH'].contains(_selectedIsoCode)) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => UnavailableCountryScreen(countryCode: _selectedIsoCode),
                                    ),
                                  );
                                  return;
                                }

                                if (_formKey.currentState!.validate()) {
                                  // Create RegistrationData
                                  final registrationData = RegistrationData(
                                    nomComplet: _nameController.text,
                                    email: _emailController.text,
                                    telephone: _fullPhoneNumber.isNotEmpty ? _fullPhoneNumber : _phoneController.text,

                                    password: _passwordController.text,
                                    countryCode: _selectedIsoCode,
                                    genderrole: _selectedGender,
                                  );

                                  try {
                                    final authApi = AuthApi();
                                    await authApi.register(
                                      name: _nameController.text,
                                      email: _emailController.text,
                                      password: _passwordController.text,
                                      phoneNumber: _fullPhoneNumber.isNotEmpty ? _fullPhoneNumber : _phoneController.text,

                                      countryCode: _selectedIsoCode,
                                      genderrole: _selectedGender,
                                      signupIntent: 'livreur',
                                    );

                                    if (mounted) {
                                      NotificationService().showSuccessDialog(
                                        title: "Inscription réussie",
                                        message: "Veuillez consulter votre boîte mail pour valider votre compte avant de vous connecter.",
                                        onConfirm: () {
                                          Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(builder: (context) => LoginPage()),
                                            (route) => false,
                                          );
                                        },
                                      );
                                    }
                                  } catch (e) {
                                    if (mounted) {
                                      NotificationService().showError(e);
                                    }
                                  }
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
                                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
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

  Widget _buildGenderToggle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4.w, bottom: 8.h),
          child: Text(
            "Genre",
            style: GoogleFonts.poppins(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
        ),
        Row(
          children: _genders.map((gender) {
            final isSelected = _selectedGender == gender['value'];
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedGender = gender['value']!),
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : Colors.grey[300]!,
                    ),
                  ),
                  child: Text(
                    gender['display']!,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? Colors.white : Colors.grey[600],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
