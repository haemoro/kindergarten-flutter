import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/map_marker.dart';
import '../../../widgets/badge_chip.dart';

class MarkerBottomSheet extends StatelessWidget {
  final MapMarker kindergarten;
  final VoidCallback? onDetailPressed;
  final VoidCallback? onClose;

  const MarkerBottomSheet({
    super.key,
    required this.kindergarten,
    this.onDetailPressed,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 핸들 바
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.gray300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 유치원 이름 + 유형 배지 + 닫기
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        kindergarten.name,
                        style: AppTextStyles.headline6,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    BadgeChip.establishType(
                      label: kindergarten.establishType,
                      establishType: kindergarten.establishType,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onClose,
                icon: const Icon(Icons.close),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),

          const SizedBox(height: 4),

          // 주소
          if (kindergarten.address != null && kindergarten.address!.isNotEmpty)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: AppColors.gray500,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    kindergarten.address!,
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.gray600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

          // 전화번호
          if (kindergarten.phone != null && kindergarten.phone!.isNotEmpty) ...[
            const SizedBox(height: 6),
            GestureDetector(
              onTap: () => launchUrl(Uri.parse('tel:${kindergarten.phone}')),
              child: Row(
                children: [
                  const Icon(
                    Icons.phone_outlined,
                    size: 16,
                    color: AppColors.gray500,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    kindergarten.phone!,
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 20),

          // 액션 버튼들
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    onClose?.call();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('길찾기 기능 구현 예정')),
                    );
                  },
                  icon: const Icon(Icons.directions),
                  label: const Text('길찾기'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onDetailPressed,
                  icon: const Icon(Icons.info),
                  label: const Text('상세보기'),
                ),
              ),
            ],
          ),

          // 하단 여백 (Safe Area)
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}