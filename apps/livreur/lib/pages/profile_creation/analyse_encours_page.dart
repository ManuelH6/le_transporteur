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

import 'package:hive_flutter/hive_flutter.dart';
import 'package:livreur_le_transporteur/pages/profile_creation/zone_couverture_page.dart';


class AnalyseEncoursPage extends StatefulWidget {
  final RegistrationData registrationData;
  const AnalyseEncoursPage({super.key, required this.registrationData});

  @override
  State<AnalyseEncoursPage> createState() => _AnalyseEncoursPageState();
}

class _AnalyseEncoursPageState extends State<AnalyseEncoursPage> {
  bool _isSubmitting = true;
  String? _error;
  String? _status;
  late RegistrationData _data;


  @override
  void initState() {
    super.initState();
    _data = widget.registrationData;
    _initData();
  }

  Future<void> _initData() async {
    // If data is empty (from main.dart), try to load from Hive
    if (_data.pieceIdentiteType == null && _data.plaqueImmatriculation == null) {
      final box = Hive.box('livreur_registration');
      final savedData = box.get('current');
      if (savedData != null) {
        _data = RegistrationData.fromJson(Map<String, dynamic>.from(savedData));
      }
    }

    if (_data.pieceIdentiteType != null || _data.plaqueImmatriculation != null) {
      _submitProfile();
    } else {
      _fetchStatus();
    }
  }

  Future<void> _fetchStatus() async {
    setState(() => _isSubmitting = true);
    try {
      final profile = await LivreurApi().getMyProfile();
      final status = profile.verificationStatus?.toLowerCase();
      
      final box = Hive.box('livreur_registration');
      await box.put('verification_status', status);

      if (mounted) {
        setState(() {
          _status = status;
          _isSubmitting = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _error = e.toString();
        });
      }
    }
  }


  Future<void> _submitProfile() async {
    try {
      // Save data to Hive immediately to ensure we keep the paths
      final box = Hive.box('livreur_registration');
      await box.put('current', _data.toJson());

      final userApi = UserApi();
      final livreurApi = LivreurApi();
      
      // 1. Get current user ID
      final user = await userApi.getMe();
      final userId = user.id;
      
      if (userId == null) {
        throw Exception("ID utilisateur introuvable. Veuillez vous reconnecter.");
      }

      // 2. Submit Profile
      await livreurApi.updateProfile(userId, {
        'vehicleType': _data.vehiculeType,
        'motoPlateNumber': _data.plaqueImmatriculation?.trim(),
        'motoChassisNumber': _data.numeroChassis?.trim(),
        'motoCarteGriseNumber': _data.numeroCarteGrise?.trim(),
        'motoBrand': _data.marqueVehicule?.trim(),
        'motoModel': _data.modeleVehicule?.trim(),
        'idType': _data.pieceIdentiteType,
        'idNumber': _data.pieceIdentiteNumero?.trim(),
      });

      // Photo upload is disabled for now
      /*
      if (_data.photoProfilePath != null) {
        try {
          await userApi.uploadProfilePhoto(_data.photoProfilePath!);
        } catch (e) {
          debugPrint("Erreur lors de l'upload de la photo: $e");
        }
      }
      */

      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _status = 'pending';
        });
        final box = Hive.box('livreur_registration');
        await box.put('verification_status', 'pending');
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
                const Center(child: CircularProgressIndicator())
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
              else if (_status == 'rejected')
                Column(
                  children: [
                    const Icon(Icons.cancel, color: Colors.red, size: 80),
                    SizedBox(height: 24.h),
                    Text(
                      "Profil Rejeté",
                      style: GoogleFonts.poppins(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      "Malheureusement, votre dossier n'a pas été accepté. Veuillez vérifier vos informations et soumettre à nouveau votre demande.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(fontSize: 16.sp, color: Colors.grey[700]),
                    ),
                    SizedBox(height: 32.h),
                    AppButton(
                      text: "Modifier mes informations",
                      onPressed: () {
                        // Go back to the beginning of registration
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => ZoneCouverturePage(registrationData: _data)),
                          (route) => false,
                        );
                      },
                    ),

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
