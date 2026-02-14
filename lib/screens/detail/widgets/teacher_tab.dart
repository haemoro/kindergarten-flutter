import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/kindergarten_detail.dart';
import '../../../widgets/detail_section_card.dart';

class TeacherTab extends StatelessWidget {
  final TeacherSection teacher;

  const TeacherTab({
    super.key,
    required this.teacher,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 전체 교직원 현황
          _buildOverviewCard(),

          const SizedBox(height: 16),

          // 직급별 현황
          DetailSectionCard(
            title: '직급별 현황',
            child: Column(
              children: [
                _TeacherTypeRow(
                  icon: Icons.manage_accounts,
                  label: '원장',
                  count: teacher.directorCount,
                  color: AppColors.primary,
                ),
                _TeacherTypeRow(
                  icon: Icons.supervisor_account,
                  label: '원감',
                  count: teacher.viceDirectorCount,
                  color: AppColors.secondary,
                ),
                _TeacherTypeRow(
                  icon: Icons.star,
                  label: '수석교사',
                  count: teacher.masterTeacherCount,
                  color: AppColors.success,
                ),
                _TeacherTypeRow(
                  icon: Icons.school,
                  label: '보직교사',
                  count: teacher.leadTeacherCount,
                  color: AppColors.info,
                ),
                _TeacherTypeRow(
                  icon: Icons.person,
                  label: '일반교사',
                  count: teacher.generalTeacherCount,
                  color: AppColors.warning,
                ),
                _TeacherTypeRow(
                  icon: Icons.accessibility,
                  label: '특수교사',
                  count: teacher.specialTeacherCount,
                  color: AppColors.primary,
                ),
                _TeacherTypeRow(
                  icon: Icons.health_and_safety,
                  label: '보건교사',
                  count: teacher.healthTeacherCount,
                  color: AppColors.success,
                ),
                _TeacherTypeRow(
                  icon: Icons.restaurant,
                  label: '영양교사',
                  count: teacher.nutritionTeacherCount,
                  color: AppColors.secondary,
                ),
                _TeacherTypeRow(
                  icon: Icons.work,
                  label: '직원',
                  count: teacher.staffCount,
                  color: AppColors.gray600,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 자격별 현황
          DetailSectionCard(
            title: '자격별 현황',
            child: Column(
              children: [
                _QualificationRow(
                  label: '정교사 (1급)',
                  count: teacher.masterQualCount,
                  level: 'master',
                ),
                _QualificationRow(
                  label: '정교사 (2급)',
                  count: teacher.grade1QualCount,
                  level: 'grade1',
                ),
                _QualificationRow(
                  label: '준교사',
                  count: teacher.grade2QualCount,
                  level: 'grade2',
                ),
                _QualificationRow(
                  label: '보조교사',
                  count: teacher.assistantQualCount,
                  level: 'assistant',
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 경력별 현황
          DetailSectionCard(
            title: '경력별 현황',
            child: Column(
              children: [
                _ExperienceRow(
                  label: '1년 미만',
                  count: teacher.under1Year,
                ),
                _ExperienceRow(
                  label: '1~2년',
                  count: teacher.between1And2Years,
                ),
                _ExperienceRow(
                  label: '2~4년',
                  count: teacher.between2And4Years,
                ),
                _ExperienceRow(
                  label: '4~6년',
                  count: teacher.between4And6Years,
                ),
                _ExperienceRow(
                  label: '6년 이상',
                  count: teacher.over6Years,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 교사 분석 정보
          _buildAnalysisCard(),
        ],
      ),
    );
  }

  Widget _buildOverviewCard() {
    final totalTeachers = teacher.totalTeacherCount;
    final totalStaff = teacher.staffCount;
    final totalAll = totalTeachers + totalStaff;

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
              '전체 교직원 현황',
              style: AppTextStyles.sectionTitle,
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _OverviewItem(
                    icon: Icons.people,
                    label: '교사',
                    count: totalTeachers,
                    color: AppColors.primary,
                  ),
                ),
                Expanded(
                  child: _OverviewItem(
                    icon: Icons.work,
                    label: '직원',
                    count: totalStaff,
                    color: AppColors.secondary,
                  ),
                ),
                Expanded(
                  child: _OverviewItem(
                    icon: Icons.groups,
                    label: '전체',
                    count: totalAll,
                    color: AppColors.success,
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
    final totalTeachers = teacher.totalTeacherCount;
    final qualifiedTeachers = teacher.masterQualCount + teacher.grade1QualCount;
    final experiencedTeachers = teacher.between4And6Years + teacher.over6Years;

    final qualificationRate = totalTeachers > 0
        ? (qualifiedTeachers / totalTeachers * 100)
        : 0.0;
    final experienceRate = totalTeachers > 0
        ? (experiencedTeachers / totalTeachers * 100)
        : 0.0;

    return Container(
      decoration: AppDecorations.cardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '교사 전문성 분석',
            style: AppTextStyles.sectionTitle,
          ),
          const SizedBox(height: 12),

          // 자격 분석
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
                      Icons.verified,
                      color: AppColors.info,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '정교사 비율',
                      style: AppTextStyles.body2.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${qualificationRate.toStringAsFixed(1)}%',
                      style: AppTextStyles.body1.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.info,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '정교사 자격을 보유한 교사: $qualifiedTeachers명',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.gray600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // 경력 분석
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.trending_up,
                      color: AppColors.success,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '경력교사 비율',
                      style: AppTextStyles.body2.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${experienceRate.toStringAsFixed(1)}%',
                      style: AppTextStyles.body1.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '4년 이상 경력 교사: $experiencedTeachers명',
                  style: AppTextStyles.caption.copyWith(
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
            '$count명',
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

class _TeacherTypeRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final Color color;

  const _TeacherTypeRow({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              icon,
              size: 16,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.body2,
            ),
          ),
          Text(
            '$count명',
            style: AppTextStyles.body2.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _QualificationRow extends StatelessWidget {
  final String label;
  final int count;
  final String level;

  const _QualificationRow({
    required this.label,
    required this.count,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    Color levelColor;
    IconData levelIcon;

    switch (level) {
      case 'master':
        levelColor = AppColors.primary;
        levelIcon = Icons.star;
        break;
      case 'grade1':
        levelColor = AppColors.info;
        levelIcon = Icons.star_half;
        break;
      case 'grade2':
        levelColor = AppColors.warning;
        levelIcon = Icons.star_outline;
        break;
      default:
        levelColor = AppColors.gray500;
        levelIcon = Icons.circle_outlined;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            levelIcon,
            size: 16,
            color: levelColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.body2,
            ),
          ),
          Text(
            '$count명',
            style: AppTextStyles.body2.copyWith(
              fontWeight: FontWeight.w600,
              color: levelColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExperienceRow extends StatelessWidget {
  final String label;
  final int count;

  const _ExperienceRow({
    required this.label,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            Icons.schedule,
            size: 16,
            color: AppColors.gray600,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.body2,
            ),
          ),
          Text(
            '$count명',
            style: AppTextStyles.body2.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
