import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF5642FA); // Purple
  static const Color background = Color(0xFFF7F8FA);
  static const Color cardBackground = Colors.white;
  static const Color textPrimary = Color(0xFF1E1E2D);
  static const Color textSecondary = Color(0xFF8B8B97);
  static const Color textLight = Colors.white;
  
  static const Color highPriority = Color(0xFFFF5C5C);
  static const Color mediumPriority = Color(0xFFFF9800);
  static const Color lowPriority = Color(0xFF4CAF50);

  // Category Icon Colors
  static const Color workIcon = primary;
  static const Color personalIcon = Color(0xFFA259FF);
  static const Color shoppingIcon = Color(0xFFFF9800);
  static const Color healthIcon = Color(0xFF4CAF50);
  
  // Category Background Colors
  static const Color workBg = Color(0xFFE8E5FF);
  static const Color personalBg = Color(0xFFF5E8FF);
  static const Color shoppingBg = Color(0xFFFFF2E6);
  static const Color healthBg = Color(0xFFE8F5E9);
}

class AppStyles {
  static const TextStyle heading1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle heading2 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle title = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle subtitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );
}
