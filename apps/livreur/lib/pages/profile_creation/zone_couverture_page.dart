import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ms_undraw/ms_undraw.dart';
import 'package:shared_le_transporteur/core/theme/app_theme.dart';
import 'package:shared_le_transporteur/core/widgets/app_button.dart';
import 'package:livreur_le_transporteur/pages/profile_creation/moyen_transport_page.dart';
import 'package:livreur_le_transporteur/models/registration_data.dart';

class ZoneCouverturePage extends StatefulWidget {
  final RegistrationData registrationData;

  const ZoneCouverturePage({super.key, required this.registrationData});

  @override
  State<ZoneCouverturePage> createState() => _ZoneCouverturePageState();
}

class _ZoneCouverturePageState extends State<ZoneCouverturePage> {
  bool _acceptedTerms = false;
  String? _selectedCity;
  final List<String> _cities = [
    'Benin - Cotonou',
    'Benin - Porto-Novo',
    'Benin - Parakou',
    'Benin - Abomey-Calavi',
    'Benin - Bohicon',
    'Benin - Natitingou',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 20.sp),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              SizedBox(height: 10.h),
              Text(
                "Augmentez vos profits\navec le transporteur",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
              SizedBox(height: 30.h),
              Expanded(
                child: UnDraw(
                  illustration: UnDrawIllustration.investing,
                  color: AppColors.primary,
                  height: 200.h,
                  placeholder: const Center(child: CircularProgressIndicator()),
                  errorWidget: const Icon(Icons.error_outline, color: Colors.red),
                ),
              ),
              SizedBox(height: 30.h),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Votre zone de couverture",
                  style: GoogleFonts.poppins(
                     fontSize: 12.sp,
                     color: Colors.grey[600],
                     fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8.r),
                   border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCity,
                    hint: Text(
                      "Sélectionnez une ville",
                      style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.grey),
                    ),
                    isExpanded: true,
                    items: _cities.map((String city) {
                      return DropdownMenuItem<String>(
                        value: city,
                        child: Text(
                          city,
                          style: GoogleFonts.poppins(fontSize: 14.sp, color: AppColors.text),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedCity = newValue;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 24.w,
                    height: 24.h,
                    child: Checkbox(
                      value: _acceptedTerms,
                      activeColor: AppColors.primary,
                      onChanged: (bool? value) {
                        setState(() {
                          _acceptedTerms = value ?? false;
                        });
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        text: "En continuant vous acceptez nos ",
                        style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.black),
                        children: [
                          TextSpan(
                            text: "politiques de confidentialité",
                            style: GoogleFonts.poppins(
                              fontSize: 12.sp, 
                              color: AppColors.primary,
                              decoration: TextDecoration.underline,
                              decorationColor: AppColors.primary,
                            ),
                          ),
                          TextSpan(text: " et nos "),
                          TextSpan(
                            text: "conditions d'utilisation",
                            style: GoogleFonts.poppins(
                              fontSize: 12.sp, 
                              color: AppColors.primary,
                              decoration: TextDecoration.underline,
                               decorationColor: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30.h),
              AppButton(
                text: "Continuer",
                onPressed: (_selectedCity != null && _acceptedTerms)
                    ? () {
                        widget.registrationData.zone = _selectedCity;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MoyenTransportPage(registrationData: widget.registrationData),
                          ),
                        );
                      }
                    : null, // Disabled if not selected or checked
              ),
              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }
}
