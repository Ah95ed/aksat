import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_shadows.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppDimens.p6), // 24px
    this.margin,
    this.color = AppColors.white,
    this.gradient,
    this.border,
    this.borderRadius = AppDimens.border2Xl, // 16px
    this.boxShadow = AppShadows.md,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final Gradient? gradient;
  final BoxBorder? border;
  final BorderRadiusGeometry borderRadius;
  final List<BoxShadow>? boxShadow;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLightColor = color == null ||
        color == AppColors.white ||
        color == AppColors.gray50 ||
        color == AppColors.gray100;
    final resolvedColor = gradient == null
        ? (isDark
            ? (isLightColor ? const Color(0xFF1E293B) : color)
            : (color ?? AppColors.white))
        : null;
    final resolvedBorder = border ??
        (isDark ? Border.all(color: const Color(0xFF334155), width: 1) : null);
    final resolvedShadow = isDark ? null : boxShadow;

    Widget card = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: resolvedColor,
        gradient: gradient,
        borderRadius: borderRadius,
        border: resolvedBorder,
        boxShadow: resolvedShadow,
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius is BorderRadius
              ? borderRadius as BorderRadius
              : AppDimens.border2Xl,
          child: card,
        ),
      );
    }

    return card;
  }
}
