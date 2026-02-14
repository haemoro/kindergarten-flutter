import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../providers/region_providers.dart';
import '../../../providers/kindergarten_providers.dart';
import '../../../models/region.dart';

class RegionSelector extends ConsumerWidget {
  const RegionSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(searchFilterProvider);
    final regionsAsync = ref.watch(regionsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('지역', style: AppTextStyles.sectionTitle),
        const SizedBox(height: 8),
        regionsAsync.when(
          data: (regionResponse) => _buildRegionDropdowns(
            context,
            ref,
            regionResponse.regions,
            filter,
          ),
          loading: () => const Row(
            children: [
              Expanded(
                child: Center(child: CircularProgressIndicator()),
              ),
            ],
          ),
          error: (error, stackTrace) => Text(
            '지역 정보를 불러올 수 없습니다: $error',
            style: AppTextStyles.errorText,
          ),
        ),
      ],
    );
  }

  Widget _buildRegionDropdowns(
    BuildContext context,
    WidgetRef ref,
    List<Region> regions,
    filter,
  ) {
    final selectedRegion = regions
        .cast<Region?>()
        .firstWhere(
          (region) => region?.sidoCode == filter.sidoCode,
          orElse: () => null,
        );

    return Column(
      children: [
        // Sido selector
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: DropdownButtonFormField<String>(
            initialValue: filter.sidoCode,
            decoration: InputDecoration(
              hintText: '시/도 선택',
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
            ),
            items: [
              const DropdownMenuItem<String>(
                value: null,
                child: Text('전체'),
              ),
              ...regions.map(
                (region) => DropdownMenuItem<String>(
                  value: region.sidoCode,
                  child: Text(region.sidoName),
                ),
              ),
            ],
            onChanged: (sidoCode) => _onSidoChanged(ref, sidoCode),
          ),
        ),

        // Sgg selector (when sido selected)
        if (selectedRegion != null) ...[
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: DropdownButtonFormField<String>(
              initialValue: filter.sggCode,
              decoration: InputDecoration(
                hintText: '시/군/구 선택',
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('전체'),
                ),
                ...selectedRegion.sggList.map(
                  (district) => DropdownMenuItem<String>(
                    value: district.sggCode,
                    child: Text(district.sggName),
                  ),
                ),
              ],
              onChanged: (sggCode) => _onSggChanged(ref, sggCode),
            ),
          ),
        ],
      ],
    );
  }

  void _onSidoChanged(WidgetRef ref, String? sidoCode) {
    final currentFilter = ref.read(searchFilterProvider);
    final newFilter = currentFilter.copyWith(
      sidoCode: sidoCode,
      sggCode: null,
    );
    ref.read(searchFilterProvider.notifier).state = newFilter;
  }

  void _onSggChanged(WidgetRef ref, String? sggCode) {
    final currentFilter = ref.read(searchFilterProvider);
    final newFilter = currentFilter.copyWith(sggCode: sggCode);
    ref.read(searchFilterProvider.notifier).state = newFilter;
  }
}
