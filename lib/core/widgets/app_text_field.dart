import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_shadows.dart';
import '../theme/app_text_styles.dart';

class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    this.label,
    this.controller,
    this.initialValue,
    String? hintText,
    String? hint,
    this.helperText,
    this.isPassword = false,
    this.isLoginStyle = false,
    this.keyboardType,
    this.textInputAction,
    this.textDirection,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.maxLines = 1,
    this.minLines,
    this.readOnly = false,
    this.autofocus = false,
    this.prefixIcon,
    this.suffixIcon,
    this.focusNode,
  }) : hintText = hintText ?? hint;

  final String? label;
  final TextEditingController? controller;
  final String? initialValue;
  final String? hintText;
  final String? helperText;
  final bool isPassword;
  final bool isLoginStyle;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextDirection? textDirection;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;
  final int? maxLines;
  final int? minLines;
  final bool readOnly;
  final bool autofocus;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final FocusNode? focusNode;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late FocusNode _focusNode;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (_focusNode.hasFocus != _hasFocus) {
      setState(() {
        _hasFocus = _focusNode.hasFocus;
      });
    }
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.removeListener(_handleFocusChange);
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = widget.isLoginStyle
        ? AppDimens.borderSm
        : AppDimens.borderLg;

    final padding = widget.isLoginStyle
        ? const EdgeInsets.symmetric(horizontal: 12, vertical: 8)
        : const EdgeInsets.symmetric(horizontal: 16, vertical: 8);

    final borderColor = _hasFocus
        ? (widget.isLoginStyle ? AppColors.blue500 : Colors.transparent)
        : AppColors.gray300;

    final boxShadow = (_hasFocus && !widget.isLoginStyle)
        ? AppShadows.focusRing
        : const <BoxShadow>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null && widget.label!.isNotEmpty) ...[
          Text(
            widget.label!,
            style: widget.isLoginStyle
                ? AppTextStyles.smBold(AppColors.gray700)
                : AppTextStyles.smSemibold(AppColors.gray700),
          ),
          const SizedBox(height: 8),
        ],
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: borderRadius,
            border: Border.all(
              color: borderColor,
              width: 1,
            ),
            boxShadow: boxShadow,
          ),
          child: TextFormField(
            controller: widget.controller,
            initialValue: widget.initialValue,
            focusNode: _focusNode,
            obscureText: widget.isPassword,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            textDirection: widget.textDirection,
            readOnly: widget.readOnly,
            autofocus: widget.autofocus,
            maxLines: widget.isPassword ? 1 : widget.maxLines,
            minLines: widget.minLines,
            onChanged: widget.onChanged,
            onFieldSubmitted: widget.onSubmitted,
            validator: widget.validator,
            style: AppTextStyles.base(AppColors.gray900),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: padding,
              border: InputBorder.none,
              hintText: widget.hintText,
              hintStyle: AppTextStyles.base(AppColors.gray400),
              prefixIcon: widget.prefixIcon,
              suffixIcon: widget.suffixIcon,
            ),
          ),
        ),
        if (widget.helperText != null && widget.helperText!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            widget.helperText!,
            style: AppTextStyles.xs(AppColors.gray500),
          ),
        ],
      ],
    );
  }
}
