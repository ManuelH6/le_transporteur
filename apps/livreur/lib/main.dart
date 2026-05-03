import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_le_transporteur/core/theme/app_theme.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_le_transporteur/services/notification_service.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:shared_le_transporteur/api/v1/api_client.dart';
import 'package:livreur_le_transporteur/pages/intro/onboarding_page.dart';
import 'package:livreur_le_transporteur/pages/home/home_page.dart';

import 'package:livreur_le_transporteur/pages/profile_creation/analyse_encours_page.dart';
import 'package:livreur_le_transporteur/pages/profile_creation/zone_couverture_page.dart';
import 'package:livreur_le_transporteur/models/registration_data.dart';
import 'package:shared_le_transporteur/api/v1/user_api.dart';
import 'package:shared_le_transporteur/models/user.dart';
import 'package:shared_le_transporteur/api/v1/livreur_api.dart';
import 'package:shared_le_transporteur/models/livreur_profile.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR', null);
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Hive.initFlutter();
  await Hive.openBox('auth');
  await Hive.openBox('livreur_registration');

  final apiClient = ApiClient();
  final token = await apiClient.token;
  User? user = await apiClient.user;

  // Refresh user data if logged in to get latest status
  if (token != null && user != null) {
    try {
      user = await UserApi().getMe().timeout(const Duration(seconds: 10));

      final authBox = await Hive.openBox('auth');
      await apiClient.saveTokens(token, authBox.get('refreshToken'), user);
    } catch (e) {
      debugPrint("Erreur lors du rafraîchissement de l'utilisateur: $e");
    }
  }

  Widget initialHome;

  if (token != null && user != null && user.role == 'livreur') {
    LivreurProfile? profile;
    try {
      profile = await LivreurApi().getMyProfile();
    } catch (e) {
      // Profile might not exist yet
    }

    final status = (profile?.verificationStatus ?? user.livreurRequestStatus)?.toLowerCase();
    
    // Cache status locally
    final box = Hive.box('livreur_registration');
    if (status != null) {
      await box.put('verification_status', status);
    }
    
    final finalStatus = status ?? box.get('verification_status');

    if (finalStatus == 'approved') {
      initialHome = const HomePage();
    } else if (finalStatus == 'pending' || finalStatus == 'rejected') {
      initialHome = AnalyseEncoursPage(registrationData: RegistrationData());
    } else {
      // status is 'none'
      initialHome = ZoneCouverturePage(
        registrationData: RegistrationData(
          nomComplet: user.name,
          email: user.email,
          telephone: user.phoneNumber,
        ),
      );
    }

  } else {

    initialHome = const OnboardingPage();
  }

  runApp(MyApp(initialHome: initialHome));
}

class MyApp extends StatelessWidget {
  final Widget initialHome;
  const MyApp({super.key, required this.initialHome});

  @override
  Widget build(BuildContext context) {
    // Remove the splash screen after the first build
    FlutterNativeSplash.remove();

    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          scaffoldMessengerKey: NotificationService().messengerKey,
          navigatorKey: NotificationService().navigatorKey,
          title: 'Livreur Le Transporteur',
          theme: AppTheme.theme,
          home: initialHome,
        );
      },
    );
  }
}
