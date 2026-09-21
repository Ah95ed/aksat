import 'package:flutter/material.dart';

class AppDimens {
  AppDimens._();

  // Spacing (Tailwind 4px base)
  static const double p1 = 4.0;
  static const double p2 = 8.0;
  static const double p3 = 12.0;
  static const double p4 = 16.0;
  static const double p5 = 20.0;
  static const double p6 = 24.0;
  static const double p8 = 32.0;
  static const double p12 = 48.0;

  // Radii
  static const double radiusSm = 4.0;   // rounded
  static const double radiusMd = 6.0;   // rounded-md
  static const double radiusLg = 8.0;   // rounded-lg
  static const double radiusXl = 12.0;  // rounded-xl
  static const double radius2Xl = 16.0; // rounded-2xl
  static const double radiusFull = 9999.0;

  static const BorderRadius borderSm = BorderRadius.all(Radius.circular(radiusSm));
  static const BorderRadius borderMd = BorderRadius.all(Radius.circular(radiusMd));
  static const BorderRadius borderLg = BorderRadius.all(Radius.circular(radiusLg));
  static const BorderRadius borderXl = BorderRadius.all(Radius.circular(radiusXl));
  static const BorderRadius border2Xl = BorderRadius.all(Radius.circular(radius2Xl));
  static const BorderRadius borderFull = BorderRadius.all(Radius.circular(radiusFull));

  // Breakpoints
  static const double breakpointMd = 768.0;
  static const double breakpointLg = 1024.0;
  static const double maxContentWidth = 1280.0;

  // Sidebar width
  static const double sidebarWidth = 256.0;
}
