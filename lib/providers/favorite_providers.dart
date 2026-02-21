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
    final current = state.valueOrNull ?? [];

    // 임시 객체로 캐시에 먼저 추가 (즉시 UI 반영)
    final tempFavorite = Favorite(
      id: 'temp_$centerId',
      centerId: centerId,
      centerName: '',
      createdAt: DateTime.now(),
    );
    state = AsyncData([tempFavorite, ...current]);

    try {
      final deviceId = await ref.read(deviceIdProvider.future);
      final repository = ref.read(favoriteRepositoryProvider);
      final favorite = await repository.addFavorite(
        deviceId: deviceId,
        centerId: centerId,
      );
      // API 응답으로 임시 객체 교체
      final updated = state.valueOrNull ?? [];
      state = AsyncData(
        updated.map((f) => f.centerId == centerId ? favorite : f).toList(),
      );
      return true;
    } catch (e) {
      debugPrint('즐겨찾기 추가 실패: $e');
      // 실패 시 롤백
      state = AsyncData(current);
      return false;
    }
  }

  /// 즐겨찾기 제거 (낙관적 업데이트)
  Future<bool> remove(String centerId) async {
    final current = state.valueOrNull ?? [];
    final index = current.indexWhere((f) => f.centerId == centerId);
    if (index == -1) return false;
    final target = current[index];

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
