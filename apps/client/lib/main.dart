import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:client_le_transporteur/pages/splash_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_le_transporteur/services/notification_service.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_le_transporteur/core/theme/app_theme.dart';
import 'package:shared_le_transporteur/services/theme_service.dart';
import 'package:shared_le_transporteur/services/favorites_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await ThemeService.init();
  await FavoritesService.init();
  await Hive.openBox('lieux');
  await Hive.openBox('distances');
  await Hive.openBox('auth');
  await initializeDateFormatting('fr_FR', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 800),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return ValueListenableBuilder(
          valueListenable: ThemeService.listenable,
          builder: (context, box, _) {
            return MaterialApp(
              title: 'Le Transporteur Client',
              debugShowCheckedModeBanner: false,
              scaffoldMessengerKey: NotificationService().messengerKey,
              navigatorKey: NotificationService().navigatorKey,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: ThemeService.getThemeMode(),
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('fr', 'FR'),
              ],
              locale: const Locale('fr', 'FR'),
              home: const SplashScreen(),
            );
          },
        );
      },
    );
  }
}
