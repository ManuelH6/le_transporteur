import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeService {
  static const String _boxName = 'settings';
  static const String _themeKey = 'themeMode'; // Changed key to reflect multiple states

  static Future<void> init() async {
    await Hive.openBox(_boxName);
  }

  static ThemeMode getThemeMode() {
    final box = Hive.box(_boxName);
    final String mode = box.get(_themeKey, defaultValue: 'system');
    switch (mode) {
      case 'light': return ThemeMode.light;
      case 'dark': return ThemeMode.dark;
      default: return ThemeMode.system;
    }
  }

  static Future<void> setThemeMode(ThemeMode mode) async {
    final box = Hive.box(_boxName);
    String modeStr;
    switch (mode) {
      case ThemeMode.light: modeStr = 'light'; break;
      case ThemeMode.dark: modeStr = 'dark'; break;
      default: modeStr = 'system';
    }
    await box.put(_themeKey, modeStr);
  }

  static ValueListenable<Box> get listenable => Hive.box(_boxName).listenable(keys: [_themeKey]);

  // Legacy helper (can be removed later if not used)
  static bool isDarkMode() => getThemeMode() == ThemeMode.dark;
}
