import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_le_transporteur/core/theme/app_theme.dart';
import 'package:shared_le_transporteur/core/widgets/app_image.dart';
import 'package:shared_le_transporteur/core/constants/assets.dart';

import 'package:livreur_le_transporteur/pages/home/dashboard_tab.dart';
import 'package:livreur_le_transporteur/pages/deliveries/mes_livraisons_page.dart';
import 'package:livreur_le_transporteur/pages/profile/profile_page.dart';
import 'package:livreur_le_transporteur/pages/settings/settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const DashboardTab(),
    const MesLivraisonsPage(),
    const ProfilePage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0EB), // Light peach background from screenshot
      appBar: _currentIndex == 0 ? _buildDashboardAppBar() : null, // Only show custom app bar on Dashboard
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.poppins(fontSize: 12.sp),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_filled),
              label: "Accueil",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.local_shipping), // Box icon alternative
              label: "Mes livraisons",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: "Profil",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: "Paramètres",
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildDashboardAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
       leading: Padding(
        padding: EdgeInsets.all(8.w),
        child: AppImage(
          assetPath: AppAssets.logoOrange, // Assuming logo exists
          fit: BoxFit.cover,
        ),
      ),
      title: Text(
        "Bon retour, Sam",
        style: GoogleFonts.poppins(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.text,
        ),
      ),
      centerTitle: false,
      actions: [
        Stack(
          alignment: Alignment.topRight,
          children: [
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.notifications_outlined, color: AppColors.text, size: 24.sp),
            ),
            Positioned(
              right: 12,
              top: 12,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  "5",
                  style: TextStyle(color: Colors.white, fontSize: 8.sp, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
         IconButton(
          onPressed: () {},
          icon: Icon(Icons.more_vert, color: AppColors.text, size: 24.sp),
        ),
        SizedBox(width: 8.w),
      ],
    );
  }
}
