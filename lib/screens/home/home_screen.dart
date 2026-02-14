import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../models/kindergarten_search.dart';
import '../../providers/kindergarten_providers.dart';
import '../../providers/location_providers.dart';
import '../../providers/favorite_providers.dart';
import '../../core/utils/establish_type_helper.dart';
import '../../widgets/kindergarten_list_tile.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    try {
      final permission = await ref.read(locationPermissionStatusProvider.future);
      
      if (permission == LocationPermission.denied) {
        await ref.read(requestLocationPermissionProvider(null).future);
      }
      
      final position = await ref.read(currentPositionProvider.future);
      if (position != null) {
        // 검색 필터에 위치 설정
        final currentFilter = ref.read(searchFilterProvider);
        final newFilter = currentFilter.copyWith(
          lat: position.latitude,
          lng: position.longitude,
        );
        ref.read(searchFilterProvider.notifier).state = newFilter;
      }
    } catch (e) {
      debugPrint('위치 초기화 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('유치원 찾기'),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(kindergartenSearchProvider);
          ref.invalidate(favoritesProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // 검색바 (ReadOnly)
              _buildSearchBar(context),

              // 내 주변 유치원 섹션
              _buildNearbySection(context, ref),

              // 설립유형 필터 칩 섹션
              _buildEstablishTypeSection(context, ref),

              // 즐겨찾기 섹션
              _buildFavoritesSection(context, ref),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: InkWell(
        onTap: () => context.go('/search'),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.gray100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.gray300),
          ),
          child: Row(
            children: [
              Icon(
                Icons.search,
                color: AppColors.gray500,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '유치원 이름이나 주소를 검색하세요',
                  style: AppTextStyles.body1.copyWith(
                    color: AppColors.gray500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNearbySection(BuildContext context, WidgetRef ref) {
    final kindergartensAsync = ref.watch(kindergartenSearchProvider);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '내 주변 유치원',
                style: AppTextStyles.sectionTitle,
              ),
              TextButton(
                onPressed: () => context.go('/search'),
                child: const Text('더보기'),
              ),
            ],
          ),
          
          const SizedBox(height: 8),

          kindergartensAsync.when(
            data: (kindergartens) {
              if (kindergartens.isEmpty) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(
                          Icons.location_off,
                          size: 48,
                          color: AppColors.gray400,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '주변 유치원을 찾을 수 없습니다',
                          style: AppTextStyles.body2.copyWith(
                            color: AppColors.gray600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => context.go('/search'),
                          child: const Text('직접 검색하기'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // 최대 3개만 표시
              final displayItems = kindergartens.take(3).toList();
              
              return Column(
                children: displayItems.map((kindergarten) {
                  return _NearbyKindergartenItem(
                    kindergarten: kindergarten,
                  );
                }).toList(),
              );
            },
            loading: () => const SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stackTrace) => Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: AppColors.error,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '주변 유치원 정보를 불러올 수 없습니다',
                      style: AppTextStyles.body2,
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        ref.invalidate(kindergartenSearchProvider);
                      },
                      child: const Text('다시 시도'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstablishTypeSection(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '설립유형별 찾기',
            style: AppTextStyles.sectionTitle,
          ),
          const SizedBox(height: 12),
          
          Row(
            children: AppConstants.establishTypes.map(
              (type) => Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: _EstablishTypeCard(
                    establishType: type,
                    onTap: () {
                      // 해당 유형으로 검색 화면 이동
                      final currentFilter = ref.read(searchFilterProvider);
                      final newFilter = currentFilter.copyWith(type: type);
                      ref.read(searchFilterProvider.notifier).state = newFilter;
                      context.go('/search');
                    },
                  ),
                ),
              ),
            ).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesSection(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(favoritesProvider);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '즐겨찾기',
                style: AppTextStyles.sectionTitle,
              ),
              TextButton(
                onPressed: () => context.go('/favorites'),
                child: const Text('더보기'),
              ),
            ],
          ),

          const SizedBox(height: 8),

          favoritesAsync.when(
            data: (favorites) {
              if (favorites.isEmpty) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(
                          Icons.favorite_border,
                          size: 48,
                          color: AppColors.gray400,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '즐겨찾기한 유치원이 없어요',
                          style: AppTextStyles.body2.copyWith(
                            color: AppColors.gray600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => context.go('/search'),
                          child: const Text('유치원 검색하기'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // 최대 3개만 표시
              final displayItems = favorites.take(3).toList();

              return Column(
                children: displayItems.map(
                  (favorite) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: const Icon(
                        Icons.favorite,
                        color: AppColors.favoriteActive,
                      ),
                      title: Text(
                        favorite.centerName,
                        style: AppTextStyles.kindergartenName,
                      ),
                      subtitle: Text(
                        '${_formatDate(favorite.createdAt)} 추가',
                        style: AppTextStyles.caption,
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push('/detail/${favorite.centerId}'),
                    ),
                  ),
                ).toList(),
              );
            },
            loading: () => const SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stackTrace) => Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: AppColors.error,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '즐겨찾기 정보를 불러올 수 없습니다',
                      style: AppTextStyles.body2,
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        ref.invalidate(favoritesProvider);
                      },
                      child: const Text('다시 시도'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }
}

class _EstablishTypeCard extends StatelessWidget {
  final String establishType;
  final VoidCallback onTap;

  const _EstablishTypeCard({
    required this.establishType,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = EstablishTypeHelper.getColor(establishType);
    final icon = EstablishTypeHelper.getIcon(establishType);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: 0.1),
                color.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                establishType,
                style: AppTextStyles.body1.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}

class _NearbyKindergartenItem extends ConsumerWidget {
  final KindergartenSearch kindergarten;

  const _NearbyKindergartenItem({required this.kindergarten});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavoriteAsync = ref.watch(isFavoriteProvider(kindergarten.id));
    final isFavorite = isFavoriteAsync.valueOrNull ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: KindergartenListTile(
        kindergarten: kindergarten,
        onTap: () => context.push('/detail/${kindergarten.id}'),
        onFavoriteToggle: () => toggleFavorite(ref, kindergarten.id),
        isFavorite: isFavorite,
      ),
    );
  }
}