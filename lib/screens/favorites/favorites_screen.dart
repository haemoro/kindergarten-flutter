import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_decorations.dart';
import '../../providers/favorite_providers.dart';
import '../../providers/kindergarten_providers.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_state.dart';

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
                        color: AppColors.error,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 16),
                        child: const Icon(
                          Icons.delete,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      child: InkWell(
                        onTap: () => context.push('/detail/${favorite.centerId}'),
                        child: CheckboxListTile(
                          value: isSelected,
                          onChanged: (selected) => _toggleSelection(favorite.centerId, selected),
                          title: Text(
                            favorite.centerName,
                            style: AppTextStyles.kindergartenName,
                          ),
                          subtitle: Text(
                            '즐겨찾기 추가: ${_formatDate(favorite.createdAt)}',
                            style: AppTextStyles.caption,
                          ),
                          secondary: const Icon(Icons.favorite, color: AppColors.favoriteActive),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
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

  Future<bool?> _confirmDelete(favorite) async {
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
    final actions = ref.read(favoriteActionProvider);
    final success = await actions.removeFavorite(centerId);

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

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }
}