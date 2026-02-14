import 'package:flutter/material.dart';
import '../core/theme/app_text_styles.dart';
import '../core/theme/app_decorations.dart';
import '../core/utils/establish_type_helper.dart';
import '../models/kindergarten_search.dart';
import 'badge_chip.dart';

/// Home screen horizontal scroll compact card
class KindergartenCompactCard extends StatelessWidget {
  final KindergartenSearch kindergarten;
  final VoidCallback? onTap;

  const KindergartenCompactCard({
    super.key,
    required this.kindergarten,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 220,
        margin: const EdgeInsets.only(right: 12),
        decoration: AppDecorations.cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top color strip
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: EstablishTypeHelper.getColor(kindergarten.establishType),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      kindergarten.name,
                      style: AppTextStyles.kindergartenName.copyWith(fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    // Badge + distance
                    Row(
                      children: [
                        BadgeChip.establishType(
                          label: kindergarten.establishType,
                          establishType: kindergarten.establishType,
                        ),
                        if (kindergarten.formattedDistance.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Text(
                            kindergarten.formattedDistance,
                            style: AppTextStyles.distanceText,
                          ),
                        ],
                      ],
                    ),
                    const Spacer(),
                    // Capacity
                    Text(
                      '정원 ${kindergarten.capacity}명 / 현원 ${kindergarten.currentEnrollment}명',
                      style: AppTextStyles.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    // Service badges
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: [
                        if (kindergarten.mealProvided)
                          const BadgeChip.meal(label: '급식'),
                        if (kindergarten.busAvailable)
                          const BadgeChip.bus(label: '통학버스'),
                        if (kindergarten.extendedCare)
                          const BadgeChip.extendedCare(label: '연장돌봄'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
