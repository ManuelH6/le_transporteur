// apps/admin/lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_le_transporteur/shared.dart';
import 'package:shared_le_transporteur/screens/splash_screen.dart';
import 'package:shared_le_transporteur/screens/login_screen.dart';
import 'package:admin_le_transporteur/pages/dashboard/dashboard_page.dart';
import 'package:admin_le_transporteur/pages/auth/admin_login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('auth');
  
  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'Le Transporteur - Admin',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.orange,
            useMaterial3: true,
            textTheme: GoogleFonts.outfitTextTheme(),
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.orange,
              primary: const Color(0xFFFF8A00),
            ),
          ),
          initialRoute: '/',
          routes: {
            '/': (context) => const SplashScreen(nextRoute: '/login'),
            '/login': (context) => const AdminLoginPage(),
            '/dashboard': (context) => const DashboardPage(),
          },
        );
      },
    );
  }
}
