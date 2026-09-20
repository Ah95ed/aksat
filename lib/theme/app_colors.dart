import 'package:flutter/material.dart';

/// Semantic colors shared by light and dark themes.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.primary,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.textHint,
    required this.success,
    required this.warning,
    required this.danger,
    required this.info,
    required this.statusPaid,
    required this.statusPending,
    required this.statusLate,
  });

  final Color primary;
  final Color onPrimary;
  final Color primaryContainer;
  final Color onPrimaryContainer;
  final Color background;
  final Color surface;
  final Color surfaceVariant;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color textHint;
  final Color success;
  final Color warning;
  final Color danger;
  final Color info;
  final Color statusPaid;
  final Color statusPending;
  final Color statusLate;

  static const light = AppColors(
    primary: Color(0xFF0F766E),
    onPrimary: Colors.white,
    primaryContainer: Color(0xFFCCFBF1),
    onPrimaryContainer: Color(0xFF134E4A),
    background: Color(0xFFF7F8F7),
    surface: Colors.white,
    surfaceVariant: Color(0xFFE8F0EF),
    border: Color(0xFFD7E1DF),
    textPrimary: Color(0xFF172321),
    textSecondary: Color(0xFF526360),
    textHint: Color(0xFF83918E),
    success: Color(0xFF237A50),
    warning: Color(0xFFB26A00),
    danger: Color(0xFFB3261E),
    info: Color(0xFF2563A6),
    statusPaid: Color(0xFF237A50),
    statusPending: Color(0xFFB26A00),
    statusLate: Color(0xFFB3261E),
  );

  static const dark = AppColors(
    primary: Color(0xFF5CC8C2),
    onPrimary: Color(0xFF003735),
    primaryContainer: Color(0xFF164C49),
    onPrimaryContainer: Color(0xFFA7F3ED),
    background: Color(0xFF101918),
    surface: Color(0xFF182321),
    surfaceVariant: Color(0xFF213331),
    border: Color(0xFF344947),
    textPrimary: Color(0xFFE4F0EE),
    textSecondary: Color(0xFFA7BAB7),
    textHint: Color(0xFF7C9290),
    success: Color(0xFF72D6A2),
    warning: Color(0xFFF0B45B),
    danger: Color(0xFFFF8A80),
    info: Color(0xFF8AB8F5),
    statusPaid: Color(0xFF72D6A2),
    statusPending: Color(0xFFF0B45B),
    statusLate: Color(0xFFFF8A80),
  );

  @override
  AppColors copyWith({
    Color? primary,
    Color? onPrimary,
    Color? primaryContainer,
    Color? onPrimaryContainer,
    Color? background,
    Color? surface,
    Color? surfaceVariant,
    Color? border,
    Color? textPrimary,
    Color? textSecondary,
    Color? textHint,
    Color? success,
    Color? warning,
    Color? danger,
    Color? info,
    Color? statusPaid,
    Color? statusPending,
    Color? statusLate,
  }) => AppColors(
    primary: primary ?? this.primary,
    onPrimary: onPrimary ?? this.onPrimary,
    primaryContainer: primaryContainer ?? this.primaryContainer,
    onPrimaryContainer: onPrimaryContainer ?? this.onPrimaryContainer,
    background: background ?? this.background,
    surface: surface ?? this.surface,
    surfaceVariant: surfaceVariant ?? this.surfaceVariant,
    border: border ?? this.border,
    textPrimary: textPrimary ?? this.textPrimary,
    textSecondary: textSecondary ?? this.textSecondary,
    textHint: textHint ?? this.textHint,
    success: success ?? this.success,
    warning: warning ?? this.warning,
    danger: danger ?? this.danger,
    info: info ?? this.info,
    statusPaid: statusPaid ?? this.statusPaid,
    statusPending: statusPending ?? this.statusPending,
    statusLate: statusLate ?? this.statusLate,
  );

  @override
  AppColors lerp(covariant AppColors? other, double t) {
    if (other == null) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppColors(
      primary: mix(primary, other.primary),
      onPrimary: mix(onPrimary, other.onPrimary),
      primaryContainer: mix(primaryContainer, other.primaryContainer),
      onPrimaryContainer: mix(onPrimaryContainer, other.onPrimaryContainer),
      background: mix(background, other.background),
      surface: mix(surface, other.surface),
      surfaceVariant: mix(surfaceVariant, other.surfaceVariant),
      border: mix(border, other.border),
      textPrimary: mix(textPrimary, other.textPrimary),
      textSecondary: mix(textSecondary, other.textSecondary),
      textHint: mix(textHint, other.textHint),
      success: mix(success, other.success),
      warning: mix(warning, other.warning),
      danger: mix(danger, other.danger),
      info: mix(info, other.info),
      statusPaid: mix(statusPaid, other.statusPaid),
      statusPending: mix(statusPending, other.statusPending),
      statusLate: mix(statusLate, other.statusLate),
    );
  }
}
