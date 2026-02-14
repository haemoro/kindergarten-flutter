import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/map_marker.dart';
import '../../../widgets/badge_chip.dart';

class MarkerBottomSheet extends StatelessWidget {
  final MapMarker kindergarten;
  final VoidCallback? onDetailPressed;

  const MarkerBottomSheet({
    super.key,
    required this.kindergarten,
    this.onDetailPressed,
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

          // 유치원 정보
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      kindergarten.name,
                      style: AppTextStyles.headline6,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    BadgeChip.establishType(
                      label: kindergarten.establishType,
                      establishType: kindergarten.establishType,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.close),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 위치 정보
          Row(
            children: [
              const Icon(
                Icons.location_on,
                size: 16,
                color: AppColors.gray600,
              ),
              const SizedBox(width: 8),
              Text(
                '위도: ${kindergarten.lat.toStringAsFixed(6)}',
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.gray600,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '경도: ${kindergarten.lng.toStringAsFixed(6)}',
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.gray600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // 액션 버튼들
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    // TODO: 길찾기 앱 연결
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
                  onPressed: onDetailPressed ?? () {
                    Navigator.pop(context);
                    context.push('/detail/${kindergarten.id}');
                  },
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