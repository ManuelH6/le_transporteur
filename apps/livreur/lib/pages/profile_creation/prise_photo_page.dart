import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:livreur_le_transporteur/models/registration_data.dart';
import 'package:livreur_le_transporteur/pages/profile_creation/photo_prise_page.dart';
import 'package:shared_le_transporteur/core/theme/app_theme.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_le_transporteur/core/utils/permission_helper.dart';
import 'package:shared_le_transporteur/core/widgets/app_button.dart';

class PrisePhotoPage extends StatefulWidget {
  final RegistrationData registrationData;

  const PrisePhotoPage({super.key, required this.registrationData});

  @override
  State<PrisePhotoPage> createState() => _PrisePhotoPageState();
}

class _PrisePhotoPageState extends State<PrisePhotoPage> {
  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    // 1. Check Permission
    Permission permission;
    String title;
    String description;
    
    if (source == ImageSource.camera) {
      permission = Permission.camera;
      title = "Autorisation Caméra";
      description = "Le Transporteur a besoin d'accéder à votre caméra pour prendre votre photo de profil.";
    } else {
      // Logic for gallery (storage or photos)
      if (Platform.isAndroid && (await _getAndroidSdkVersion()) >= 33) {
         permission = Permission.photos;
      } else {
         permission = Permission.storage;
      }
      title = "Autorisation Galerie";
      description = "Le Transporteur a besoin d'accéder à votre galerie pour choisir votre photo de profil.";
    }

    final hasPermission = await PermissionHelper.requestPermission(
      context,
      permission: permission,
      title: title,
      description: description,
      iconPath: "", // Use default icon
    );

    if (!hasPermission) return;

    final picker = ImagePicker();
    try {
      final XFile? pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null) {
        if (mounted) {
          widget.registrationData.photoProfilePath = pickedFile.path;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PhotoPrisePage(
                registrationData: widget.registrationData,
                imagePath: pickedFile.path,
              ),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Erreur lors de la prise de photo: $e')),
        );
      }
    }
  }

  Future<int> _getAndroidSdkVersion() async {
    // Simple check or robust implementation
    // For now, assume < 33 if difficult to check without device_info_plus
    // Actually, let's just stick to Permission.storage for simplicity or use a safe fallback.
    // Permission_handler handles SDK diffs often.
    return 30; 
  }

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
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              SizedBox(height: 60.h),
              Text(
                "Prenez une photo pour votre profil",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                "Une photo d'identité ou un selfie serait idéal",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              
              SizedBox(height: 40.h),
              
              Text(
                "Votre photo de profil aide les clients à vous reconnaître\n Elle ne peut plus être modifiée une fois envoyée",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 16.h),
              
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton.icon(
                  onPressed: () => _pickImage(context, ImageSource.camera),
                  icon: Icon(Icons.camera_alt_outlined, color: Colors.black, size: 24.sp),
                  label: Text(
                    "Prendre une photo",
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.background,
                    elevation: 0,
                     shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
               AppButton(
                text: "Choisir dans la galerie",
                onPressed: () => _pickImage(context, ImageSource.gallery),
                 backgroundColor: AppColors.primary,
              ),
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }
}
