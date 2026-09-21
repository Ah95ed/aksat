import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'app_card.dart';

class EmptyView extends StatelessWidget {
  const EmptyView({
    super.key,
    required this.message,
    this.inCard = true,
    this.compact = false,
  });

  final String message;
  final bool inCard;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final padding = EdgeInsets.symmetric(vertical: compact ? 16 : 48);

    final content = Center(
      child: Padding(
        padding: padding,
        child: Text(
          message,
          style: AppTextStyles.base(AppColors.gray500),
          textAlign: TextAlign.center,
        ),
      ),
    );

    if (inCard) {
      return AppCard(child: content);
    }
    return content;
  }
}
