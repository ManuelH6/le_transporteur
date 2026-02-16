import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_le_transporteur/core/theme/app_theme.dart';
import 'package:shared_le_transporteur/core/widgets/app_button.dart';
import 'package:shared_le_transporteur/core/widgets/app_image.dart';
import 'package:shared_le_transporteur/core/constants/assets.dart';
import 'package:client_le_transporteur/pages/auth/login_page.dart';
import 'package:client_le_transporteur/pages/auth/register_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      "image": AppAssets.backgroundLivreurColis,
      "title": "Envoyez vos colis en toute simplicité",
      "subtitle": "Un service rapide et fiable pour tous vos besoins de livraison.",
    },
    {
      "image": AppAssets.backgroundMotoLivreur,
      "title": "Suivez votre livraison en temps réel",
      "subtitle": "Gardez un œil sur votre colis du ramassage à la destination.",
    },
    {
      "image": AppAssets.backgroundDeuxLivreurs, // Using existing asset from assets.dart
      "title": "Un réseau de livreurs de confiance",
      "subtitle": "Des professionnels vérifiés pour assurer la sécurité de vos biens.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemBuilder: (context, index) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  AppImage(
                    assetPath: _pages[index]["image"]!,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.1),
                          Colors.black.withOpacity(0.8),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                   // Dots Indicator
                   Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: EdgeInsets.symmetric(horizontal: 4.w),
                        height: 8.h,
                        width: _currentPage == index ? 24.w : 8.w,
                        decoration: BoxDecoration(
                          color: _currentPage == index ? AppColors.primary : Colors.white54,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 32.h),
                  Text(
                    _pages[_currentPage]["title"]!,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    _pages[_currentPage]["subtitle"]!,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  SizedBox(height: 48.h),
                  
                  if (_currentPage == _pages.length - 1) ...[
                     AppButton(
                      text: "S'inscrire",
                      onPressed: () {
                         Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterPage()));
                      },
                    ),
                    SizedBox(height: 16.h),
                    TextButton(
                      onPressed: () {
                         Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage()));
                      },
                      child: Text(
                        "Se connecter",
                        style: GoogleFonts.poppins(
                          fontSize: 16.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ] else ...[
                     AppButton(
                      text: "Suivant",
                      onPressed: () {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeIn,
                        );
                      },
                    ),
                     SizedBox(height: 16.h),
                    TextButton(
                      onPressed: () {
                         _pageController.jumpToPage(_pages.length - 1);
                      },
                      child: Text(
                        "Ignorer",
                        style: GoogleFonts.poppins(
                          fontSize: 16.sp,
                          color: Colors.white54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
