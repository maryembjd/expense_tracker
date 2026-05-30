import 'package:flutter/material.dart';

class AppColors {
  // Brand
  static const primary = Color(0xFF6C63FF);
  static const primaryDark = Color(0xFF4B44D6);
  static const primaryLight = Color(0xFF9B94FF);
  static const secondary = Color(0xFF00D4AA);
  static const secondaryDark = Color(0xFF00A885);
  static const accent = Color(0xFFFF6584);

  // Gradients
  static const gradientPrimary = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF9B94FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const gradientSuccess = LinearGradient(
    colors: [Color(0xFF00D4AA), Color(0xFF00F5CC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const gradientDanger = LinearGradient(
    colors: [Color(0xFFFF6584), Color(0xFFFF8FA3)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const gradientWarning = LinearGradient(
    colors: [Color(0xFFFFB347), Color(0xFFFFCC80)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Semantic
  static const success = Color(0xFF00D4AA);
  static const warning = Color(0xFFFFB347);
  static const error = Color(0xFFFF6584);
  static const info = Color(0xFF4FC3F7);

  // Neutral Light
  static const background = Color(0xFFF8F9FF);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceVariant = Color(0xFFF0F1FA);
  static const onSurface = Color(0xFF1A1A2E);
  static const onSurfaceVariant = Color(0xFF6B7280);
  static const divider = Color(0xFFE8EAF6);
  static const shadow = Color(0x1A6C63FF);

  // Neutral Dark
  static const darkBackground = Color(0xFF0F0F1E);
  static const darkSurface = Color(0xFF1A1A2E);
  static const darkSurfaceVariant = Color(0xFF252540);
  static const darkOnSurface = Color(0xFFF8F9FF);
  static const darkOnSurfaceVariant = Color(0xFFB0B3C6);
  static const darkDivider = Color(0xFF2D2D4A);
  static const darkShadow = Color(0x406C63FF);

  // Category Colors
  static const catFood = Color(0xFFFF6B6B);
  static const catTransport = Color(0xFF4ECDC4);
  static const catShopping = Color(0xFFFFE66D);
  static const catHealth = Color(0xFF6BCB77);
  static const catEntertainment = Color(0xFF9B59B6);
  static const catHousing = Color(0xFF3498DB);
  static const catEducation = Color(0xFFE67E22);
  static const catTravel = Color(0xFF1ABC9C);
  static const catPersonal = Color(0xFFE91E63);
  static const catOther = Color(0xFF95A5A6);

  static const List<Color> categoryColors = [
    catFood,
    catTransport,
    catShopping,
    catHealth,
    catEntertainment,
    catHousing,
    catEducation,
    catTravel,
    catPersonal,
    catOther,
  ];
}
