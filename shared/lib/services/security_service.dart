import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';

class SecurityService {
  static final SecurityService _instance = SecurityService._internal();
  factory SecurityService() => _instance;
  SecurityService._internal();

  final LocalAuthentication _auth = LocalAuthentication();
  static const String _boxName = 'security_settings';
  static const String _keyEnabled = 'app_lock_enabled';
  static const String _keyBiometric = 'biometric_enabled';
  static const String _keyPin = 'app_pin';

  Future<void> init() async {
    await Hive.openBox(_boxName);
  }

  bool get isLockEnabled => Hive.box(_boxName).get(_keyEnabled, defaultValue: false);
  bool get isBiometricEnabled => Hive.box(_boxName).get(_keyBiometric, defaultValue: false);
  String? get pinCode => Hive.box(_boxName).get(_keyPin);

  Future<void> setLockEnabled(bool enabled) async {
    await Hive.box(_boxName).put(_keyEnabled, enabled);
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    await Hive.box(_boxName).put(_keyBiometric, enabled);
  }

  Future<void> setPinCode(String pin) async {
    await Hive.box(_boxName).put(_keyPin, pin);
  }

  Future<bool> canCheckBiometrics() async {
    try {
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool canAuthenticate = canAuthenticateWithBiometrics || await _auth.isDeviceSupported();
      
      if (!canAuthenticate) return false;

      final List<BiometricType> availableBiometrics = await _auth.getAvailableBiometrics();
      return availableBiometrics.isNotEmpty;
    } on PlatformException catch (e) {
      debugPrint("Error checking biometrics: $e");
      return false;
    }
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } on PlatformException catch (_) {
      return <BiometricType>[];
    }
  }

  Future<bool> authenticate() async {
    if (!isLockEnabled || !isBiometricEnabled) return false;
    
    try {
      return await _auth.authenticate(
        localizedReason: 'Veuillez vous authentifier pour accéder à votre espace de travail',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
        authMessages: const [
          AndroidAuthMessages(
            signInTitle: 'Authentification requise',
            cancelButton: 'Annuler',
          ),
          IOSAuthMessages(
            cancelButton: 'Annuler',
          ),
        ],
      );
    } on PlatformException catch (_) {
      return false;
    }
  }
}
