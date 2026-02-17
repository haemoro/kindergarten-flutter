import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/favorite_repository.dart';
import '../providers/device_id_provider.dart';
import '../models/favorite.dart';

// Favorite Repository Provider
final favoriteRepositoryProvider = Provider<FavoriteRepository>((ref) {
  return FavoriteRepository();
});

// 즐겨찾기 목록 + 캐시 관리 Notifier
final favoritesProvider =
    AsyncNotifierProvider<FavoritesNotifier, List<Favorite>>(
  FavoritesNotifier.new,
);

class FavoritesNotifier extends AsyncNotifier<List<Favorite>> {
  @override
  Future<List<Favorite>> build() async {
    final deviceId = await ref.watch(deviceIdProvider.future);
    final repository = ref.read(favoriteRepositoryProvider);
    try {
      final result = await repository.getFavorites(
        deviceId: deviceId,
        size: 1000,
      );
      return result.content;
    } catch (e) {
      debugPrint('즐겨찾기 목록 로드 실패: $e');
      return [];
    }
  }

  /// 즐겨찾기 추가 (낙관적 업데이트)
  Future<bool> add(String centerId) async {
    try {
      final deviceId = await ref.read(deviceIdProvider.future);
      final repository = ref.read(favoriteRepositoryProvider);
      final favorite = await repository.addFavorite(
        deviceId: deviceId,
        centerId: centerId,
      );
      // 로컬 캐시에 바로 추가
      final current = state.valueOrNull ?? [];
      state = AsyncData([favorite, ...current]);
      return true;
    } catch (e) {
      debugPrint('즐겨찾기 추가 실패: $e');
      return false;
    }
  }

  /// 즐겨찾기 제거 (낙관적 업데이트)
  Future<bool> remove(String centerId) async {
    final current = state.valueOrNull ?? [];
    final target = current.cast<Favorite?>().firstWhere(
          (f) => f?.centerId == centerId,
          orElse: () => null,
        );
    if (target == null) return false;

    // 로컬 캐시에서 먼저 제거 (빠른 UI 반영)
    state = AsyncData(current.where((f) => f.centerId != centerId).toList());

    try {
      final deviceId = await ref.read(deviceIdProvider.future);
      final repository = ref.read(favoriteRepositoryProvider);
      await repository.removeFavorite(
        favoriteId: target.id,
        deviceId: deviceId,
      );
      return true;
    } catch (e) {
      debugPrint('즐겨찾기 제거 실패: $e');
      // 실패 시 롤백
      state = AsyncData(current);
      return false;
    }
  }

  /// 즐겨찾기 토글
  Future<bool> toggle(String centerId) async {
    final current = state.valueOrNull ?? [];
    final isFav = current.any((f) => f.centerId == centerId);
    return isFav ? remove(centerId) : add(centerId);
  }
}

// 특정 유치원의 즐겨찾기 여부 (동기적으로 캐시에서 확인)
final isFavoriteProvider = Provider.family<bool, String>((ref, centerId) {
  final favorites = ref.watch(favoritesProvider).valueOrNull ?? [];
  return favorites.any((f) => f.centerId == centerId);
});

// 즐겨찾기 토글을 위한 간편 함수
Future<void> toggleFavorite(WidgetRef ref, String centerId) async {
  await ref.read(favoritesProvider.notifier).toggle(centerId);
}
