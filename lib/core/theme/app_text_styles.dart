import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const String fontFamily = 'Cairo';

  static TextStyle _base({
    required double fontSize,
    required double lineHeight,
    FontWeight fontWeight = FontWeight.normal,
    Color color = AppColors.gray800,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: fontSize,
      height: lineHeight / fontSize,
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: fontWeight,
      color: color,
    );
  }

  // xs: 12/16
  static TextStyle xs([Color? color]) => _base(fontSize: 12, lineHeight: 16, color: color ?? AppColors.gray500);
  static TextStyle xsMedium([Color? color]) => _base(fontSize: 12, lineHeight: 16, fontWeight: FontWeight.w500, color: color ?? AppColors.gray600);
  static TextStyle xsBold([Color? color]) => _base(fontSize: 12, lineHeight: 16, fontWeight: FontWeight.w700, color: color ?? AppColors.gray700);

  // sm: 14/20
  static TextStyle sm([Color? color]) => _base(fontSize: 14, lineHeight: 20, color: color ?? AppColors.gray600);
  static TextStyle smMedium([Color? color]) => _base(fontSize: 14, lineHeight: 20, fontWeight: FontWeight.w500, color: color ?? AppColors.gray700);
  static TextStyle smSemibold([Color? color]) => _base(fontSize: 14, lineHeight: 20, fontWeight: FontWeight.w600, color: color ?? AppColors.gray700);
  static TextStyle smBold([Color? color]) => _base(fontSize: 14, lineHeight: 20, fontWeight: FontWeight.w700, color: color ?? AppColors.gray800);

  // base: 16/24
  static TextStyle base([Color? color]) => _base(fontSize: 16, lineHeight: 24, color: color ?? AppColors.gray800);
  static TextStyle baseMedium([Color? color]) => _base(fontSize: 16, lineHeight: 24, fontWeight: FontWeight.w500, color: color ?? AppColors.gray800);
  static TextStyle baseSemibold([Color? color]) => _base(fontSize: 16, lineHeight: 24, fontWeight: FontWeight.w600, color: color ?? AppColors.gray800);
  static TextStyle baseBold([Color? color]) => _base(fontSize: 16, lineHeight: 24, fontWeight: FontWeight.w700, color: color ?? AppColors.gray800);

  // lg: 18/28
  static TextStyle lg([Color? color]) => _base(fontSize: 18, lineHeight: 28, color: color ?? AppColors.gray800);
  static TextStyle lgMedium([Color? color]) => _base(fontSize: 18, lineHeight: 28, fontWeight: FontWeight.w500, color: color ?? AppColors.gray800);
  static TextStyle lgBold([Color? color]) => _base(fontSize: 18, lineHeight: 28, fontWeight: FontWeight.w700, color: color ?? AppColors.gray800);

  // xl: 20/28
  static TextStyle xl([Color? color]) => _base(fontSize: 20, lineHeight: 28, color: color ?? AppColors.gray800);
  static TextStyle xlBold([Color? color]) => _base(fontSize: 20, lineHeight: 28, fontWeight: FontWeight.w700, color: color ?? AppColors.gray800);

  // 2xl: 24/32
  static TextStyle xxl([Color? color]) => _base(fontSize: 24, lineHeight: 32, color: color ?? AppColors.gray800);
  static TextStyle xxlBold([Color? color]) => _base(fontSize: 24, lineHeight: 32, fontWeight: FontWeight.w700, color: color ?? AppColors.gray800);

  // 3xl: 30/36 (Page h1)
  static TextStyle xxxlBold([Color? color]) => _base(fontSize: 30, lineHeight: 36, fontWeight: FontWeight.w700, color: color ?? AppColors.gray800);

  // 4xl: 36/40
  static TextStyle xxxxlBold([Color? color]) => _base(fontSize: 36, lineHeight: 40, fontWeight: FontWeight.w700, color: color ?? AppColors.gray800);
}
