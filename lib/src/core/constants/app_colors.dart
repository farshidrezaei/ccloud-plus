import 'package:flutter/material.dart';

abstract final class AppColors {
  // Brand Accents
  static const Color brandRed = Color(0xFFE50914);
  static const Color brandRedHover = Color(0xFFF40612);
  static const Color brandRedGlow = Color(0x59E50914);
  static const Color starGold = Color(0xFFFFC107);
  static const Color imdbGold = starGold;

  // Cinematic Dark Surfaces (OLED / Deep Slate)
  static const Color scaffoldBackground = Color(0xFF090A0E);
  static const Color topBarBackground = Color(0xFF0C0D13);
  static const Color sidebarBackground = Color(0xFF0C0D14);
  static const Color surfaceCard = Color(0xFF13151F);
  static const Color surfaceCardHover = Color(0xFF181B27);
  static const Color surfacePill = Color(0xFF171924);
  static const Color surfacePillActive = Color(0xFFE50914);

  // Borders
  static const Color glassBorder = Color(0x14FFFFFF);
  static const Color glassBorderHover = Color(0x33E50914);
  static const Color activeBorder = Color(0xFFE50914);
  static const Color darkBorder = glassBorder;
  static const Color lightBorder = Color(0x0F000000);

  // Fallbacks & Compatibility
  static const Color darkCardBackground = surfaceCard;
  static const Color darkCardPlaceholder = surfacePill;

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFA0A3B1);
  static const Color textMuted = Color(0xFF6B6E7D);
}
