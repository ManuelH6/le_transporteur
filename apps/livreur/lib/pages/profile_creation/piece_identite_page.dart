import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ms_undraw/ms_undraw.dart';
import 'package:shared_le_transporteur/core/theme/app_theme.dart';
import 'package:shared_le_transporteur/core/widgets/app_button.dart';
import 'package:shared_le_transporteur/core/widgets/app_text_field.dart';
import 'package:livreur_le_transporteur/pages/profile_creation/identite_validee_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_le_transporteur/core/utils/permission_helper.dart';

import 'package:livreur_le_transporteur/models/registration_data.dart';

class PieceIdentitePage extends StatefulWidget {
  final RegistrationData registrationData;
  const PieceIdentitePage({super.key, required this.registrationData});

  @override
  State<PieceIdentitePage> createState() => _PieceIdentitePageState();
}

class _PieceIdentitePageState extends State<PieceIdentitePage> {
  String? _selectedIdType;
  final List<String> _idTypes = [
    'CIP/CIPR',
    'Passeport',
    'Carte Nationale',
    'Permis de conduire',
  ];
  final TextEditingController _idNumberController = TextEditingController();
  final TextEditingController _ifuController = TextEditingController();


  Future<void> _pickImage(String side) async {
    final hasPermission = await PermissionHelper.requestPermission(
      context,
      permission: Permission.camera,
      title: "Autorisation Caméra",
      description: "Le Transporteur a besoin d'accéder à votre caméra pour prendre en photo votre pièce d'identité.",
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
          if (side == "recto") {
            widget.registrationData.pieceIdentiteRectoPath = pickedFile.path;
          } else {
            widget.registrationData.pieceIdentiteVersoPath = pickedFile.path;
          }
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

  @override
  void dispose() {
    _idNumberController.dispose();
    _ifuController.dispose();
    super.dispose();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Pièce d'identité",
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
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              SizedBox(height: 20.h),
              Text(
                "Veuillez télécharger votre pièce d'identité",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 30.h),
              SizedBox(
                height: 150.h,
                child: UnDraw(
                  illustration: UnDrawIllustration.resume_folder,
                  color: AppColors.primary,
                  placeholder: const Center(child: CircularProgressIndicator()),
                  errorWidget: const Icon(Icons.error_outline, color: Colors.red),
                ),
              ),
              SizedBox(height: 30.h),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Type de pièce",
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
                    value: _selectedIdType,
                    hint: Text(
                      "Sélectionnez le type de pièce",
                      style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.grey),
                    ),
                    isExpanded: true,
                    items: _idTypes.map((String type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(
                          type,
                          style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.black),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedIdType = newValue;
                        widget.registrationData.pieceIdentiteType = newValue;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              AppTextField(
                controller: _idNumberController,
                hintText: "Numéro de la pièce",
                prefixIcon: Icons.badge_outlined,
              ),
              SizedBox(height: 16.h),
              AppTextField(
                controller: _ifuController,
                hintText: "Numéro IFU",
                prefixIcon: Icons.assignment_ind_outlined,
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16.h),

              _buildDatePickerField(
                label: "Date d'expiration",
                value: widget.registrationData.dateExpirationPiece,
                onTap: () => _selectDate(context, (date) {
                  setState(() => widget.registrationData.dateExpirationPiece = date);
                }),
              ),
              SizedBox(height: 20.h),

              _buildUploadButton(
                "Recto de la pièce", 
                widget.registrationData.pieceIdentiteRectoPath != null,
                () => _pickImage("recto"),
              ),
              if (_selectedIdType != 'CIP/CIPR' && _selectedIdType != 'Passeport') ...[
                SizedBox(height: 16.h),
                _buildUploadButton(
                  "Verso de la pièce", 
                  widget.registrationData.pieceIdentiteVersoPath != null,
                  () => _pickImage("verso"),
                ),
              ],
              
              SizedBox(height: 40.h),
              
              AppButton(
                text: "Soumettre",
                onPressed: () {
                   if (_selectedIdType == null) {
                     ScaffoldMessenger.of(context).showSnackBar(
                       const SnackBar(content: Text("Veuillez sélectionner le type de pièce")),
                     );
                     return;
                   }
                   if (_idNumberController.text.trim().isEmpty) {
                     ScaffoldMessenger.of(context).showSnackBar(
                       const SnackBar(content: Text("Veuillez renseigner le numéro de la pièce")),
                     );
                     return;
                   }
                   if (widget.registrationData.pieceIdentiteRectoPath == null) {
                     ScaffoldMessenger.of(context).showSnackBar(
                       const SnackBar(content: Text("Veuillez prendre une photo du recto de la pièce")),
                     );
                     return;
                   }
                   if (_selectedIdType != 'CIP/CIPR' && _selectedIdType != 'Passeport' && 
                       widget.registrationData.pieceIdentiteVersoPath == null) {
                     ScaffoldMessenger.of(context).showSnackBar(
                       const SnackBar(content: Text("Veuillez prendre une photo du verso de la pièce")),
                     );
                     return;
                   }

                   widget.registrationData.pieceIdentiteNumero = _idNumberController.text.trim();
                   widget.registrationData.ifuNumber = _ifuController.text.trim();
                   Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => IdentiteValideePage(registrationData: widget.registrationData)),
                    );
                },
              ),
              SizedBox(height: 40.h),
            ],
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
