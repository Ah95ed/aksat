import 'package:flutter/material.dart';
import '../theme/app_dimens.dart';

class InfoBanner extends StatelessWidget {
  const InfoBanner({
    super.key,
    required this.child,
    required this.backgroundColor,
    required this.borderColor,
    this.borderWidth = 4.0,
    this.borderRadius = AppDimens.borderLg,
    this.padding = const EdgeInsets.all(AppDimens.p4),
  });

  final Widget child;
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    // Physical right border 4px regardless of LTR/RTL
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius,
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(
                color: borderColor,
                width: borderWidth,
              ),
            ),
          ),
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
