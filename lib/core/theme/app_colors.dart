import 'package:flutter/material.dart';

abstract final class AppColors {
  // Enterprise brand palette.
  static const Color seed = Color(0xFF174A5B);
  static const Color brandPrimary = Color(0xFF174A5B);
  static const Color brandPrimaryDark = Color(0xFF103440);
  static const Color brandAccent = Color(0xFF2B7184);

  // Light surfaces.
  static const Color lightBackground = Color(0xFFF5F7F9);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceMuted = Color(0xFFF0F3F5);
  static const Color lightBorder = Color(0xFFDDE3E8);

  // Dark surfaces.
  static const Color darkBackground = Color(0xFF0D1419);
  static const Color darkSurface = Color(0xFF141D23);
  static const Color darkSurfaceMuted = Color(0xFF1B262D);
  static const Color darkBorder = Color(0xFF2A3841);

  // Semantic colors. Use these only when meaning is attached.
  static const Color positive = Color(0xFF16815D);
  static const Color warning = Color(0xFFB97816);
  static const Color danger = Color(0xFFBC3A3A);
  static const Color information = Color(0xFF356DA8);
}
