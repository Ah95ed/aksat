import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// THE ONLY place spacing and sizing constants live.
/// All values are expressed in logical pixels via `.w/.h/.r/.sp`.
/// Never hardcode a padding/margin/gap value inside a screen.
class AppDimens {
  AppDimens._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 48;

  static double get xsW => xs.w;
  static double get smW => sm.w;
  static double get mdW => md.w;
  static double get lgW => lg.w;
  static double get xlW => xl.w;
  static double get xxlW => xxl.w;
  static double get xxxlW => xxxl.w;
  static double get hugeW => huge.w;

  static double get iconSm => 18.r;
  static double get iconMd => 22.r;
  static double get iconLg => 28.r;
  static double get iconXl => 36.r;

  static double get cardRadius => 14.r;
  static double get buttonRadius => 12.r;
  static double get inputRadius => 12.r;
  static double get chipRadius => 999.r;

  static double get buttonHeight => 52.h;
  static double get inputHeight => 56.h;
  static double get fabSize => 56.r;

  static double get splashLogo => 120.r;

  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 10.r,
      offset: Offset(0, 4.h),
    ),
  ];

  static List<BoxShadow> get elevatedShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 16.r,
      offset: Offset(0, 6.h),
    ),
  ];
}
