import 'package:flutter/material.dart';
import 'package:shared_le_transporteur/api/v1/user_api.dart';
import 'package:shared_le_transporteur/api/v1/livreur_api.dart';
import 'package:livreur_le_transporteur/models/registration_data.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_le_transporteur/core/widgets/error_dialog.dart';
import 'package:shared_le_transporteur/api/v1/api_client.dart';

class ProfileSubmissionService {
  static Future<bool> submitProfile(BuildContext context, RegistrationData data) async {
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final box = Hive.box('livreur_registration');
      await box.put('current', data.toJson());

      final userApi = UserApi();
      final livreurApi = LivreurApi();
      
      final user = await userApi.getMe();
      final userId = user.id;
      
      if (userId == null) {
        throw Exception("ID utilisateur introuvable. Veuillez vous reconnecter.");
      }

      // Submit Profile
      await livreurApi.updateProfile(userId, {
        'vehicleType': data.vehiculeType,
        'motoPlateNumber': data.plaqueImmatriculation?.trim(),
        'motoChassisNumber': data.numeroChassis?.trim(),
        'motoCarteGriseNumber': data.numeroCarteGrise?.trim(),
        'motoBrand': data.marqueVehicule?.trim(),
        'motoModel': data.modeleVehicule?.trim(),
        'idType': data.pieceIdentiteType,
        'idNumber': data.pieceIdentiteNumero?.trim(),
        'ifuNumber': data.ifuNumber?.trim(),
      });


      // Photo upload is disabled for now as per user request
      /*
      if (data.photoProfilePath != null) {
        try {
          await userApi.uploadProfilePhoto(data.photoProfilePath!);
        } catch (e) {
          debugPrint("Erreur lors de l'upload de la photo: $e");
        }
      }
      */

      // Remove loading
      if (context.mounted) Navigator.pop(context);
      return true;
    } catch (e) {
      // Remove loading
      if (context.mounted) Navigator.pop(context);
      
      String message = e.toString();
      if (e is ApiException) {
        message = e.message;
      } else if (message.contains('ApiException:')) {
         message = message.replaceFirst('ApiException:', '').split('(').first.trim();
      }

      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => ErrorDialog(
            title: "Échec de la soumission",
            message: message,
            actionLabel: "Réessayer",
            onAction: () => submitProfile(context, data),
          ),
        );
      }
      return false;
    }
  }
}
