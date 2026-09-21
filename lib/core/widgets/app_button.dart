import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_shadows.dart';
import '../theme/app_text_styles.dart';

enum AppButtonVariant { primary, success, danger, secondary, warning }
enum AppButtonSize { normal, sm, tableSmall, small, large }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.normal,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
  });

  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final Widget? icon;
  final bool isLoading;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final bool disabled = onPressed == null || isLoading;

    Color bg;
    Color hoverBg;
    Color fg;
    List<BoxShadow> shadows = const [];

    switch (variant) {
      case AppButtonVariant.primary:
        bg = AppColors.blue600;
        hoverBg = AppColors.blue700;
        fg = AppColors.white;
        shadows = AppShadows.md;
        break;
      case AppButtonVariant.success:
        bg = AppColors.green600;
        hoverBg = AppColors.green700;
        fg = AppColors.white;
        shadows = AppShadows.md;
        break;
      case AppButtonVariant.danger:
        bg = AppColors.red600;
        hoverBg = AppColors.red700;
        fg = AppColors.white;
        shadows = AppShadows.md;
        break;
      case AppButtonVariant.secondary:
        bg = AppColors.gray200;
        hoverBg = AppColors.gray300;
        fg = AppColors.gray800;
        shadows = const [];
        break;
      case AppButtonVariant.warning:
        bg = AppColors.amber500;
        hoverBg = AppColors.amber600;
        fg = AppColors.white;
        shadows = const [];
        break;
    }

    EdgeInsets padding;
    TextStyle style;
    BorderRadius radius;

    switch (size) {
      case AppButtonSize.normal:
        padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 10);
        style = AppTextStyles.baseMedium(fg);
        radius = AppDimens.borderLg;
        break;
      case AppButtonSize.large:
        padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 14);
        style = AppTextStyles.lgBold(fg);
        radius = AppDimens.borderLg;
        break;
      case AppButtonSize.sm:
      case AppButtonSize.small:
        padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
        style = AppTextStyles.smMedium(fg);
        radius = AppDimens.borderLg;
        break;
      case AppButtonSize.tableSmall:
        padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 4);
        style = AppTextStyles.xsMedium(fg);
        radius = AppDimens.borderSm;
        shadows = const [];
        break;
    }

    Widget content = Row(
      mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (isLoading)
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 8),
            child: SizedBox(
              width: size == AppButtonSize.tableSmall ? 12 : 16,
              height: size == AppButtonSize.tableSmall ? 12 : 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: fg),
            ),
          )
        else if (icon != null) ...[
          icon!,
          const SizedBox(width: 8),
        ],
        Text(
          text,
          style: style,
          textAlign: TextAlign.center,
        ),
      ],
    );

    return Opacity(
      opacity: disabled ? 0.5 : 1.0,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: disabled ? const [] : shadows,
        ),
        child: Material(
          color: bg,
          borderRadius: radius,
          child: InkWell(
            onTap: disabled ? null : onPressed,
            highlightColor: hoverBg,
            splashColor: hoverBg.withValues(alpha: 0.5),
            borderRadius: radius,
            child: Container(
              padding: padding,
              width: fullWidth ? double.infinity : null,
              alignment: fullWidth ? Alignment.center : null,
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}
