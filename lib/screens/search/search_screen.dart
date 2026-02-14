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
import 'widgets/search_bar.dart';
import 'widgets/filter_chips.dart';
import 'widgets/region_selector.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final ScrollController _scrollController = ScrollController();

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
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(paginatedSearchProvider.notifier).loadNextPage();
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
          // 검색 및 필터 영역
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

          // 검색 결과 목록
          Expanded(
            child: _buildSearchResults(searchState),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(PaginatedSearchState searchState) {
    if (searchState.isInitialLoading) {
      return const Center(child: CircularProgressIndicator());
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

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            '${searchState.totalElements}개 유치원',
            style: AppTextStyles.body2.copyWith(
              color: AppColors.gray600,
              fontWeight: FontWeight.w500,
            ),
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

              return KindergartenListTile(
                kindergarten: kindergarten,
                onTap: () => context.push('/detail/${kindergarten.id}'),
                onFavoriteToggle: () => toggleFavorite(ref, kindergarten.id),
                isFavorite: isFavAsync.value ?? false,
              );
            },
          ),
        ),
      ],
    );
  }
}