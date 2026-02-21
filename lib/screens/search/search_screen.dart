import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/kindergarten_providers.dart';
import '../../providers/favorite_providers.dart';
import '../../providers/location_providers.dart';
import '../../providers/region_providers.dart';
import '../../models/search_filter.dart';
import '../../models/region.dart';
import '../../widgets/kindergarten_list_tile.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_state.dart';
import '../../widgets/staggered_animation.dart';
import '../../widgets/shimmer_loading.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;
  AnimationController? _staggerController;
  int _previousItemCount = 0;

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
    _scrollController.addListener(_onScroll);

    final initialFilter = ref.read(searchFilterProvider);
    if (initialFilter.q != null) {
      _searchController.text = initialFilter.q!;
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    _debounceTimer?.cancel();
    _staggerController?.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(paginatedSearchProvider.notifier).loadNextPage();
    }
  }

  void _triggerStaggerAnimation(int itemCount) {
    if (itemCount > 0 && itemCount != _previousItemCount) {
      _staggerController?.dispose();
      _staggerController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      )..forward();
      _previousItemCount = itemCount;
    }
  }

  Future<void> _requestLocationPermission() async {
    final permission = await ref.read(locationPermissionStatusProvider.future);

    if (permission == LocationPermission.denied) {
      final newPermission = await ref.read(
        requestLocationPermissionProvider(null).future,
      );
      if (newPermission == LocationPermission.whileInUse ||
          newPermission == LocationPermission.always) {
        _updateLocationInFilter();
      }
    } else if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      _updateLocationInFilter();
    }
  }

  Future<void> _updateLocationInFilter() async {
    final position = await ref.read(currentPositionProvider.future);
    if (position != null) {
      final currentFilter = ref.read(searchFilterProvider);
      final newFilter = currentFilter.copyWith(
        lat: position.latitude,
        lng: position.longitude,
      );
      ref.read(searchFilterProvider.notifier).state = newFilter;
    }
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(AppConstants.searchDebounceTime, () {
      final currentFilter = ref.read(searchFilterProvider);
      ref.read(searchFilterProvider.notifier).state =
          currentFilter.copyWith(q: query.isEmpty ? null : query);
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _debounceTimer?.cancel();
    final currentFilter = ref.read(searchFilterProvider);
    ref.read(searchFilterProvider.notifier).state =
        currentFilter.copyWith(q: null);
  }

  // --- 필터 바텀시트 ---

  void _showTypeFilter() {
    final filter = ref.read(searchFilterProvider);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _FilterSheet(
        title: '설립유형',
        options: ['전체', ...AppConstants.establishTypes],
        selected: filter.type ?? '전체',
        onSelected: (value) {
          ref.read(searchFilterProvider.notifier).state =
              filter.copyWith(type: value == '전체' ? null : value);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showSortFilter() {
    final filter = ref.read(searchFilterProvider);
    final labels = AppConstants.sortLabels;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _FilterSheet(
        title: '정렬',
        options: labels.values.toList(),
        selected: labels[filter.sort] ?? '거리순',
        onSelected: (value) {
          final sort = labels.entries
              .firstWhere((e) => e.value == value)
              .key;
          ref.read(searchFilterProvider.notifier).state =
              filter.copyWith(sort: sort);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showRegionFilter() {
    final filter = ref.read(searchFilterProvider);
    final regionsAsync = ref.read(regionsProvider);
    regionsAsync.whenData((regionResponse) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (context) => _RegionFilterSheet(
          regions: regionResponse.regions,
          selectedSidoCode: filter.sidoCode,
          selectedSggCode: filter.sggCode,
          onSelected: (sidoCode, sggCode) {
            ref.read(searchFilterProvider.notifier).state =
                filter.copyWith(sidoCode: sidoCode, sggCode: sggCode);
            Navigator.pop(context);
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(paginatedSearchProvider);
    final filter = ref.watch(searchFilterProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 검색바
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.gray100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 14),
                    const Icon(Icons.search, color: AppColors.gray500, size: 22),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        textAlignVertical: TextAlignVertical.center,
                        decoration: InputDecoration(
                          hintText: '유치원 이름이나 주소를 검색하세요',
                          hintStyle: AppTextStyles.body2.copyWith(
                            color: AppColors.gray500,
                            height: 1.0,
                          ),
                          border: InputBorder.none,
                          isCollapsed: true,
                        ),
                        style: AppTextStyles.body2.copyWith(height: 1.0),
                      ),
                    ),
                    if (_searchController.text.isNotEmpty)
                      GestureDetector(
                        onTap: _clearSearch,
                        child: const Padding(
                          padding: EdgeInsets.all(10),
                          child: Icon(Icons.close, color: AppColors.gray400, size: 20),
                        ),
                      )
                    else
                      const SizedBox(width: 14),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // 필터 칩 가로스크롤
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _FilterButton(
                    label: filter.type ?? '설립유형',
                    isActive: filter.hasType,
                    onTap: _showTypeFilter,
                  ),
                  const SizedBox(width: 8),
                  _FilterButton(
                    label: _getRegionLabel(filter),
                    isActive: filter.hasRegion,
                    onTap: _showRegionFilter,
                  ),
                  const SizedBox(width: 8),
                  _FilterButton(
                    label: _getSortLabel(filter.sort),
                    isActive: filter.sort != 'distance',
                    onTap: _showSortFilter,
                  ),
                  // 필터 초기화
                  if (filter.hasType || filter.hasRegion || filter.sort != 'distance') ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        ref.read(searchFilterProvider.notifier).state = filter.reset();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppColors.gray300),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(Icons.refresh, size: 18, color: AppColors.gray500),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 8),

            // 결과 수
            if (!searchState.isInitialLoading && searchState.items.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${searchState.totalElements}개 유치원',
                    style: AppTextStyles.caption.copyWith(color: AppColors.gray600),
                  ),
                ),
              ),

            // 결과 목록
            Expanded(
              child: _buildSearchResults(searchState),
            ),
          ],
        ),
      ),
    );
  }

  String _getRegionLabel(SearchFilter filter) {
    if (!filter.hasRegion) return '지역';
    final regionsAsync = ref.read(regionsProvider);
    return regionsAsync.whenOrNull(
          data: (regionResponse) {
            final regions = regionResponse.regions;
            final idx = regions.indexWhere((r) => r.sidoCode == filter.sidoCode);
            if (idx == -1) return '지역';
            final region = regions[idx];
            if (filter.sggCode != null) {
              final sggIdx = region.sggList.indexWhere((d) => d.sggCode == filter.sggCode);
              if (sggIdx != -1) return '${region.sidoName} ${region.sggList[sggIdx].sggName}';
            }
            return region.sidoName;
          },
        ) ??
        '지역';
  }

  String _getSortLabel(String sort) {
    return AppConstants.sortLabels[sort] ?? '거리순';
  }

  Widget _buildSearchResults(PaginatedSearchState searchState) {
    if (searchState.isInitialLoading) {
      return ListView(
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          ShimmerListTile(),
          ShimmerListTile(),
          ShimmerListTile(),
          ShimmerListTile(),
          ShimmerListTile(),
        ],
      );
    }

    if (searchState.error != null && searchState.items.isEmpty) {
      return ErrorState(
        message: searchState.error!,
        onRetry: () {
          ref.read(paginatedSearchProvider.notifier).loadFirstPage();
        },
      );
    }

    if (searchState.items.isEmpty) {
      final filter = ref.read(searchFilterProvider);
      return EmptyState(
        title: '검색 결과가 없습니다',
        subtitle: filter.hasQuery || filter.hasType || filter.hasRegion
            ? '다른 조건으로 검색해보세요'
            : '위치 권한을 허용하면 주변 유치원을 찾을 수 있어요',
        actionText: '필터 초기화',
        onAction: () {
          _searchController.clear();
          final currentFilter = ref.read(searchFilterProvider);
          ref.read(searchFilterProvider.notifier).state = currentFilter.reset();
        },
      );
    }

    final kindergartens = searchState.items;
    _triggerStaggerAnimation(kindergartens.length);

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: kindergartens.length + (searchState.hasNextPage ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= kindergartens.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final kindergarten = kindergartens[index];
        final isFav = ref.watch(isFavoriteProvider(kindergarten.id));

        final tile = KindergartenListTile(
          kindergarten: kindergarten,
          onTap: () => context.push('/detail/${kindergarten.id}'),
          onFavoriteToggle: () => toggleFavorite(ref, kindergarten.id),
          onMapView: () {
            ref.read(mapFocusLocationProvider.notifier).state =
                (lat: kindergarten.lat, lng: kindergarten.lng);
            context.go('/map');
          },
          isFavorite: isFav,
        );

        if (_staggerController != null && index < 10) {
          final animation = StaggeredListItem.createAnimation(
            controller: _staggerController!,
            index: index,
            totalCount: kindergartens.length.clamp(1, 10),
          );
          return StaggeredListItem(
            animation: animation,
            child: tile,
          );
        }

        return tile;
      },
    );
  }
}

