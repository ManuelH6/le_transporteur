import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:livreur_le_transporteur/pages/splash_screen.dart';
import 'package:shared_le_transporteur/core/theme/app_theme.dart';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_le_transporteur/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('auth');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context , child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          scaffoldMessengerKey: NotificationService().messengerKey,
          navigatorKey: NotificationService().navigatorKey,
          title: 'Livreur Le Transporteur',
          theme: AppTheme.theme, // Use the shared theme
          home: const SplashScreen(),
        );
      },
    );
  }
}
