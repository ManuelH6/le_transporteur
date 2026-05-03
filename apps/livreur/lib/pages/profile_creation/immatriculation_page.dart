import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ms_undraw/ms_undraw.dart';
import 'package:shared_le_transporteur/core/theme/app_theme.dart';
import 'package:shared_le_transporteur/core/widgets/app_button.dart';
import 'package:shared_le_transporteur/core/widgets/app_text_field.dart';
import 'package:livreur_le_transporteur/pages/profile_creation/immatriculation_validee_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_le_transporteur/core/utils/permission_helper.dart';

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
  final _couleurController = TextEditingController();

  Future<void> _selectDate(BuildContext context, Function(String) onDateSelected) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.text,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final formattedDate = "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      onDateSelected(formattedDate);
    }
  }

  Future<void> _pickImage() async {
    final hasPermission = await PermissionHelper.requestPermission(
      context,
      permission: Permission.camera,
      title: "Autorisation Caméra",
      description: "Le Transporteur a besoin d'accéder à votre caméra pour prendre en photo votre carte grise.",
      iconPath: "",
    );

    if (!hasPermission) return;

    final picker = ImagePicker();
    try {
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
      );
      
      if (pickedFile != null) {
        setState(() {
          widget.registrationData.carteGrisePath = pickedFile.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur lors de la prise de photo : $e")),
        );
      }
    }
  }

  @override
  void dispose() {
    _plaqueController.dispose();
    _chassisController.dispose();
    _carteGriseController.dispose();
    _marqueController.dispose();
    _modeleController.dispose();
    _couleurController.dispose();
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
                _buildUploadButton(
                  "Photo de la Carte Grise", 
                  widget.registrationData.carteGrisePath != null,
                  _pickImage
                ),
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
                SizedBox(height: 12.h),
                AppTextField(
                  controller: _couleurController,
                  hintText: "Couleur du véhicule",
                  prefixIcon: Icons.palette_outlined,
                ),
                SizedBox(height: 12.h),
                _buildDatePickerField(
                  label: "Date d'expiration carte grise",
                  value: widget.registrationData.dateExpirationCarteGrise,
                  onTap: () => _selectDate(context, (date) {
                    setState(() => widget.registrationData.dateExpirationCarteGrise = date);
                  }),
                ),
                SizedBox(height: 30.h),
                AppButton(
                  text: "Soumettre",
                  onPressed: () {
                    if (widget.registrationData.carteGrisePath == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Veuillez prendre une photo de la carte grise")),
                      );
                      return;
                    }
                    
                    if (_formKey.currentState!.validate()) {
                      widget.registrationData.plaqueImmatriculation = _plaqueController.text.trim();
                      widget.registrationData.numeroChassis = _chassisController.text.trim();
                      widget.registrationData.numeroCarteGrise = _carteGriseController.text.trim();
                      widget.registrationData.marqueVehicule = _marqueController.text.trim();
                      widget.registrationData.modeleVehicule = _modeleController.text.trim();
                      widget.registrationData.vehiculeCouleur = _couleurController.text.trim();

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

  Widget _buildUploadButton(String label, bool isUploaded, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(
          isUploaded ? Icons.check_circle : Icons.cloud_upload_outlined, 
          color: isUploaded ? Colors.green : AppColors.primary, 
          size: 24.sp
        ),
        label: Text(
          isUploaded ? "Photo enregistrée" : label,
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            color: isUploaded ? Colors.green : AppColors.text,
            fontWeight: FontWeight.w500,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: isUploaded ? Colors.green : Colors.grey.shade300),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.symmetric(horizontal: 20.w),
        ),
      ),
    );
  }

  Widget _buildDatePickerField({required String label, String? value, required VoidCallback onTap}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12.sp,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        InkWell(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_outlined, color: AppColors.primary, size: 20.sp),
                SizedBox(width: 12.w),
                Text(
                  value ?? "Sélectionnez la date",
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    color: value != null ? Colors.black : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
