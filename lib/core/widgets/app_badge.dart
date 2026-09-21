import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';

enum AppBadgeVariant { success, warning, danger, info, neutral }

class AppBadge extends StatelessWidget {
  const AppBadge({
    super.key,
    String? text,
    String? label,
    this.variant = AppBadgeVariant.neutral,
    this.customBg,
    this.customFg,
  }) : text = text ?? label ?? '';

  final String text;
  final AppBadgeVariant variant;
  final Color? customBg;
  final Color? customFg;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;

    switch (variant) {
      case AppBadgeVariant.success:
        bg = AppColors.green100;
        fg = AppColors.green800;
        break;
      case AppBadgeVariant.warning:
        bg = AppColors.amber100;
        fg = AppColors.amber800;
        break;
      case AppBadgeVariant.danger:
        bg = AppColors.red100;
        fg = AppColors.red800;
        break;
      case AppBadgeVariant.info:
        bg = AppColors.blue100;
        fg = AppColors.blue800;
        break;
      case AppBadgeVariant.neutral:
        bg = AppColors.gray200;
        fg = AppColors.gray700;
        break;
    }

    if (customBg != null) bg = customBg!;
    if (customFg != null) fg = customFg!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppDimens.borderFull,
      ),
      child: Text(
        text,
        style: AppTextStyles.xsBold(fg),
      ),
    );
  }
}
