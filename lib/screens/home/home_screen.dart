import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_decorations.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/kindergarten_providers.dart';
import '../../providers/location_providers.dart';
import '../../providers/favorite_providers.dart';
import '../../core/utils/establish_type_helper.dart';
import '../../core/utils/date_formatter.dart';
import '../../widgets/kindergarten_compact_card.dart';
import '../../widgets/shimmer_loading.dart';

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
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(kindergartenSearchProvider);
          ref.invalidate(favoritesProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // Gradient Hero Header + Search Bar
              _buildHeroHeader(context),

              const SizedBox(height: 24),

              // Nearby section (horizontal scroll) - delay 200ms
              _FadeInSection(
                delay: const Duration(milliseconds: 200),
                child: _buildNearbySection(context, ref),
              ),

              const SizedBox(height: 8),

              // Establish type filter chips - delay 400ms
              _FadeInSection(
                delay: const Duration(milliseconds: 400),
                child: _buildEstablishTypeSection(context, ref),
              ),

              // Favorites section - delay 600ms
              _FadeInSection(
                delay: const Duration(milliseconds: 600),
                child: _buildFavoritesSection(context, ref),
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroHeader(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Gradient background
        Container(
          width: double.infinity,
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top,
            left: 24,
            right: 24,
            bottom: 48,
          ),
          decoration: AppDecorations.headerDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '우리 아이에게 딱 맞는\n유치원을 찾아보세요',
                style: AppTextStyles.headline4.copyWith(
                  color: Colors.white,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        // Search bar overlapping bottom of header
        Positioned(
          left: 16,
          right: 16,
          bottom: -24,
          child: _buildSearchBar(context),
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.go('/search'),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                offset: const Offset(0, 4),
                blurRadius: 12,
              ),
            ],
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

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTextStyles.sectionTitle,
        ),
      ],
    );
  }

  Widget _buildNearbySection(BuildContext context, WidgetRef ref) {
    final kindergartensAsync = ref.watch(kindergartenSearchProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSectionTitle('내 주변 유치원'),
              TextButton(
                onPressed: () => context.go('/search'),
                child: const Text('더보기'),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        kindergartensAsync.when(
          data: (kindergartens) {
            if (kindergartens.isEmpty) {
              return _buildEmptyNearby(context);
            }

            final displayItems = kindergartens.take(5).toList();

            return SizedBox(
              height: 155,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: displayItems.length,
                itemBuilder: (context, index) {
                  final item = displayItems[index];
                  return KindergartenCompactCard(
                    kindergarten: item,
                    onTap: () => context.push('/detail/${item.id}'),
                    isFavorite: ref.watch(isFavoriteProvider(item.id)),
                    onFavoriteToggle: () => toggleFavorite(ref, item.id),
                  );
                },
              ),
            );
          },
          loading: () => SizedBox(
            height: 175,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: const [
                ShimmerCompactCard(),
                ShimmerCompactCard(),
                ShimmerCompactCard(),
              ],
            ),
          ),
          error: (error, stackTrace) => _buildErrorNearby(ref),
        ),
      ],
    );
  }

  Widget _buildEmptyNearby(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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

  Widget _buildErrorNearby(WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
    );
  }

  Widget _buildEstablishTypeSection(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('설립유형별 찾기'),
          const SizedBox(height: 10),
          Row(
            children: AppConstants.establishTypes.map(
              (type) {
                final color = EstablishTypeHelper.getColor(type);
                final icon = EstablishTypeHelper.getIcon(type);
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Material(
                      color: color.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: () {
                          final currentFilter = ref.read(searchFilterProvider);
                          final newFilter = currentFilter.copyWith(type: type);
                          ref.read(searchFilterProvider.notifier).state = newFilter;
                          context.go('/search');
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: color.withValues(alpha: 0.2)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(icon, color: color, size: 18),
                              const SizedBox(width: 6),
                              Text(
                                type,
                                style: AppTextStyles.body2.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
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
              _buildSectionTitle('즐겨찾기'),
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
                        '${formatDate(favorite.createdAt)} 추가',
                        style: AppTextStyles.caption,
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push('/detail/${favorite.centerId}'),
                    ),
                  ),
                ).toList(),
              );
            },
            loading: () => const Column(
              children: [
                ShimmerFavoriteItem(),
                ShimmerFavoriteItem(),
                ShimmerFavoriteItem(),
              ],
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

}


class _FadeInSection extends StatefulWidget {
  final Widget child;
  final Duration delay;

  const _FadeInSection({
    required this.child,
    this.delay = Duration.zero,
  });

  @override
  State<_FadeInSection> createState() => _FadeInSectionState();
}

class _FadeInSectionState extends State<_FadeInSection> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay, () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      opacity: _visible ? 1.0 : 0.0,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
        offset: _visible ? Offset.zero : const Offset(0, 0.05),
        child: widget.child,
      ),
    );
  }
}

