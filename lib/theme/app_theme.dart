import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

/// Builds the light and dark [`ThemeData`] from the single source of truth.
class AppTheme {
  AppTheme._();

  static const _fontFamily = 'Cairo';

  static ThemeData light() => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: AppColors.light.primary,
      onPrimary: AppColors.light.onPrimary,
      primaryContainer: AppColors.light.primaryContainer,
      onPrimaryContainer: AppColors.light.onPrimaryContainer,
    ),
    extensions: const [AppColors.light],
    scaffoldBackgroundColor: AppColors.light.background,
    cardColor: AppColors.light.surface,
    dividerColor: AppColors.light.border,
    scrollbarTheme: ScrollbarThemeData(
      thumbColor: WidgetStatePropertyAll(AppColors.light.textHint),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.light.surfaceVariant,
      contentTextStyle: TextStyle(color: AppColors.light.textPrimary),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.light.surface,
      shape: ContinuousRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: AppColors.light.surface,
      shape: ContinuousRectangleBorder(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),
    fontFamily: _fontFamily,
    textTheme: _buildTextTheme(
      AppColors.light.textPrimary,
      AppColors.light.textSecondary,
      AppColors.light.textHint,
    ),
  );

  static ThemeData dark() => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: AppColors.dark.primary,
      onPrimary: AppColors.dark.onPrimary,
      primaryContainer: AppColors.dark.primaryContainer,
      onPrimaryContainer: AppColors.dark.onPrimaryContainer,
    ),
    extensions: const [AppColors.dark],
    scaffoldBackgroundColor: AppColors.dark.background,
    cardColor: AppColors.dark.surface,
    dividerColor: AppColors.dark.border,
    scrollbarTheme: ScrollbarThemeData(
      thumbColor: WidgetStatePropertyAll(AppColors.dark.textHint),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.dark.surfaceVariant,
      contentTextStyle: TextStyle(color: AppColors.dark.textPrimary),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.dark.surface,
      shape: ContinuousRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: AppColors.dark.surface,
      shape: ContinuousRectangleBorder(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),
    fontFamily: _fontFamily,
    textTheme: _buildTextTheme(
      AppColors.dark.textPrimary,
      AppColors.dark.textSecondary,
      AppColors.dark.textHint,
    ),
  );

  static TextTheme _buildTextTheme(Color primary, Color secondary, Color hint) {
    return TextTheme(
      titleLarge: AppTextStyles.titleLarge(primary),
      titleMedium: AppTextStyles.titleMedium(primary),
      titleSmall: AppTextStyles.titleSmall(primary),
      headlineMedium: AppTextStyles.heading(primary),
      bodyLarge: AppTextStyles.bodyLarge(primary),
      bodyMedium: AppTextStyles.bodyMedium(primary),
      bodySmall: AppTextStyles.bodySmall(primary),
      labelLarge: AppTextStyles.bodyMedium(primary),
      labelMedium: AppTextStyles.bodySmall(primary),
      labelSmall: AppTextStyles.caption(secondary),
      headlineSmall: AppTextStyles.titleMedium(primary),
      displaySmall: AppTextStyles.titleLarge(primary),
      displayMedium: AppTextStyles.titleLarge(primary),
      displayLarge: AppTextStyles.titleLarge(primary),
    );
  }
}
