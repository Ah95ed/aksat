import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';

class AppDialogs {
  AppDialogs._();

  static Future<void> alert(BuildContext context, String message, {String? title}) {
    return showDialog<void>(
      context: context,
      barrierColor: AppColors.modalBackdrop,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: const RoundedRectangleBorder(
            borderRadius: AppDimens.border2Xl,
          ),
          backgroundColor: AppColors.white,
          title: title != null
              ? Text(title, style: AppTextStyles.xlBold(AppColors.gray800))
              : null,
          content: Text(
            message,
            style: AppTextStyles.base(AppColors.gray700),
          ),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.blue600,
                textStyle: AppTextStyles.baseMedium(),
              ),
              child: const Text('موافق'),
            ),
          ],
        ),
      ),
    );
  }

  static Future<bool> confirm(BuildContext context, String message, {String? title}) async {
    final result = await showDialog<bool>(
      context: context,
      barrierColor: AppColors.modalBackdrop,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: const RoundedRectangleBorder(
            borderRadius: AppDimens.border2Xl,
          ),
          backgroundColor: AppColors.white,
          title: title != null
              ? Text(title, style: AppTextStyles.xlBold(AppColors.gray800))
              : null,
          content: Text(
            message,
            style: AppTextStyles.base(AppColors.gray700),
          ),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.gray600,
                textStyle: AppTextStyles.baseMedium(),
              ),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.blue600,
                textStyle: AppTextStyles.baseMedium(),
              ),
              child: const Text('موافق'),
            ),
          ],
        ),
      ),
    );
    return result ?? false;
  }
}
