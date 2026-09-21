import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'app_spinner.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({
    super.key,
    this.message,
    this.size = 48.0,
  });

  final String? message;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AppSpinner(size: size),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(
                message!,
                style: AppTextStyles.base(AppColors.gray600),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
