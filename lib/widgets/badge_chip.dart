import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/utils/establish_type_helper.dart';

class BadgeChip extends StatelessWidget {
  final String label;
  final Color? backgroundColor;
  final Color? textColor;
  final EdgeInsetsGeometry? padding;

  const BadgeChip({
    super.key,
    required this.label,
    this.backgroundColor,
    this.textColor,
    this.padding,
  });

  const BadgeChip.meal({
    super.key,
    required this.label,
  }) : backgroundColor = AppColors.mealBadge,
       textColor = AppColors.mealBadge,
       padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 4);

  const BadgeChip.bus({
    super.key,
    required this.label,
  }) : backgroundColor = AppColors.busBadge,
       textColor = AppColors.busBadge,
       padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 4);

  const BadgeChip.extendedCare({
    super.key,
    required this.label,
  }) : backgroundColor = AppColors.extendedCareBadge,
       textColor = AppColors.extendedCareBadge,
       padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 4);

  BadgeChip.establishType({
    super.key,
    required this.label,
    required String establishType,
  }) : backgroundColor = EstablishTypeHelper.getColor(establishType),
       textColor = EstablishTypeHelper.getColor(establishType),
       padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 4);

  @override
  Widget build(BuildContext context) {
    final color = backgroundColor ?? AppColors.gray400;
    final txtColor = textColor ?? color;

    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: AppTextStyles.badgeText.copyWith(
          color: txtColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
