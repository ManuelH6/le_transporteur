import 'package:client_le_transporteur/pages/maps/client_map_page.dart'; // Ensure package name is correct, likely client_le_transporteur or similar.
// Wait, I don't know the package name for client app. 
// I should check pubspec.yaml of client app first to be sure. 
// But let's assume 'client_le_transporteur' based on 'livreur_le_transporteur'.
// Actually, I'll check pubspec first.

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_le_transporteur/screens/splash_screen.dart';

void main() {
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
          title: 'Client App',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: const SplashScreen(useOrangeSplash: false),
        );
      },
    );
  }
}
