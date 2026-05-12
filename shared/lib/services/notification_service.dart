// shared/lib/services/notification_service.dart

import 'package:flutter/material.dart';
import 'package:shared_le_transporteur/api/v1/api_client.dart';
import 'package:shared_le_transporteur/api/v1/auth_api.dart';
import 'package:shared_le_transporteur/core/widgets/error_dialog.dart';
import 'package:shared_le_transporteur/core/widgets/success_dialog.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final GlobalKey<ScaffoldMessengerState> messengerKey = GlobalKey<ScaffoldMessengerState>();
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  void showError(dynamic error, {String? emailForResend}) {
    String title = "Erreur";
    String message = "Une erreur inattendue est survenue.";
    String? details;
    String? actionLabel;
    VoidCallback? onAction;

    if (error is ApiException) {
      if (error.statusCode == 403) {
        final apiError = error.errorResponse;
        if (apiError != null && apiError.message.toLowerCase().contains('verify')) {
          message = "Veuillez consulter votre boîte mail pour vérifier et activer votre compte avant de vous connecter.";
          title = "Email non vérifié";
          details = apiError.toString();
          
          if (emailForResend != null && emailForResend.isNotEmpty) {
            actionLabel = "Renvoyer l'email";
            onAction = () async {
              try {
                // Must import AuthApi here, or handle it via a callback instead.
                // We'll use AuthApi since it's already in the project.
                await AuthApi().resendVerification(emailForResend);
                showSuccessDialog(
                  title: "Email renvoyé",
                  message: "Un nouveau lien de vérification a été envoyé à $emailForResend.",
                );
              } catch (e) {
                showError(e); // Without emailForResend to avoid loops
              }
            };
          }
        } else {
          message = apiError?.message ?? error.message;
          details = apiError?.toString() ?? error.body;
          title = "Accès refusé (403)";
        }
      } else if (error.statusCode == 401) {
        final apiError = error.errorResponse;
        title = "Connexion échouée";
        if (apiError != null && apiError.message.toLowerCase().contains('invalid')) {
          message = "Email ou mot de passe incorrect.";
        } else {
          message = apiError?.message ?? "Email ou mot de passe incorrect.";
        }
        details = null; // Hide technical details for simple login errors
      } else {
        final apiError = error.errorResponse;
        if (apiError != null) {
          // Check for specific English errors to translate
          if (apiError.message.toLowerCase().contains('verify your email')) {
            message = "Veuillez consulter votre boîte mail pour vérifier et activer votre compte.";
            title = "Email non vérifié";
            
            if (emailForResend != null && emailForResend.isNotEmpty) {
              actionLabel = "Renvoyer l'email";
              onAction = () async {
                try {
                  await AuthApi().resendVerification(emailForResend);
                  showSuccessDialog(
                    title: "Email renvoyé",
                    message: "Un nouveau lien de vérification a été envoyé à $emailForResend.",
                  );
                } catch (e) {
                  showError(e);
                }
              };
            }
          } else if (apiError.message.toLowerCase().contains('already in use')) {
            message = "Cette adresse email est déjà utilisée par un autre compte.";
            title = "Compte déjà existant";
            details = null;
          } else {
            message = apiError.message;
            details = apiError.toString();
          }
        } else {
          message = error.message;
          details = error.body;
        }
        title = "Erreur (${error.statusCode})";
      }
    } else if (error is String) {
      message = error;
    } else {
      String errStr = error.toString().toLowerCase();
      if (errStr.contains('socketexception') || errStr.contains('connection failed') || errStr.contains('timed out')) {
        message = "Impossible de se connecter au serveur. Veuillez vérifier votre connexion internet.";
        title = "Problème de connexion";
      } else {
        message = error.toString();
      }
    }

    final context = navigatorKey.currentContext;
    if (context != null) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => ErrorDialog(
          title: title,
          message: message,
          details: details,
          actionLabel: actionLabel,
          onAction: onAction,
        ),
      );
    } else {
      // Fallback to SnackBar if Navigator context is not available
      messengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 10),
          action: SnackBarAction(label: 'OK', onPressed: () {}, textColor: Colors.white),
        ),
      );
    }
  }

  void showSuccessDialog({
    String title = "Succès",
    required String message,
    VoidCallback? onConfirm,
  }) {
    final context = navigatorKey.currentContext;
    if (context != null) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => SuccessDialog(
          title: title,
          message: message,
          onConfirm: onConfirm,
        ),
      );
    } else {
      showSuccess(message);
      if (onConfirm != null) onConfirm();
    }
  }

  void showSuccess(String message) {
    messengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void showInfo(String message) {
    messengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
