import 'package:flutter/material.dart';

class Responsive {
  static const double mobileBreakpoint = 800;
  static const double maxContentWidth = 1200;

  static bool isWide(BuildContext context) =>
      MediaQuery.sizeOf(context).width > mobileBreakpoint;

  static int gridColumns(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width > 1100) return 4;
    if (width > mobileBreakpoint) return 3;
    return 2;
  }
}
