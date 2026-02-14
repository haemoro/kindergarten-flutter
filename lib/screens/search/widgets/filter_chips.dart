import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../providers/kindergarten_providers.dart';

class FilterChips extends ConsumerWidget {
  const FilterChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(searchFilterProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Establish type
        Text('설립유형', style: AppTextStyles.sectionTitle),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            _DesignChip(
              label: '전체',
              isSelected: filter.type == null || filter.type!.isEmpty,
              onTap: () => _onEstablishTypeChanged(ref, null),
            ),
            ...AppConstants.establishTypes.map(
              (type) => _DesignChip(
                label: type,
                isSelected: filter.type == type,
                onTap: () => _onEstablishTypeChanged(ref, type),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Sort
        Text('정렬', style: AppTextStyles.sectionTitle),
        const SizedBox(height: 8),
        Row(
          children: [
            _DesignChip(
              label: '거리순',
              isSelected: filter.sort == 'distance',
              onTap: () => _onSortChanged(ref, 'distance'),
            ),
            const SizedBox(width: 8),
            _DesignChip(
              label: '이름순',
              isSelected: filter.sort == 'name',
              onTap: () => _onSortChanged(ref, 'name'),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Radius (when location available)
        if (filter.hasLocation) ...[
          Text('검색 반경', style: AppTextStyles.sectionTitle),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: AppConstants.radiusOptions.map(
              (radius) => _DesignChip(
                label: '${radius.toInt()}km',
                isSelected: filter.radiusKm == radius,
                onTap: () => _onRadiusChanged(ref, radius),
              ),
            ).toList(),
          ),
        ],
      ],
    );
  }

  void _onEstablishTypeChanged(WidgetRef ref, String? type) {
    final currentFilter = ref.read(searchFilterProvider);
    final newFilter = currentFilter.copyWith(type: type);
    ref.read(searchFilterProvider.notifier).state = newFilter;
  }

  void _onSortChanged(WidgetRef ref, String sort) {
    final currentFilter = ref.read(searchFilterProvider);
    final newFilter = currentFilter.copyWith(sort: sort);
    ref.read(searchFilterProvider.notifier).state = newFilter;
  }

  void _onRadiusChanged(WidgetRef ref, double radius) {
    final currentFilter = ref.read(searchFilterProvider);
    final newFilter = currentFilter.copyWith(radiusKm: radius);
    ref.read(searchFilterProvider.notifier).state = newFilter;
  }
}

/// Design Course style chip: gradient when selected, white+border+shadow when not
class _DesignChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _DesignChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: isSelected
            ? BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
              )
            : BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.gray300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
        child: Text(
          label,
          style: AppTextStyles.chipText.copyWith(
            color: isSelected ? Colors.white : AppColors.onSurface,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
