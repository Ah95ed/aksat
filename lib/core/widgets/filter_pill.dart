import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';

enum FilterPillSize { large, medium, small }

class FilterPill extends StatelessWidget {
  const FilterPill({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.size = FilterPillSize.large,
    this.icon,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final FilterPillSize size;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    EdgeInsets padding;
    TextStyle style;

    switch (size) {
      case FilterPillSize.large:
        padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
        style = isSelected
            ? AppTextStyles.baseMedium(AppColors.white)
            : AppTextStyles.baseMedium(AppColors.gray700);
        break;
      case FilterPillSize.medium:
        padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
        style = isSelected
            ? AppTextStyles.smMedium(AppColors.white)
            : AppTextStyles.smMedium(AppColors.gray700);
        break;
      case FilterPillSize.small:
        padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 4);
        style = isSelected
            ? AppTextStyles.smMedium(AppColors.white)
            : AppTextStyles.smMedium(AppColors.gray700);
        break;
    }

    final bg = isSelected ? AppColors.blue600 : AppColors.gray100;
    final splash = isSelected ? AppColors.blue700 : AppColors.gray200;

    return Material(
      color: bg,
      borderRadius: AppDimens.borderLg,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppDimens.borderLg,
        highlightColor: splash,
        splashColor: splash.withValues(alpha: 0.5),
        child: Container(
          padding: padding,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                icon!,
                const SizedBox(width: 6),
              ],
              Text(label, style: style),
            ],
          ),
        ),
      ),
    );
  }
}
