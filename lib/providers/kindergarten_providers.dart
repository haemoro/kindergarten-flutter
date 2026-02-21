import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/kindergarten_repository.dart';
import '../models/kindergarten_search.dart';
import '../models/kindergarten_detail.dart';
import '../models/map_marker.dart';
import '../models/compare_item.dart';
import '../models/center_review.dart';
import '../models/page_response.dart';
import '../models/search_filter.dart';
import '../core/constants/app_constants.dart';
import 'location_providers.dart';

// Kindergarten Repository Provider
final kindergartenRepositoryProvider = Provider<KindergartenRepository>((ref) {
  return KindergartenRepository();
});

// Search Filter State Provider
final searchFilterProvider = StateProvider<SearchFilter>((ref) {
  return const SearchFilter();
});

// 간단한 검색 결과 Provider (첫 페이지만)
final kindergartenSearchProvider = FutureProvider<List<KindergartenSearch>>((ref) async {
  final filter = ref.watch(searchFilterProvider);
  final repository = ref.read(kindergartenRepositoryProvider);

  try {
    final result = await repository.searchKindergartens(
      lat: filter.lat,
      lng: filter.lng,
      radiusKm: filter.radiusKm,
      type: filter.hasType ? SearchFilter.mapTypeToApi(filter.type!) : null,
      q: filter.q,
      sidoCode: filter.sidoCode,
      sggCode: filter.sggCode,
      sort: filter.sort,
      page: 0,
      size: AppConstants.defaultPageSize,
    );

    return result.content;
  } catch (error, stackTrace) {
    debugPrint('검색 에러: $error');
    debugPrint('스택 트레이스: $stackTrace');
    rethrow;
  }
});

// 페이지네이션 검색 상태
class PaginatedSearchState {
  final List<KindergartenSearch> items;
  final int currentPage;
  final int totalPages;
  final int totalElements;
  final bool isLoadingMore;
  final bool isInitialLoading;
  final String? error;

  const PaginatedSearchState({
    this.items = const [],
    this.currentPage = 0,
    this.totalPages = 0,
    this.totalElements = 0,
    this.isLoadingMore = false,
    this.isInitialLoading = true,
    this.error,
  });

  bool get hasNextPage => currentPage < totalPages - 1;

  PaginatedSearchState copyWith({
    List<KindergartenSearch>? items,
    int? currentPage,
    int? totalPages,
    int? totalElements,
    bool? isLoadingMore,
    bool? isInitialLoading,
    String? error,
  }) {
    return PaginatedSearchState(
      items: items ?? this.items,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalElements: totalElements ?? this.totalElements,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      error: error,
    );
  }
}

// 페이지네이션 검색 Notifier
class PaginatedSearchNotifier extends StateNotifier<PaginatedSearchState> {
  final KindergartenRepository _repository;
  final Ref _ref;

  PaginatedSearchNotifier(this._repository, this._ref) : super(const PaginatedSearchState()) {
    _ref.listen(searchFilterProvider, (prev, next) {
      loadFirstPage();
    });
    loadFirstPage();
  }

  Future<void> loadFirstPage() async {
    state = state.copyWith(isInitialLoading: true, error: null);
    final filter = _ref.read(searchFilterProvider);

    try {
      final result = await _repository.searchKindergartens(
        lat: filter.lat,
        lng: filter.lng,
        radiusKm: filter.radiusKm,
        type: filter.hasType ? SearchFilter.mapTypeToApi(filter.type!) : null,
        q: filter.q,
        sidoCode: filter.sidoCode,
        sggCode: filter.sggCode,
        sort: filter.sort,
        page: 0,
        size: AppConstants.defaultPageSize,
      );

      state = PaginatedSearchState(
        items: result.content,
        currentPage: result.page,
        totalPages: result.totalPages,
        totalElements: result.totalElements,
        isLoadingMore: false,
        isInitialLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isInitialLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadNextPage() async {
    if (!state.hasNextPage || state.isLoadingMore) return;

    state = state.copyWith(isLoadingMore: true);
    final filter = _ref.read(searchFilterProvider);
    final nextPage = state.currentPage + 1;

    try {
      final result = await _repository.searchKindergartens(
        lat: filter.lat,
        lng: filter.lng,
        radiusKm: filter.radiusKm,
        type: filter.hasType ? SearchFilter.mapTypeToApi(filter.type!) : null,
        q: filter.q,
        sidoCode: filter.sidoCode,
        sggCode: filter.sggCode,
        sort: filter.sort,
        page: nextPage,
        size: AppConstants.defaultPageSize,
      );

      state = state.copyWith(
        items: [...state.items, ...result.content],
        currentPage: result.page,
        totalPages: result.totalPages,
        totalElements: result.totalElements,
        isLoadingMore: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }
}

final paginatedSearchProvider =
    StateNotifierProvider<PaginatedSearchNotifier, PaginatedSearchState>((ref) {
  final repository = ref.read(kindergartenRepositoryProvider);
  return PaginatedSearchNotifier(repository, ref);
});

// 유치원 상세 정보 Provider
final kindergartenDetailProvider = FutureProvider.family<KindergartenDetail, String>((ref, id) async {
  final repository = ref.read(kindergartenRepositoryProvider);
  return await repository.getKindergartenDetail(id);
});

// 지도 마커 Provider
final mapMarkersProvider = FutureProvider.family<List<MapMarker>, ({double lat, double lng, double? radiusKm, String? type, int? limit})>((ref, params) async {
  final repository = ref.read(kindergartenRepositoryProvider);
  return await repository.getMapMarkers(
    lat: params.lat,
    lng: params.lng,
    radiusKm: params.radiusKm,
    type: params.type,
    limit: params.limit,
  );
});

// 비교 결과 Provider
final compareResultProvider = FutureProvider.family<CompareResponse, ({List<String> ids, double? lat, double? lng})>((ref, params) async {
  if (params.ids.length < AppConstants.minCompareCount) {
    throw Exception('비교할 유치원을 ${AppConstants.minCompareCount}개 이상 선택해주세요.');
  }
  if (params.ids.length > AppConstants.maxCompareCount) {
    throw Exception('비교할 유치원은 최대 ${AppConstants.maxCompareCount}개까지 선택 가능합니다.');
  }

  final repository = ref.read(kindergartenRepositoryProvider);
  return await repository.compareKindergartens(
    ids: params.ids,
    lat: params.lat,
    lng: params.lng,
  );
});

// 비교할 유치원 ID 목록 Provider
final compareIdsProvider = StateProvider<List<String>>((ref) => []);

// 유치원 리뷰 Provider
final kindergartenReviewsProvider = FutureProvider.family<PageResponse<CenterReview>, String>((ref, id) async {
  final repository = ref.read(kindergartenRepositoryProvider);
  return await repository.getReviews(id);
});

// 홈 화면 주변 유치원 Provider (현위치 기반, 최대 10개)
final nearbyKindergartensProvider = FutureProvider<List<KindergartenSearch>>((ref) async {
  final position = await ref.watch(currentPositionProvider.future);
  if (position == null) return [];

  final repository = ref.read(kindergartenRepositoryProvider);
  final result = await repository.searchKindergartens(
    lat: position.latitude,
    lng: position.longitude,
    radiusKm: 2.0,
    sort: 'distance',
    page: 0,
    size: 10,
  );
  return result.content;
});