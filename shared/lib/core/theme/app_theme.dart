// lib/core/theme/app_theme.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppColors {
  static const Color primary = Color(0xFFFC471A);
  static const Color secondary = Color(0xFFFEBE05);
  static const Color text = Color(0xFF333333);
  static const Color background = Color(0xFFFFF5F0);
  static const Color white = Color(0xFFFFFFFF);
  static const Color grey = Color(0xFFF5F5F5);

  // Dark Mode Palette
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkText = Color(0xFFEEEEEE);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: GoogleFonts.poppinsTextTheme(
        TextTheme(
          displayLarge: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w600, color: AppColors.text),
          displayMedium: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w400, color: AppColors.text),
          bodyLarge: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w400, color: AppColors.text),
          bodyMedium: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w400, color: AppColors.text),
          labelLarge: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: AppColors.white),
        ),
      ),
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.white,
        onSurface: AppColors.text,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.darkBackground,
      textTheme: GoogleFonts.poppinsTextTheme(
        TextTheme(
          displayLarge: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w600, color: AppColors.darkText),
          displayMedium: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w400, color: AppColors.darkText),
          bodyLarge: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w400, color: AppColors.darkText),
          bodyMedium: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w400, color: AppColors.darkText),
          labelLarge: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: AppColors.white),
        ),
      ),
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkText,
        background: AppColors.darkBackground,
      ),
    );
  }
}
