import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_shadows.dart';

enum AppModalMaxWidth { md, xl2 }

class AppModal extends StatelessWidget {
  const AppModal({
    super.key,
    required this.child,
    this.maxWidth = AppModalMaxWidth.md,
    this.padding = const EdgeInsets.all(AppDimens.p6), // 24px
  });

  final Widget child;
  final AppModalMaxWidth maxWidth;
  final EdgeInsetsGeometry padding;

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    AppModalMaxWidth maxWidth = AppModalMaxWidth.md,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: AppColors.modalBackdrop,
      builder: (ctx) => AppModal(
        maxWidth: maxWidth,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double maxW = maxWidth == AppModalMaxWidth.md ? 448.0 : 672.0;
    final maxH = MediaQuery.of(context).size.height * 0.8;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.p4), // 16px
        child: Material(
          color: Colors.transparent,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: maxW,
              maxHeight: maxH,
            ),
            decoration: const BoxDecoration(
              color: AppColors.white,
              borderRadius: AppDimens.border2Xl,
              boxShadow: AppShadows.xxl,
            ),
            child: ClipRRect(
              borderRadius: AppDimens.border2Xl,
              child: SingleChildScrollView(
                padding: padding,
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
