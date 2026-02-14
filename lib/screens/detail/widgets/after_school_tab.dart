import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/kindergarten_detail.dart';
import '../../../widgets/detail_section_card.dart';

class AfterSchoolTab extends StatelessWidget {
  final AfterSchoolSection afterSchool;

  const AfterSchoolTab({
    super.key,
    required this.afterSchool,
  });

  @override
  Widget build(BuildContext context) {
    final hasAfterSchoolPrograms = afterSchool.independentClassCount > 0 ||
                                  afterSchool.afternoonClassCount > 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasAfterSchoolPrograms) ...[
            // 방과후 프로그램 현황
            _buildProgramOverview(),

            const SizedBox(height: 16),

            // 독립편성 프로그램
            if (afterSchool.independentClassCount > 0)
              DetailSectionCard(
                title: '독립편성 프로그램',
                subtitle: '방과후 전용 시간에 운영되는 프로그램',
                child: Column(
                  children: [
                    DetailInfoRow(
                      icon: Icons.class_,
                      label: '수업 수',
                      value: '${afterSchool.independentClassCount}개',
                      valueColor: AppColors.primary,
                    ),
                    const SizedBox(height: 8),
                    DetailInfoRow(
                      icon: Icons.groups,
                      label: '참여 인원',
                      value: '${afterSchool.independentParticipants}명',
                      valueColor: AppColors.success,
                    ),
                    if (afterSchool.independentClassCount > 0) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calculate,
                              color: AppColors.primary,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '수업당 평균 인원: ${(afterSchool.independentParticipants / afterSchool.independentClassCount).toStringAsFixed(1)}명',
                              style: AppTextStyles.body2.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

            if (afterSchool.independentClassCount > 0 && afterSchool.afternoonClassCount > 0)
              const SizedBox(height: 16),

            // 오후편성 프로그램
            if (afterSchool.afternoonClassCount > 0)
              DetailSectionCard(
                title: '오후편성 프로그램',
                subtitle: '정규 수업 시간 이후에 운영되는 프로그램',
                child: Column(
                  children: [
                    DetailInfoRow(
                      icon: Icons.class_,
                      label: '수업 수',
                      value: '${afterSchool.afternoonClassCount}개',
                      valueColor: AppColors.secondary,
                    ),
                    const SizedBox(height: 8),
                    DetailInfoRow(
                      icon: Icons.groups,
                      label: '참여 인원',
                      value: '${afterSchool.afternoonParticipants}명',
                      valueColor: AppColors.success,
                    ),
                    if (afterSchool.afternoonClassCount > 0) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calculate,
                              color: AppColors.secondary,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '수업당 평균 인원: ${(afterSchool.afternoonParticipants / afterSchool.afternoonClassCount).toStringAsFixed(1)}명',
                              style: AppTextStyles.body2.copyWith(
                                color: AppColors.secondary,
                                fontWeight: FontWeight.w600,
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

            // 방과후 담당 인력
            DetailSectionCard(
              title: '담당 인력 현황',
              child: Column(
                children: [
                  DetailInfoRow(
                    icon: Icons.person,
                    label: '정규 교사',
                    value: '${afterSchool.regularTeacherCount}명',
                    valueColor: AppColors.primary,
                  ),
                  const SizedBox(height: 8),
                  DetailInfoRow(
                    icon: Icons.person_outline,
                    label: '계약 교사',
                    value: '${afterSchool.contractTeacherCount}명',
                    valueColor: AppColors.info,
                  ),
                  const SizedBox(height: 8),
                  DetailInfoRow(
                    icon: Icons.support_agent,
                    label: '전담 직원',
                    value: '${afterSchool.dedicatedStaffCount}명',
                    valueColor: AppColors.success,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 방과후 분석 정보
            _buildAnalysisCard(),
          ] else ...[
            // 방과후 프로그램 없음
            _buildNoAfterSchoolCard(),
          ],
        ],
      ),
    );
  }

  Widget _buildProgramOverview() {
    final totalClasses = afterSchool.independentClassCount + afterSchool.afternoonClassCount;
    final totalParticipants = afterSchool.independentParticipants + afterSchool.afternoonParticipants;
    final totalStaff = afterSchool.regularTeacherCount + afterSchool.contractTeacherCount + afterSchool.dedicatedStaffCount;

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
              '방과후 프로그램 현황',
              style: AppTextStyles.sectionTitle,
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _OverviewItem(
                    icon: Icons.class_,
                    label: '전체 수업',
                    count: totalClasses,
                    color: AppColors.primary,
                  ),
                ),
                Expanded(
                  child: _OverviewItem(
                    icon: Icons.groups,
                    label: '참여 인원',
                    count: totalParticipants,
                    color: AppColors.success,
                  ),
                ),
                Expanded(
                  child: _OverviewItem(
                    icon: Icons.people,
                    label: '담당 인력',
                    count: totalStaff,
                    color: AppColors.info,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisCard() {
    final totalStaff = afterSchool.regularTeacherCount + afterSchool.contractTeacherCount + afterSchool.dedicatedStaffCount;
    final totalParticipants = afterSchool.independentParticipants + afterSchool.afternoonParticipants;
    final staffParticipantRatio = totalStaff > 0 ? (totalParticipants / totalStaff) : 0.0;

    return Container(
      decoration: AppDecorations.cardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '방과후 프로그램 분석',
            style: AppTextStyles.sectionTitle,
          ),
          const SizedBox(height: 12),

          // 인력 대비 참여자 비율
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.analytics,
                      color: AppColors.info,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '인력 대비 참여자',
                      style: AppTextStyles.body2.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${staffParticipantRatio.toStringAsFixed(1)}:1',
                      style: AppTextStyles.body1.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.info,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '담당 인력 1명당 ${staffParticipantRatio.toStringAsFixed(1)}명의 원아를 담당',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.gray600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // 프로그램 유형 분석
          Row(
            children: [
              if (afterSchool.independentClassCount > 0)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '독립편성',
                          style: AppTextStyles.body2.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${afterSchool.independentClassCount}개 수업',
                          style: AppTextStyles.caption,
                        ),
                        Text(
                          '${afterSchool.independentParticipants}명 참여',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                ),

              if (afterSchool.independentClassCount > 0 && afterSchool.afternoonClassCount > 0)
                const SizedBox(width: 8),

              if (afterSchool.afternoonClassCount > 0)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.secondary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '오후편성',
                          style: AppTextStyles.body2.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.secondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${afterSchool.afternoonClassCount}개 수업',
                          style: AppTextStyles.caption,
                        ),
                        Text(
                          '${afterSchool.afternoonParticipants}명 참여',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoAfterSchoolCard() {
    return Container(
      decoration: AppDecorations.cardDecoration(),
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(
            Icons.schedule_outlined,
            size: 80,
            color: AppColors.gray400,
          ),
          const SizedBox(height: 16),
          Text(
            '방과후 프로그램 없음',
            style: AppTextStyles.emptyStateTitle,
          ),
          const SizedBox(height: 8),
          Text(
            '현재 방과후 프로그램을 운영하지 않고 있습니다.',
            style: AppTextStyles.emptyStateSubtitle,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _OverviewItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final Color color;

  const _OverviewItem({
    required this.icon,
    required this.label,
    required this.count,
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
            '$count개',
            style: AppTextStyles.headline6.copyWith(
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
