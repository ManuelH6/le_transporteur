import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_le_transporteur/core/theme/app_theme.dart';
import 'package:shared_le_transporteur/core/widgets/app_button.dart';
import 'package:shared_le_transporteur/core/widgets/app_text_field.dart';
import 'package:shared_le_transporteur/core/widgets/app_image.dart';
import 'package:shared_le_transporteur/core/constants/assets.dart';
import 'package:client_le_transporteur/pages/auth/login_page.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:shared_le_transporteur/screens/auth/unavailable_country_screen.dart';
import 'package:shared_le_transporteur/api/v1/auth_api.dart';
import 'package:shared_le_transporteur/services/notification_service.dart';


class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController(); // New
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String _selectedIsoCode = 'BJ';
  String _selectedGender = 'other'; // default
  PhoneNumber number = PhoneNumber(isoCode: 'BJ');

  final List<Map<String, String>> _genders = [
    {'display': 'Homme', 'value': 'man'},
    {'display': 'Femme', 'value': 'women'},
    {'display': 'Autre', 'value': 'other'},
  ];

  void _register() async { // Added async
    if (['CI', 'NG', 'GH'].contains(_selectedIsoCode)) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UnavailableCountryScreen(countryCode: _selectedIsoCode),
        ),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      NotificationService().showError('Les mots de passe ne correspondent pas');
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      final authApi = AuthApi();
      await authApi.register(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        phoneNumber: _phoneController.text,
        countryCode: _selectedIsoCode,
        genderrole: _selectedGender,
        signupIntent: 'client',
      );

      if (mounted) {
        setState(() => _isLoading = false);
        NotificationService().showSuccessDialog(
          title: "Inscription réussie",
          message: "Veuillez consulter votre boîte mail pour valider votre compte avant de vous connecter.",
          onConfirm: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
              (route) => false,
            );
          },
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        NotificationService().showError(e);
      }
    }
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
                   SizedBox(
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
                            color: Colors.black.withValues(alpha: 0.3),
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
                  AppTextField(
                    controller: _emailController,
                    hintText: "Adresse email",
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 12.h),
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
                        });
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
                      keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                      inputDecoration: InputDecoration(
                        hintText: 'Numéro de téléphone',
                        hintStyle: TextStyle(fontSize: 14.sp),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.only(bottom: 12.h),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButtonFormField<String>(
                        value: _selectedGender,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.people_outline, size: 20.sp, color: Colors.grey),
                          labelText: 'Genre',
                          labelStyle: TextStyle(fontSize: 12.sp, color: Colors.grey),
                        ),
                        items: _genders.map((gender) {
                          return DropdownMenuItem<String>(
                            value: gender['value'],
                            child: Text(gender['display']!, style: TextStyle(fontSize: 14.sp)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedGender = value);
                          }
                        },
                      ),
                    ),
                  ),
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
