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
  final bool isFavorite;

  const KindergartenListTile({
    super.key,
    required this.kindergarten,
    this.onTap,
    this.onFavoriteToggle,
    this.isFavorite = false,
  });

  @override
  Widget build(BuildContext context) {
    final typeColor = EstablishTypeHelper.getColor(kindergarten.establishType);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header (name + badge + favorite)
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  kindergarten.name,
                                  style: AppTextStyles.kindergartenName,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                BadgeChip.establishType(
                                  label: kindergarten.establishType,
                                  establishType: kindergarten.establishType,
                                ),
                              ],
                            ),
                          ),
                          if (onFavoriteToggle != null)
                            IconButton(
                              onPressed: onFavoriteToggle,
                              icon: Icon(
                                isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: isFavorite
                                    ? AppColors.favoriteActive
                                    : AppColors.favoriteInactive,
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Address
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 16,
                            color: AppColors.gray500,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              kindergarten.address,
                              style: AppTextStyles.kindergartenAddress,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (kindergarten.distanceKm != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              kindergarten.formattedDistance,
                              style: AppTextStyles.distanceText,
                            ),
                          ],
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Phone
                      Row(
                        children: [
                          Icon(
                            Icons.phone,
                            size: 16,
                            color: AppColors.gray500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            kindergarten.phone,
                            style: AppTextStyles.kindergartenAddress,
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Capacity info
                      Row(
                        children: [
                          Text(
                            '정원: ${kindergarten.capacity}명',
                            style: AppTextStyles.body2,
                          ),
                          const SizedBox(width: 16),
                          Text(
                            '현원: ${kindergarten.currentEnrollment}명',
                            style: AppTextStyles.body2,
                          ),
                          const SizedBox(width: 16),
                          Text(
                            '학급: ${kindergarten.totalClassCount}개',
                            style: AppTextStyles.body2,
                          ),
                        ],
                      ),

                      // Occupancy rate bar
                      if (kindergarten.capacity > 0) ...[
                        const SizedBox(height: 10),
                        _OccupancyBar(rate: kindergarten.occupancyRate),
                        const SizedBox(height: 4),
                        Text(
                          '재원률: ${(kindergarten.occupancyRate * 100).toStringAsFixed(1)}%',
                          style: AppTextStyles.caption,
                        ),
                      ],

                      const SizedBox(height: 12),

                      // Service badges
                      Wrap(
                        spacing: 8,
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

/// Rounded gradient occupancy bar
class _OccupancyBar extends StatelessWidget {
  final double rate;

  const _OccupancyBar({required this.rate});

  @override
  Widget build(BuildContext context) {
    final color = rate > 0.9
        ? AppColors.error
        : rate > 0.7
            ? AppColors.warning
            : AppColors.success;

    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        height: 6,
        child: LinearProgressIndicator(
          value: rate,
          backgroundColor: AppColors.gray200,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ),
    );
  }
}
