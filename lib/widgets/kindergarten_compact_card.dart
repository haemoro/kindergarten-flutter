import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/theme/app_decorations.dart';
import '../core/utils/establish_type_helper.dart';
import '../models/kindergarten_search.dart';
import 'badge_chip.dart';

/// Home screen horizontal scroll compact card
class KindergartenCompactCard extends StatelessWidget {
  final KindergartenSearch kindergarten;
  final VoidCallback? onTap;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;

  const KindergartenCompactCard({
    super.key,
    required this.kindergarten,
    this.onTap,
    this.isFavorite = false,
    this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
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
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name + Favorite heart
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            kindergarten.name,
                            style: AppTextStyles.kindergartenName.copyWith(fontSize: 13),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (onFavoriteToggle != null)
                          Semantics(
                            label: isFavorite ? '즐겨찾기 해제' : '즐겨찾기 추가',
                            button: true,
                            child: GestureDetector(
                              onTap: onFavoriteToggle,
                              behavior: HitTestBehavior.opaque,
                              child: Padding(
                                padding: const EdgeInsets.all(6),
                                child: Icon(
                                  isFavorite ? Icons.favorite : Icons.favorite_border,
                                  size: 18,
                                  color: isFavorite ? AppColors.favoriteActive : AppColors.gray400,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Badge + distance
                    Row(
                      children: [
                        BadgeChip.establishType(
                          label: kindergarten.establishType,
                          establishType: kindergarten.establishType,
                        ),
                        if (kindergarten.formattedDistance.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Text(
                            kindergarten.formattedDistance,
                            style: AppTextStyles.distanceText,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Capacity / current enrollment
                    Text(
                      '정원 ${kindergarten.capacity}명 | 현원 ${kindergarten.currentEnrollment}명',
                      style: AppTextStyles.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    // Address
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 12,
                          color: AppColors.gray500,
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            kindergarten.address,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.gray500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
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
