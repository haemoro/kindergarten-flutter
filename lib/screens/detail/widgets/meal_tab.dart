import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/kindergarten_detail.dart';
import '../../../widgets/detail_section_card.dart';

class MealTab extends StatelessWidget {
  final MealSection meal;

  const MealTab({
    super.key,
    required this.meal,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DetailSectionCard(
            title: '급식 운영 정보',
            child: Column(
              children: [
                DetailInfoRow(
                  icon: Icons.restaurant,
                  label: '운영 형태',
                  value: meal.mealOperationType.isNotEmpty
                      ? meal.mealOperationType
                      : '-',
                  valueColor: _getOperationTypeColor(meal.mealOperationType),
                ),

                if (meal.consignmentCompany != null &&
                    meal.consignmentCompany!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  DetailInfoRow(
                    icon: Icons.business,
                    label: '위탁업체',
                    value: meal.consignmentCompany!,
                  ),
                ],

                const SizedBox(height: 8),
                DetailInfoRow(
                  icon: Icons.groups,
                  label: '급식 제공 인원',
                  value: '${meal.mealChildren}명',
                  valueColor: AppColors.primary,
                ),

                const SizedBox(height: 8),
                DetailInfoRow(
                  icon: Icons.restaurant_menu,
                  label: '조리사 수',
                  value: '${meal.cookCount}명',
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 급식 운영 상태 요약
          DetailSectionCard(
            title: '운영 현황',
            child: Column(
              children: [
                // 급식 제공률
                if (meal.mealChildren > 0)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.success.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: AppColors.success,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '급식 서비스 제공',
                                style: AppTextStyles.body2.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.success,
                                ),
                              ),
                              Text(
                                '${meal.mealChildren}명의 원아에게 급식을 제공하고 있습니다',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.gray600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 12),

                // 조리사 대 급식인원 비율
                if (meal.cookCount > 0 && meal.mealChildren > 0)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.analytics,
                          color: AppColors.info,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '조리사 1인당 담당 원아',
                                style: AppTextStyles.body2.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${(meal.mealChildren / meal.cookCount).toStringAsFixed(1)}명',
                                style: AppTextStyles.headline6.copyWith(
                                  color: AppColors.info,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 운영 형태별 안내
          _buildOperationTypeGuide(meal.mealOperationType),
        ],
      ),
    );
  }

  Widget _buildOperationTypeGuide(String operationType) {
    IconData icon;
    String title;
    String description;
    Color color;

    switch (operationType) {
      case '직영':
        icon = Icons.home_work;
        title = '직영 급식';
        description = '유치원에서 직접 급식을 조리하고 관리합니다.';
        color = AppColors.success;
        break;
      case '위탁':
        icon = Icons.business_center;
        title = '위탁 급식';
        description = '전문 급식업체에서 급식을 제공합니다.';
        color = AppColors.warning;
        break;
      default:
        icon = Icons.info;
        title = '급식 정보';
        description = '급식 운영 형태에 대한 정보가 등록되지 않았습니다.';
        color = AppColors.gray500;
    }

    return Container(
      decoration: AppDecorations.cardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.body1.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.gray600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getOperationTypeColor(String operationType) {
    switch (operationType) {
      case '직영':
        return AppColors.success;
      case '위탁':
        return AppColors.warning;
      default:
        return AppColors.gray600;
    }
  }
}
