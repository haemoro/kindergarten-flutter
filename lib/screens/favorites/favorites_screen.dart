import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_decorations.dart';
import '../../models/favorite.dart';
import '../../providers/favorite_providers.dart';
import '../../providers/kindergarten_providers.dart';
import '../../core/utils/date_formatter.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_state.dart';
import '../../widgets/shimmer_loading.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  final Set<String> _selectedItems = {};

  @override
  Widget build(BuildContext context) {
    final favoritesAsync = ref.watch(favoritesProvider);

    return Scaffold(
      appBar: AppBar(
        title: favoritesAsync.when(
          data: (favorites) => Text('즐겨찾기 (${favorites.length})'),
          loading: () => const Text('즐겨찾기'),
          error: (_, __) => const Text('즐겨찾기'),
        ),
        actions: [
          if (_selectedItems.isNotEmpty)
            TextButton(
              onPressed: _clearSelection,
              child: const Text('선택 해제'),
            ),
        ],
      ),
      body: favoritesAsync.when(
        data: (favorites) {
          if (favorites.isEmpty) {
            return const EmptyState(
              icon: Icons.favorite_border,
              title: '즐겨찾기한 유치원이 없어요',
              subtitle: '검색에서 하트를 눌러 추가해보세요',
            );
          }

          return Column(
            children: [
              // 선택된 아이템 수 표시
              if (_selectedItems.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: AppColors.primary.withValues(alpha: 0.1),
                  child: Text(
                    '${_selectedItems.length}개 선택됨',
                    style: AppTextStyles.body1.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

              // 즐겨찾기 목록
              Expanded(
                child: ListView.builder(
                  itemCount: favorites.length,
                  itemBuilder: (context, index) {
                    final favorite = favorites[index];
                    final isSelected = _selectedItems.contains(favorite.centerId);

                    return Dismissible(
                      key: Key(favorite.id),
                      direction: DismissDirection.endToStart,
                      confirmDismiss: (direction) => _confirmDelete(favorite),
                      background: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 24),
                        child: const Icon(
                          Icons.delete,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      child: GestureDetector(
                        onTap: () => context.push('/detail/${favorite.centerId}'),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.transparent,
                              width: 1.5,
                            ),
                            boxShadow: AppDecorations.cardShadow,
                          ),
                          child: Material(
                            color: isSelected
                                ? AppColors.primary.withValues(alpha: 0.04)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.favorite,
                                    color: AppColors.favoriteActive,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          favorite.centerName,
                                          style: AppTextStyles.kindergartenName,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${formatDate(favorite.createdAt)} 추가',
                                          style: AppTextStyles.caption,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  GestureDetector(
                                    onTap: () => _toggleSelection(
                                      favorite.centerId,
                                      !isSelected,
                                    ),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isSelected
                                            ? AppColors.primary
                                            : Colors.transparent,
                                        border: Border.all(
                                          color: isSelected
                                              ? AppColors.primary
                                              : AppColors.gray400,
                                          width: 2,
                                        ),
                                      ),
                                      child: isSelected
                                          ? const Icon(
                                              Icons.check,
                                              size: 16,
                                              color: Colors.white,
                                            )
                                          : null,
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
                ),
              ),
            ],
          );
        },
        loading: () => ListView(
          physics: const NeverScrollableScrollPhysics(),
          children: const [
            ShimmerFavoriteItem(),
            ShimmerFavoriteItem(),
            ShimmerFavoriteItem(),
            ShimmerFavoriteItem(),
            ShimmerFavoriteItem(),
          ],
        ),
        error: (error, stackTrace) => ErrorState(
          message: error.toString(),
          onRetry: () => ref.invalidate(favoritesProvider),
        ),
      ),
      bottomNavigationBar: _selectedItems.length >= 2 
          ? _buildCompareBottomBar()
          : null,
    );
  }

  Widget _buildCompareBottomBar() {
    final canCompare = _selectedItems.length >= 2 && _selectedItems.length <= 4;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: GestureDetector(
          onTap: canCompare ? _navigateToCompare : null,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: canCompare
                ? AppDecorations.gradientButtonDecoration()
                : BoxDecoration(
                    color: AppColors.gray300,
                    borderRadius: BorderRadius.circular(16),
                  ),
            child: Text(
              '선택한 유치원 비교하기 (${_selectedItems.length}/4)',
              textAlign: TextAlign.center,
              style: AppTextStyles.button.copyWith(
                color: canCompare ? Colors.white : AppColors.gray500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _toggleSelection(String centerId, bool? selected) {
    setState(() {
      if (selected == true) {
        if (_selectedItems.length < 4) {
          _selectedItems.add(centerId);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('최대 4개까지 선택 가능합니다')),
          );
        }
      } else {
        _selectedItems.remove(centerId);
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedItems.clear();
    });
  }

  Future<bool?> _confirmDelete(Favorite favorite) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('즐겨찾기 삭제'),
          content: Text('${favorite.centerName}을(를) 즐겨찾기에서 삭제하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop(true);
                await _deleteFavorite(favorite.centerId);
              },
              child: const Text('삭제'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteFavorite(String centerId) async {
    final success = await ref.read(favoritesProvider.notifier).remove(centerId);

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('즐겨찾기에서 삭제되었습니다')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('삭제에 실패했습니다')),
      );
    }
  }

  void _navigateToCompare() {
    // 비교 화면으로 선택된 ID들 전달
    final selectedList = _selectedItems.toList();
    ref.read(compareIdsProvider.notifier).state = selectedList;
    context.push('/compare');
  }

}