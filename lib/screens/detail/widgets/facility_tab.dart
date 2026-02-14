import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/kindergarten_detail.dart';
import '../../../widgets/detail_section_card.dart';

class FacilityTab extends StatelessWidget {
  final FacilitySection facility;

  const FacilityTab({
    super.key,
    required this.facility,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 건물 정보
          DetailSectionCard(
            title: '건물 정보',
            child: Column(
              children: [
                DetailInfoRow(
                  icon: Icons.calendar_today,
                  label: '건축 연도',
                  value: '${facility.archYear}년',
                  valueColor: _getBuildingAgeColor(facility.archYear),
                ),
                const SizedBox(height: 8),
                DetailInfoRow(
                  icon: Icons.layers,
                  label: '층수',
                  value: '${facility.floorCount}층',
                ),
                const SizedBox(height: 8),
                DetailInfoRow(
                  icon: Icons.square_foot,
                  label: '건물 면적',
                  value: '${facility.buildingArea.toStringAsFixed(1)}㎡',
                  valueColor: AppColors.primary,
                ),
                const SizedBox(height: 8),
                DetailInfoRow(
                  icon: Icons.landscape,
                  label: '대지 면적',
                  value: '${facility.totalLandArea.toStringAsFixed(1)}㎡',
                  valueColor: AppColors.secondary,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 교육 시설
          DetailSectionCard(
            title: '교육 시설',
            child: Column(
              children: [
                DetailInfoRow(
                  icon: Icons.school,
                  label: '교실 수',
                  value: '${facility.classroomCount}개',
                  valueColor: AppColors.primary,
                ),
                const SizedBox(height: 8),
                DetailInfoRow(
                  icon: Icons.square_foot,
                  label: '교실 면적',
                  value: '${facility.classroomArea.toStringAsFixed(1)}㎡',
                ),
                const SizedBox(height: 8),
                DetailInfoRow(
                  icon: Icons.sports_soccer,
                  label: '놀이터 면적',
                  value: '${facility.playgroundArea.toStringAsFixed(1)}㎡',
                  valueColor: AppColors.success,
                ),
                const SizedBox(height: 12),
                // 교실당 평균 면적
                if (facility.classroomCount > 0)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calculate,
                          color: AppColors.info,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '교실당 평균 면적: ${(facility.classroomArea / facility.classroomCount).toStringAsFixed(1)}㎡',
                          style: AppTextStyles.body2.copyWith(
                            color: AppColors.info,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 통학버스 정보
          DetailSectionCard(
            title: '통학버스 운영',
            child: Column(
              children: [
                DetailInfoRow(
                  icon: Icons.directions_bus,
                  label: '통학버스 운영',
                  value: facility.busOperating == 'Y' ? '운영' : '미운영',
                  valueColor: facility.busOperating == 'Y'
                      ? AppColors.success
                      : AppColors.gray500,
                ),

                if (facility.busOperating == 'Y') ...[
                  const SizedBox(height: 8),
                  DetailInfoRow(
                    icon: Icons.airport_shuttle,
                    label: '운행 대수',
                    value: '${facility.operatingBusCount}대',
                    valueColor: AppColors.primary,
                  ),
                  const SizedBox(height: 8),
                  DetailInfoRow(
                    icon: Icons.how_to_reg,
                    label: '등록 대수',
                    value: '${facility.registeredBusCount}대',
                  ),

                  const SizedBox(height: 12),
                  // 통학버스 운영 현황 요약
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
                                '통학버스 서비스 제공',
                                style: AppTextStyles.body2.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.success,
                                ),
                              ),
                              Text(
                                '${facility.operatingBusCount}대의 통학버스가 운행 중입니다',
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
                ] else ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.gray100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppColors.gray500,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '통학버스를 운영하지 않습니다',
                            style: AppTextStyles.body2.copyWith(
                              color: AppColors.gray600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 시설 규모 요약
          _buildFacilitySummary(),
        ],
      ),
    );
  }

  Widget _buildFacilitySummary() {
    return Container(
      decoration: AppDecorations.cardDecoration(),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withValues(alpha: 0.1),
              AppColors.secondary.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '시설 규모 요약',
              style: AppTextStyles.sectionTitle,
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _SummaryItem(
                    icon: Icons.square_foot,
                    label: '총 면적',
                    value: '${facility.totalLandArea.toStringAsFixed(0)}㎡',
                    color: AppColors.primary,
                  ),
                ),
                Expanded(
                  child: _SummaryItem(
                    icon: Icons.home_work,
                    label: '건물 면적',
                    value: '${facility.buildingArea.toStringAsFixed(0)}㎡',
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _SummaryItem(
                    icon: Icons.school,
                    label: '교실 수',
                    value: '${facility.classroomCount}개',
                    color: AppColors.success,
                  ),
                ),
                Expanded(
                  child: _SummaryItem(
                    icon: Icons.directions_bus,
                    label: '통학버스',
                    value: facility.busOperating == 'Y'
                        ? '${facility.operatingBusCount}대'
                        : '미운영',
                    color: facility.busOperating == 'Y'
                        ? AppColors.info
                        : AppColors.gray500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getBuildingAgeColor(int year) {
    final currentYear = DateTime.now().year;
    final age = currentYear - year;

    if (age <= 5) return AppColors.success;
    if (age <= 15) return AppColors.warning;
    return AppColors.error;
  }
}

class _SummaryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _SummaryItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.body1.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.gray600,
            ),
          ),
        ],
      ),
    );
  }
}
