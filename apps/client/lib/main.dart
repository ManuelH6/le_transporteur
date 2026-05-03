import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:client_le_transporteur/pages/splash_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_le_transporteur/services/notification_service.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
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
      designSize: const Size(360, 800), // Standard Android design size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context , child) {
        return MaterialApp(
          title: 'Le Transporteur Client',
          debugShowCheckedModeBanner: false,
          scaffoldMessengerKey: NotificationService().messengerKey,
          navigatorKey: NotificationService().navigatorKey,
          theme: ThemeData(
            primarySwatch: Colors.orange,
            scaffoldBackgroundColor: Colors.white,
            useMaterial3: true,
          ),
          home: const SplashScreen(),
        );
      },
    );
  }
}
