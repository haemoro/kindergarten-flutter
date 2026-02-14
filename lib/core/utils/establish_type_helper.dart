import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class EstablishTypeHelper {
  static Color getColor(String establishType) {
    switch (establishType) {
      case '국공립':
        return AppColors.publicType;
      case '사립':
        return AppColors.privateType;
      case '법인':
        return AppColors.corporationType;
      default:
        return AppColors.otherType;
    }
  }

  static IconData getIcon(String establishType) {
    switch (establishType) {
      case '국공립':
        return Icons.account_balance;
      case '사립':
        return Icons.business;
      case '법인':
        return Icons.corporate_fare;
      default:
        return Icons.school;
    }
  }
}
