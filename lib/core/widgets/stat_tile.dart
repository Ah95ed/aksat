import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';

class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.value,
    required this.label,
    required this.backgroundColor,
    required this.valueColor,
    this.valueFontSize = 24.0,
    this.padding = const EdgeInsets.all(AppDimens.p3),
  });

  final String value;
  final String label;
  final Color backgroundColor;
  final Color valueColor;
  final double valueFontSize;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppDimens.borderLg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            value,
            style: AppTextStyles.xxlBold(valueColor).copyWith(
              fontSize: valueFontSize,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.xs(AppColors.gray600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
