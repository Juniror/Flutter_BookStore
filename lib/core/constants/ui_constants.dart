import 'package:flutter/material.dart';

/// Common UI-related constants such as padding and border radius.
abstract class UIConstants {
  UIConstants._();

  // Spacing
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;

  // Sizes
  static const double borderRadius = 16.0;

  // Colors (if needed globally, otherwise use Theme)
  static const Color primaryColor = Colors.deepPurple;
}