// --- 필터 칩 버튼 ---

class _FilterButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.gray300,
          ),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTextStyles.chipText.copyWith(
                color: isActive ? AppColors.primary : AppColors.gray700,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            const SizedBox(width: 2),
            Icon(
              Icons.keyboard_arrow_down,
              size: 16,
              color: isActive ? AppColors.primary : AppColors.gray500,
            ),
          ],
        ),
      ),
    );
  }
}

// --- 일반 필터 바텀시트 ---

class _FilterSheet extends StatelessWidget {
  final String title;
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;

  const _FilterSheet({
    required this.title,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.headline6),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: options.map((option) {
              final isSelected = option == selected;
              return GestureDetector(
                onTap: () => onSelected(option),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: isSelected
                      ? BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(20),
                        )
                      : BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.gray300),
                        ),
                  child: Text(
                    option,
                    style: AppTextStyles.body2.copyWith(
                      color: isSelected ? Colors.white : AppColors.gray700,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// --- 지역 필터 바텀시트 ---

class _RegionFilterSheet extends StatefulWidget {
  final List<Region> regions;
  final String? selectedSidoCode;
  final String? selectedSggCode;
  final void Function(String? sidoCode, String? sggCode) onSelected;

  const _RegionFilterSheet({
    required this.regions,
    required this.selectedSidoCode,
    required this.selectedSggCode,
    required this.onSelected,
  });

  @override
  State<_RegionFilterSheet> createState() => _RegionFilterSheetState();
}

class _RegionFilterSheetState extends State<_RegionFilterSheet> {
  String? _sidoCode;
  String? _sggCode;

  @override
  void initState() {
    super.initState();
    _sidoCode = widget.selectedSidoCode;
    _sggCode = widget.selectedSggCode;
  }

  Region? get _selectedRegion {
    final idx = widget.regions.indexWhere((r) => r.sidoCode == _sidoCode);
    return idx == -1 ? null : widget.regions[idx];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24, 20, 24, MediaQuery.of(context).padding.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('지역', style: AppTextStyles.headline6),
          const SizedBox(height: 16),

          // 시/도
          Text('시/도', style: AppTextStyles.caption.copyWith(color: AppColors.gray600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildRegionChip('전체', _sidoCode == null, () {
                setState(() { _sidoCode = null; _sggCode = null; });
              }),
              ...widget.regions.map((region) => _buildRegionChip(
                region.sidoName,
                _sidoCode == region.sidoCode,
                () => setState(() { _sidoCode = region.sidoCode; _sggCode = null; }),
              )),
            ],
          ),

          // 시/군/구
          if (_selectedRegion != null) ...[
            const SizedBox(height: 16),
            Text('시/군/구', style: AppTextStyles.caption.copyWith(color: AppColors.gray600)),
            const SizedBox(height: 8),
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildRegionChip('전체', _sggCode == null, () {
                    setState(() => _sggCode = null);
                  }),
                  const SizedBox(width: 8),
                  ..._selectedRegion!.sggList.map((district) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _buildRegionChip(
                      district.sggName,
                      _sggCode == district.sggCode,
                      () => setState(() => _sggCode = district.sggCode),
                    ),
                  )),
                ],
              ),
            ),
          ],

          const SizedBox(height: 20),

          // 적용 버튼
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => widget.onSelected(_sidoCode, _sggCode),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('적용'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegionChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: isSelected
            ? BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(18),
              )
            : BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.gray300),
              ),
        child: Text(
          label,
          style: AppTextStyles.chipText.copyWith(
            color: isSelected ? Colors.white : AppColors.gray700,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
