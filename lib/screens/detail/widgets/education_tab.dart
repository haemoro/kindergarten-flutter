import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/kindergarten_detail.dart';
import '../../../widgets/detail_section_card.dart';

class EducationTab extends StatelessWidget {
  final EducationSection education;

  const EducationTab({
    super.key,
    required this.education,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 연령별 학급수
          DetailSectionCard(
            title: '연령별 학급수',
            child: _AgeTable(
              age3Label: '3세',
              age4Label: '4세',
              age5Label: '5세',
              mixedLabel: '혼합',
              specialLabel: '특수',
              age3Value: education.classCountByAge.age3,
              age4Value: education.classCountByAge.age4,
              age5Value: education.classCountByAge.age5,
              mixedValue: education.classCountByAge.mixed,
              specialValue: education.classCountByAge.special,
              unit: '개',
              total: education.classCountByAge.total,
            ),
          ),

          const SizedBox(height: 16),

          // 연령별 정원
          DetailSectionCard(
            title: '연령별 정원',
            child: _AgeTable(
              age3Label: '3세',
              age4Label: '4세',
              age5Label: '5세',
              mixedLabel: '혼합',
              specialLabel: '특수',
              age3Value: education.capacityByAge.age3,
              age4Value: education.capacityByAge.age4,
              age5Value: education.capacityByAge.age5,
              mixedValue: education.capacityByAge.mixed,
              specialValue: education.capacityByAge.special,
              unit: '명',
              total: education.capacityByAge.total,
            ),
          ),

          const SizedBox(height: 16),

          // 연령별 현원
          DetailSectionCard(
            title: '연령별 현원',
            child: Column(
              children: [
                _AgeTable(
                  age3Label: '3세',
                  age4Label: '4세',
                  age5Label: '5세',
                  mixedLabel: '혼합',
                  specialLabel: '특수',
                  age3Value: education.enrollmentByAge.age3,
                  age4Value: education.enrollmentByAge.age4,
                  age5Value: education.enrollmentByAge.age5,
                  mixedValue: education.enrollmentByAge.mixed,
                  specialValue: education.enrollmentByAge.special,
                  unit: '명',
                  total: education.enrollmentByAge.total,
                ),
                const SizedBox(height: 12),
                // 재원률 표시
                if (education.capacityByAge.total > 0)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.gray100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.people,
                          size: 16,
                          color: AppColors.gray600,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '전체 재원률: ${((education.enrollmentByAge.total / education.capacityByAge.total) * 100).toStringAsFixed(1)}%',
                          style: AppTextStyles.body2.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 수업일수
          DetailSectionCard(
            title: '연령별 수업일수',
            child: Column(
              children: [
                DetailInfoRow(label: '3세', value: '${education.lessonDaysAge3}일'),
                DetailInfoRow(label: '4세', value: '${education.lessonDaysAge4}일'),
                DetailInfoRow(label: '5세', value: '${education.lessonDaysAge5}일'),
                if (education.lessonDaysMixed != null)
                  DetailInfoRow(label: '혼합', value: '${education.lessonDaysMixed}일'),
                const Divider(),
                DetailInfoRow(
                  label: '법정일수 미만 여부',
                  value: education.belowLegalDays == 'Y' ? '예' : '아니오',
                  valueColor: education.belowLegalDays == 'Y'
                      ? AppColors.warning
                      : AppColors.success,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AgeTable extends StatelessWidget {
  final String age3Label;
  final String age4Label;
  final String age5Label;
  final String mixedLabel;
  final String specialLabel;
  final int age3Value;
  final int age4Value;
  final int age5Value;
  final int mixedValue;
  final int specialValue;
  final String unit;
  final int total;

  const _AgeTable({
    required this.age3Label,
    required this.age4Label,
    required this.age5Label,
    required this.mixedLabel,
    required this.specialLabel,
    required this.age3Value,
    required this.age4Value,
    required this.age5Value,
    required this.mixedValue,
    required this.specialValue,
    required this.unit,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Table(
      border: TableBorder.all(color: AppColors.gray300, width: 1),
      children: [
        // 헤더
        TableRow(
          decoration: const BoxDecoration(color: AppColors.gray100),
          children: [
            _TableCell(age3Label, isHeader: true),
            _TableCell(age4Label, isHeader: true),
            _TableCell(age5Label, isHeader: true),
            _TableCell(mixedLabel, isHeader: true),
            _TableCell(specialLabel, isHeader: true),
            _TableCell('합계', isHeader: true),
          ],
        ),
        // 데이터
        TableRow(
          children: [
            _TableCell('$age3Value$unit'),
            _TableCell('$age4Value$unit'),
            _TableCell('$age5Value$unit'),
            _TableCell('$mixedValue$unit'),
            _TableCell('$specialValue$unit'),
            _TableCell(
              '$total$unit',
              textStyle: AppTextStyles.tableContent.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TableCell extends StatelessWidget {
  final String text;
  final bool isHeader;
  final TextStyle? textStyle;

  const _TableCell(
    this.text, {
    this.isHeader = false,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: textStyle ?? (isHeader
            ? AppTextStyles.tableHeader
            : AppTextStyles.tableContent),
      ),
    );
  }
}
