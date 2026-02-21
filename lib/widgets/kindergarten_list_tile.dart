import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/theme/app_decorations.dart';
import '../core/utils/establish_type_helper.dart';
import '../models/kindergarten_search.dart';
import 'badge_chip.dart';

class KindergartenListTile extends StatelessWidget {
  final KindergartenSearch kindergarten;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle;
  final VoidCallback? onMapView;
  final bool isFavorite;

  const KindergartenListTile({
    super.key,
    required this.kindergarten,
    this.onTap,
    this.onFavoriteToggle,
    this.onMapView,
    this.isFavorite = false,
  });

  @override
  Widget build(BuildContext context) {
    final typeColor = EstablishTypeHelper.getColor(kindergarten.establishType);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: AppDecorations.cardDecoration(),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Left color strip
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: typeColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
              ),
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Row 1: name + badge + favorite
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    kindergarten.name,
                                    style: AppTextStyles.kindergartenName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                BadgeChip.establishType(
                                  label: kindergarten.establishType,
                                  establishType: kindergarten.establishType,
                                ),
                              ],
                            ),
                          ),
                          if (onFavoriteToggle != null)
                            GestureDetector(
                              onTap: onFavoriteToggle,
                              behavior: HitTestBehavior.opaque,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 4),
                                child: Icon(
                                  isFavorite ? Icons.favorite : Icons.favorite_border,
                                  size: 20,
                                  color: isFavorite
                                      ? AppColors.favoriteActive
                                      : AppColors.favoriteInactive,
                                ),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      // Row 2: address + distance
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 14,
                            color: AppColors.gray500,
                          ),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              kindergarten.address,
                              style: AppTextStyles.caption.copyWith(color: AppColors.gray600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (kindergarten.distanceKm != null) ...[
                            const SizedBox(width: 6),
                            Text(
                              kindergarten.formattedDistance,
                              style: AppTextStyles.distanceText,
                            ),
                          ],
                        ],
                      ),

                      const SizedBox(height: 6),

                      // Row 3: capacity + service badges + map
                      Row(
                        children: [
                          Text(
                            '정원 ${kindergarten.capacity} · 현원 ${kindergarten.currentEnrollment} · ${(kindergarten.occupancyRate * 100).toStringAsFixed(0)}%',
                            style: AppTextStyles.caption.copyWith(color: AppColors.gray500),
                          ),
                          const Spacer(),
                          if (onMapView != null)
                            GestureDetector(
                              onTap: onMapView,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.map_outlined, size: 13, color: AppColors.primary),
                                  const SizedBox(width: 2),
                                  Text(
                                    '지도',
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      // Row 4: service badges
                      Wrap(
                        spacing: 6,
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
      ),
    );
  }
}
