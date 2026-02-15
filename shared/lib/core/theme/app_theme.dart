// lib/core/theme/app_theme.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppColors {
  static const Color primary = Color(0xFFFF4D9D);
  static const Color secondary = Color(0xFFFEBE05);
  static const Color text = Color(0xFF333333);
  static const Color background = Color(0xFFFFF5F0);
  static const Color white = Color(0xFFFFFFFF);
  static const Color grey = Color(0xFFF5F5F5);
}

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: GoogleFonts.poppinsTextTheme(
        TextTheme(
          displayLarge: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w600, color: AppColors.text), // SemiBold (was headline1)
          displayMedium: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w400, color: AppColors.text), // Regular (was headline2)
          bodyLarge: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w400, color: AppColors.text), // Regular (was bodyText1)
          bodyMedium: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w400, color: AppColors.text), // Regular for smaller text (was bodyText2)
          labelLarge: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: AppColors.white), // SemiBold (was button)
        ),
      ),
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        background: AppColors.background,
      ),
    );
  }
}
