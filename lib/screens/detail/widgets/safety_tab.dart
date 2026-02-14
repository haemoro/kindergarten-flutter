import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/kindergarten_detail.dart';
import '../../../widgets/detail_section_card.dart';

class SafetyTab extends StatelessWidget {
  final SafetySection safety;

  const SafetyTab({
    super.key,
    required this.safety,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 환경 안전 점검
          DetailSectionCard(
            title: '환경 안전 점검',
            child: Column(
              children: [
                _SafetyCheckItem(
                  icon: Icons.air,
                  label: '공기질 점검',
                  result: safety.airQualityCheck,
                ),
                _SafetyCheckItem(
                  icon: Icons.cleaning_services,
                  label: '소독 점검',
                  result: safety.disinfectionCheck,
                ),
                _SafetyCheckItem(
                  icon: Icons.water_drop,
                  label: '수질 점검',
                  result: safety.waterQualityCheck,
                ),
                _SafetyCheckItem(
                  icon: Icons.grain,
                  label: '미세먼지 측정',
                  result: safety.dustMeasurement,
                ),
                _SafetyCheckItem(
                  icon: Icons.lightbulb,
                  label: '조도 측정',
                  result: safety.lightMeasurement,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 시설 안전 점검
          DetailSectionCard(
            title: '시설 안전 점검',
            child: Column(
              children: [
                _SafetyCheckItem(
                  icon: Icons.local_fire_department,
                  label: '가스 점검',
                  result: safety.gasCheck,
                ),
                _SafetyCheckItem(
                  icon: Icons.electrical_services,
                  label: '전기 점검',
                  result: safety.electricCheck,
                ),
                _SafetyCheckItem(
                  icon: Icons.toys,
                  label: '놀이시설 점검',
                  result: safety.playgroundCheck,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 보안 시설
          DetailSectionCard(
            title: 'CCTV 및 보안',
            child: Column(
              children: [
                DetailInfoRow(
                  icon: Icons.videocam,
                  label: 'CCTV 설치',
                  value: safety.cctvInstalled == 'Y' ? '설치됨' : '미설치',
                  valueColor: safety.cctvInstalled == 'Y'
                      ? AppColors.success
                      : AppColors.error,
                ),
                if (safety.cctvInstalled == 'Y') ...[
                  const SizedBox(height: 8),
                  DetailInfoRow(
                    icon: Icons.videocam_outlined,
                    label: 'CCTV 대수',
                    value: '${safety.cctvTotal}대',
                    valueColor: AppColors.primary,
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 보험 가입 현황
          DetailSectionCard(
            title: '보험 가입 현황',
            child: Column(
              children: [
                _InsuranceItem(
                  icon: Icons.local_fire_department,
                  label: '화재보험',
                  status: safety.fireInsuranceCheck,
                ),
                _InsuranceItem(
                  icon: Icons.shield,
                  label: '학교안전공제회',
                  status: safety.schoolSafetyEnrolled,
                ),
                _InsuranceItem(
                  icon: Icons.account_balance,
                  label: '교육시설공제회',
                  status: safety.educationFacilityEnrolled,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 종합 안전 등급
          _buildSafetySummary(),
        ],
      ),
    );
  }

  Widget _buildSafetySummary() {
    final checkItems = [
      safety.airQualityCheck,
      safety.disinfectionCheck,
      safety.waterQualityCheck,
      safety.dustMeasurement,
      safety.lightMeasurement,
      safety.gasCheck,
      safety.electricCheck,
      safety.playgroundCheck,
    ];

    final passCount = checkItems.where((item) =>
        item.contains('적합') || item.contains('양호')).length;
    final totalCount = checkItems.length;
    final passRate = (passCount / totalCount * 100);

    Color gradeColor;
    String grade;
    IconData gradeIcon;

    if (passRate >= 90) {
      grade = '매우 우수';
      gradeColor = AppColors.success;
      gradeIcon = Icons.star;
    } else if (passRate >= 80) {
      grade = '우수';
      gradeColor = AppColors.info;
      gradeIcon = Icons.star_half;
    } else if (passRate >= 70) {
      grade = '양호';
      gradeColor = AppColors.warning;
      gradeIcon = Icons.warning;
    } else {
      grade = '개선 필요';
      gradeColor = AppColors.error;
      gradeIcon = Icons.priority_high;
    }

    return Container(
      decoration: AppDecorations.cardDecoration(),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              gradeColor.withValues(alpha: 0.1),
              gradeColor.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: gradeColor.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: gradeColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    gradeIcon,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '종합 안전 등급',
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.gray600,
                        ),
                      ),
                      Text(
                        grade,
                        style: AppTextStyles.headline6.copyWith(
                          color: gradeColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${passRate.toStringAsFixed(0)}%',
                      style: AppTextStyles.headline5.copyWith(
                        color: gradeColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '$passCount/$totalCount 항목',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.gray600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SafetyCheckItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String result;

  const _SafetyCheckItem({
    required this.icon,
    required this.label,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final isPass = result.contains('적합') || result.contains('양호');
    final badgeColor = isPass ? AppColors.success : AppColors.error;
    final badgeIcon = isPass ? Icons.check_circle : Icons.cancel;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: AppColors.gray600,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.body2,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: badgeColor.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  badgeIcon,
                  size: 12,
                  color: badgeColor,
                ),
                const SizedBox(width: 4),
                Text(
                  result,
                  style: AppTextStyles.caption.copyWith(
                    color: badgeColor,
                    fontWeight: FontWeight.w600,
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

class _InsuranceItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String status;

  const _InsuranceItem({
    required this.icon,
    required this.label,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final isInsured = status.contains('가입');
    final statusColor = isInsured ? AppColors.success : AppColors.error;
    final statusIcon = isInsured ? Icons.check_circle : Icons.cancel;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: AppColors.gray600,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.body2,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                statusIcon,
                size: 16,
                color: statusColor,
              ),
              const SizedBox(width: 4),
              Text(
                status,
                style: AppTextStyles.body2.copyWith(
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
