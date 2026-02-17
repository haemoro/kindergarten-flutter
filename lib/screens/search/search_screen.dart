import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/kindergarten_providers.dart';
import '../../providers/favorite_providers.dart';
import '../../providers/location_providers.dart';
import '../../widgets/kindergarten_list_tile.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_state.dart';
import '../../widgets/staggered_animation.dart';
import 'widgets/search_bar.dart';
import 'widgets/filter_chips.dart';
import 'widgets/region_selector.dart';
import '../../widgets/shimmer_loading.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  AnimationController? _staggerController;
  int _previousItemCount = 0;

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
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
        requestLocationPermissionProvider(null).future
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

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(paginatedSearchProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('유치원 검색'),
        actions: [
          TextButton(
            onPressed: () {
              final currentFilter = ref.read(searchFilterProvider);
              final resetFilter = currentFilter.reset();
              ref.read(searchFilterProvider.notifier).state = resetFilter;
            },
            child: const Text('필터 초기화'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and filter area
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.background,
            child: Column(
              children: [
                const CustomSearchBar(),
                const SizedBox(height: 16),
                const RegionSelector(),
                const SizedBox(height: 16),
                const FilterChips(),
                const Divider(),
              ],
            ),
          ),

          // Search results
          Expanded(
            child: _buildSearchResults(searchState),
          ),
        ],
      ),
    );
  }

  static const _sortLabels = {
    'distance': '거리순',
    'capacity': '정원순',
    'name': '이름순',
  };

  Widget _buildSortDropdown() {
    final filter = ref.watch(searchFilterProvider);
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: filter.sort,
        isDense: true,
        style: AppTextStyles.body2.copyWith(
          color: AppColors.gray700,
        ),
        icon: const Icon(Icons.arrow_drop_down, size: 20),
        items: _sortLabels.entries
            .map((e) => DropdownMenuItem(
                  value: e.key,
                  child: Text(e.value),
                ))
            .toList(),
        onChanged: (sort) {
          if (sort != null) {
            ref.read(searchFilterProvider.notifier).state =
                filter.copyWith(sort: sort);
          }
        },
      ),
    );
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
          final currentFilter = ref.read(searchFilterProvider);
          final resetFilter = currentFilter.reset();
          ref.read(searchFilterProvider.notifier).state = resetFilter;
        },
      );
    }

    final kindergartens = searchState.items;
    _triggerStaggerAnimation(kindergartens.length);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Text(
                '${searchState.totalElements}개 유치원',
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.gray600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              _buildSortDropdown(),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            itemCount: kindergartens.length + (searchState.hasNextPage ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= kindergartens.length) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final kindergarten = kindergartens[index];
              final isFavAsync = ref.watch(isFavoriteProvider(kindergarten.id));

              final tile = KindergartenListTile(
                kindergarten: kindergarten,
                onTap: () => context.push('/detail/${kindergarten.id}'),
                onFavoriteToggle: () => toggleFavorite(ref, kindergarten.id),
                isFavorite: isFavAsync.value ?? false,
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
          ),
        ),
      ],
    );
  }
}
