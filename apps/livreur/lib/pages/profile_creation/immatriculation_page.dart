import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ms_undraw/ms_undraw.dart';
import 'package:shared_le_transporteur/core/theme/app_theme.dart';
import 'package:shared_le_transporteur/core/widgets/app_button.dart';
import 'package:shared_le_transporteur/core/widgets/app_text_field.dart';
import 'package:livreur_le_transporteur/pages/profile_creation/immatriculation_validee_page.dart';

import 'package:livreur_le_transporteur/models/registration_data.dart';

class ImmatriculationPage extends StatefulWidget {
  final RegistrationData registrationData;
  const ImmatriculationPage({super.key, required this.registrationData});

  @override
  State<ImmatriculationPage> createState() => _ImmatriculationPageState();
}

class _ImmatriculationPageState extends State<ImmatriculationPage> {
  final _formKey = GlobalKey<FormState>();
  final _plaqueController = TextEditingController();
  final _chassisController = TextEditingController();
  final _carteGriseController = TextEditingController();
  final _marqueController = TextEditingController();
  final _modeleController = TextEditingController();

  @override
  void dispose() {
    _plaqueController.dispose();
    _chassisController.dispose();
    _carteGriseController.dispose();
    _marqueController.dispose();
    _modeleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Informations du véhicule",
           style: GoogleFonts.poppins(
             fontSize: 18.sp,
             fontWeight: FontWeight.w600,
             color: AppColors.text,
           ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 20.sp),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              children: [
                SizedBox(height: 20.h),
                Text(
                  "Fournissez les informations de votre véhicule",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 20.h),
                SizedBox(
                  height: 120.h,
                  child: UnDraw(
                    illustration: UnDrawIllustration.order_ride,
                    color: AppColors.primary,
                    placeholder: const Center(child: CircularProgressIndicator()),
                    errorWidget: const Icon(Icons.error_outline, color: Colors.red),
                  ),
                ),
                SizedBox(height: 20.h),
                _buildUploadButton("Photo de la Carte Grise"),
                SizedBox(height: 20.h),
                AppTextField(
                  controller: _plaqueController,
                  hintText: "Numéro de plaque",
                  prefixIcon: Icons.numbers,
                ),
                SizedBox(height: 12.h),
                AppTextField(
                  controller: _chassisController,
                  hintText: "Numéro du chassis",
                  prefixIcon: Icons.confirmation_number_outlined,
                ),
                SizedBox(height: 12.h),
                AppTextField(
                  controller: _carteGriseController,
                  hintText: "Numéro de la carte grise",
                  prefixIcon: Icons.document_scanner_outlined,
                ),
                SizedBox(height: 12.h),
                AppTextField(
                  controller: _marqueController,
                  hintText: "Marque du véhicule",
                  prefixIcon: Icons.directions_car_outlined,
                ),
                SizedBox(height: 12.h),
                AppTextField(
                  controller: _modeleController,
                  hintText: "Modèle du véhicule",
                  prefixIcon: Icons.car_repair_outlined,
                ),
                SizedBox(height: 30.h),
                AppButton(
                  text: "Soumettre",
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      widget.registrationData.plaqueImmatriculation = _plaqueController.text;
                      widget.registrationData.numeroChassis = _chassisController.text;
                      widget.registrationData.numeroCarteGrise = _carteGriseController.text;
                      widget.registrationData.marqueVehicule = _marqueController.text;
                      widget.registrationData.modeleVehicule = _modeleController.text;

                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ImmatriculationValideePage(registrationData: widget.registrationData)),
                      );
                    }
                  },
                ),
                SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUploadButton(String label) {
    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: Icon(Icons.cloud_upload_outlined, color: AppColors.primary, size: 24.sp),
        label: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            color: AppColors.text,
            fontWeight: FontWeight.w500,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.grey.shade300),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.symmetric(horizontal: 20.w),
        ),
      ),
    );
  }
}
