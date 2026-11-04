import 'package:flutter/material.dart';

abstract final class AppDimensions {
  // Grid
  static const double cardWidth = 200.0;
  static const double cardAspectRatio = 0.68;
  static const double gridSpacing = 20.0;
  static const int minGridColumns = 1;
  static const int maxGridColumns = 5;

  static const EdgeInsets screenPadding = EdgeInsets.fromLTRB(8, 20, 8, 0);
  static const EdgeInsets headerHorizontalPadding = EdgeInsets.symmetric(
    horizontal: 12.0,
  );
  static const EdgeInsets gridPadding = EdgeInsets.fromLTRB(12, 12, 12, 24);

  // Border radius
  static const double cardRadius = 16.0;
  static const double cardInnerRadius = 15.0;
  static const double badgeRadius = 8.0;

  // Animation
  static const double hoverScale = 1.04;
  static const Duration hoverDuration = Duration(milliseconds: 200);
}
