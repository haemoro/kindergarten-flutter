import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppDecorations {
  /// Standard card shadow
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.grey.withValues(alpha: 0.2),
      offset: const Offset(0, 3),
      blurRadius: 6,
    ),
  ];

  /// Card decoration: white + 16px radius + soft shadow
  static BoxDecoration cardDecoration({Color? color}) => BoxDecoration(
    color: color ?? AppColors.card,
    borderRadius: BorderRadius.circular(16),
    boxShadow: cardShadow,
  );

  /// Header gradient decoration with rounded bottom corners
  static BoxDecoration headerDecoration() => const BoxDecoration(
    gradient: AppColors.headerGradient,
    borderRadius: BorderRadius.only(
      bottomLeft: Radius.circular(24),
      bottomRight: Radius.circular(24),
    ),
  );

  /// Gradient button decoration
  static BoxDecoration gradientButtonDecoration() => BoxDecoration(
    gradient: AppColors.primaryGradient,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: AppColors.primary.withValues(alpha: 0.3),
        offset: const Offset(0, 4),
        blurRadius: 8,
      ),
    ],
  );
}
