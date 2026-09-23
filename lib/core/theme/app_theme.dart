import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    return ThemeData(
      useMaterial3: false,
      fontFamily: AppTextStyles.fontFamily,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.pageBgFrom,
      dividerColor: AppColors.divider,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.blue500,
        surface: AppColors.white,
        error: AppColors.danger,
        onPrimary: AppColors.white,
        onSecondary: AppColors.white,
        onSurface: AppColors.gray800,
        onError: AppColors.white,
      ),
    );
  }

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: false,
      fontFamily: AppTextStyles.fontFamily,
      brightness: Brightness.dark,
      primaryColor: AppColors.blue500,
      scaffoldBackgroundColor: const Color(0xFF0F172A), // Slate 900
      dividerColor: const Color(0xFF334155),
      colorScheme: const ColorScheme.dark(
        primary: AppColors.blue500,
        secondary: AppColors.blue400,
        surface: Color(0xFF1E293B), // Slate 800
        error: AppColors.red400,
        onPrimary: AppColors.white,
        onSecondary: AppColors.white,
        onSurface: AppColors.gray100,
        onError: AppColors.white,
      ),
    );
  }

  static ThemeData get lightTheme => light();
  static ThemeData get darkTheme => light();
}
