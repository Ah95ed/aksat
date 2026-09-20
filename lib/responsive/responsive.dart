import 'package:flutter/material.dart';

import 'breakpoints.dart';

/// Adaptive helpers exposed via BuildContext.
class Responsive {
  const Responsive._();

  static const double _maxContentWidth = 1100;

  static ScreenSize sizeOf(BuildContext context) =>
      responsiveSize(MediaQuery.of(context).size.width);

  static bool isMobile(BuildContext context) =>
      sizeOf(context) == ScreenSize.mobile;

  static bool isTablet(BuildContext context) =>
      sizeOf(context) == ScreenSize.tablet;

  static bool isDesktop(BuildContext context) =>
      sizeOf(context) == ScreenSize.desktop;

  static bool isWide(BuildContext context) =>
      sizeOf(context) != ScreenSize.mobile;

  static double contentWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width > _maxContentWidth ? _maxContentWidth : width;
  }
}

extension ResponsiveContext on BuildContext {
  Responsive get responsive => const Responsive._();
  ScreenSize get size => Responsive.sizeOf(this);
  bool get isMobile => Responsive.isMobile(this);
  bool get isTablet => Responsive.isTablet(this);
  bool get isDesktop => Responsive.isDesktop(this);
  bool get isWide => Responsive.isWide(this);
  double get contentWidth => Responsive.contentWidth(this);
}

/// Builds a child only when the predicate matches. Prevents overflow on
/// small screens by dropping optional widgets entirely.
class ResponsiveBuilder extends StatefulWidget {
  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  @override
  State<ResponsiveBuilder> createState() => _ResponsiveBuilderState();
}

class _ResponsiveBuilderState extends State<ResponsiveBuilder> {
  @override
  Widget build(BuildContext context) {
    return switch (Responsive.sizeOf(context)) {
      ScreenSize.mobile => widget.mobile,
      ScreenSize.tablet => widget.tablet ?? widget.mobile,
      ScreenSize.desktop => widget.desktop ?? widget.tablet ?? widget.mobile,
    };
  }
}