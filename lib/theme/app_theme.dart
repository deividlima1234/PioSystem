import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeType {
  darkRed,
  lightBlue
}

class AppColors {
  final Color primary;
  final Color primaryDark;
  final Color background;
  final Color surface;
  final Color surfaceDark;
  final Color surfaceLight;
  final Color overlay;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color borderLight;
  final Color borderFaint;
  final Color borderFaintest;
  final Color success;
  final Color error;
  final Color errorAccent;
  final Color black;
  final Color transparent;
  final bool isDark;

  const AppColors({
    required this.primary,
    required this.primaryDark,
    required this.background,
    required this.surface,
    required this.surfaceDark,
    required this.surfaceLight,
    required this.overlay,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.borderLight,
    required this.borderFaint,
    required this.borderFaintest,
    required this.success,
    required this.error,
    required this.errorAccent,
    required this.black,
    required this.transparent,
    required this.isDark,
  });

  static const AppColors darkRed = AppColors(
    isDark: true,
    primary: Color(0xFFFF003C), 
    primaryDark: Color(0xFF990024),
    background: Color(0xFF0A0A0A),
    surface: Color(0xFF1A1A1A),
    surfaceDark: Color(0xFF151515),
    surfaceLight: Color(0xFF252525),
    overlay: Colors.black54,
    textPrimary: Colors.white,
    textSecondary: Colors.white54,
    textMuted: Colors.grey,
    borderLight: Colors.white24,
    borderFaint: Colors.white12,
    borderFaintest: Colors.white10,
    success: Colors.greenAccent,
    error: Colors.red,
    errorAccent: Colors.redAccent,
    black: Colors.black,
    transparent: Colors.transparent,
  );

  static const AppColors lightBlue = AppColors(
    isDark: false,
    primary: Color(0xFF1565C0), // Azul principal
    primaryDark: Color(0xFF0D47A1), // Azul oscuro
    background: Color(0xFFF5F5F5), // Fondo general gris suave
    surface: Color(0xFFFFFFFF), // Tarjetas blancas
    surfaceDark: Color(0xFFE0E0E0), // Gris fondos
    surfaceLight: Color(0xFFF0F0F0), // Gris íconos
    overlay: Colors.black54,
    textPrimary: Color(0xFF1A1A1A), // Texto oscuro
    textSecondary: Color(0xFF757575), // Texto secundario
    textMuted: Color(0xFF9E9E9E), // Texto muteado
    borderLight: Color(0xFFBDBDBD),
    borderFaint: Color(0xFFE0E0E0),
    borderFaintest: Color(0xFFEEEEEE),
    success: Colors.green,
    error: Colors.red,
    errorAccent: Colors.redAccent,
    black: Colors.black,
    transparent: Colors.transparent,
  );
}

class ThemeProvider extends ChangeNotifier {
  AppThemeType _currentTheme = AppThemeType.darkRed;
  
  AppThemeType get currentTheme => _currentTheme;
  
  AppColors get colors {
    switch (_currentTheme) {
      case AppThemeType.darkRed:
        return AppColors.darkRed;
      case AppThemeType.lightBlue:
        return AppColors.lightBlue;
    }
  }

  ThemeData get themeData {
    return ThemeData(
      brightness: colors.isDark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: colors.background,
      primaryColor: colors.primary,
      colorScheme: ColorScheme(
        brightness: colors.isDark ? Brightness.dark : Brightness.light,
        primary: colors.primary,
        onPrimary: Colors.white,
        secondary: colors.primaryDark,
        onSecondary: Colors.white,
        error: colors.error,
        onError: Colors.white,
        surface: colors.surface,
        onSurface: colors.textPrimary,
        background: colors.background,
        onBackground: colors.textPrimary,
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: colors.textPrimary),
        bodyMedium: TextStyle(color: colors.textPrimary),
        displayLarge: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.w600),
      ),
      useMaterial3: true,
    );
  }

  ThemeProvider() {
    _loadTheme();
  }

  void switchTheme(AppThemeType type) async {
    _currentTheme = type;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('app_theme', type.index);
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedThemeIndex = prefs.getInt('app_theme');
    if (savedThemeIndex != null && savedThemeIndex < AppThemeType.values.length) {
      _currentTheme = AppThemeType.values[savedThemeIndex];
      notifyListeners();
    }
  }
}

extension ThemeContext on BuildContext {
  AppColors get colors => watch<ThemeProvider>().colors;
}
