import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ms_undraw/ms_undraw.dart';
import 'package:shared_le_transporteur/core/theme/app_theme.dart';
import 'package:shared_le_transporteur/core/widgets/app_button.dart';
import 'package:livreur_le_transporteur/pages/home/home_page.dart';

import 'package:livreur_le_transporteur/models/registration_data.dart';

import 'package:shared_le_transporteur/api/v1/user_api.dart';
import 'package:shared_le_transporteur/api/v1/livreur_api.dart';

class AnalyseEncoursPage extends StatefulWidget {
  final RegistrationData registrationData;
  const AnalyseEncoursPage({super.key, required this.registrationData});

  @override
  State<AnalyseEncoursPage> createState() => _AnalyseEncoursPageState();
}

class _AnalyseEncoursPageState extends State<AnalyseEncoursPage> {
  bool _isSubmitting = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _submitProfile();
  }

  Future<void> _submitProfile() async {
    try {
      final userApi = UserApi();
      final livreurApi = LivreurApi();
      
      // 1. Get current user ID
      // This will now work as we logged in after OTP verification
      final user = await userApi.getMe();
      final userId = user.id;
      
      if (userId == null) {
        throw Exception("ID utilisateur introuvable. Veuillez vous reconnecter.");
      }

      // 2. Submit Profile
      await livreurApi.updateProfile(userId, {
        'motoPlateNumber': widget.registrationData.plaqueImmatriculation?.trim(),
        'motoChassisNumber': widget.registrationData.numeroChassis?.trim(),
        'motoBrand': widget.registrationData.marqueVehicule?.trim(),
        'motoModel': widget.registrationData.modeleVehicule?.trim(),
        'idType': widget.registrationData.pieceIdentiteType,
        'idNumber': widget.registrationData.pieceIdentiteNumero?.trim(), // Using the actual ID document number
      });

      // 3. Upload Profile Photo if any
      if (widget.registrationData.photoProfilePath != null) {
        try {
          await userApi.uploadProfilePhoto(widget.registrationData.photoProfilePath!);
        } catch (e) {
          debugPrint("Erreur lors de l'upload de la photo: $e");
          // Non-critical error, we continue
        }
      }

      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    } catch (e) {
      debugPrint("Erreur lors de la soumission du profil: $e");
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _error = e.toString().replaceFirst('ApiException:', '').trim();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              if (_isSubmitting)
                const CircularProgressIndicator()
              else if (_error != null)
                Column(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 60),
                    SizedBox(height: 16.h),
                    Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
                    SizedBox(height: 16.h),
                    AppButton(text: "Réessayer", onPressed: _submitProfile),
                  ],
                )
              else
                Column(
                  children: [
                    UnDraw(
                      illustration: UnDrawIllustration.processing,
                      color: AppColors.secondary,
                      height: 200.h,
                      placeholder: const Center(child: CircularProgressIndicator()),
                      errorWidget: const Icon(Icons.hourglass_empty, color: AppColors.secondary, size: 100),
                    ),
                    SizedBox(height: 40.h),
                    Text(
                      "Analyse en cours...",
                      style: GoogleFonts.poppins(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      "Votre dossier est en cours d'analyse par nos équipes. Vous serez notifié dès que votre compte sera activé.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              const Spacer(),
              if (!_isSubmitting && _error == null)
                AppButton(
                  text: "Retour à l'accueil",
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const HomePage()),
                      (route) => false,
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
}
