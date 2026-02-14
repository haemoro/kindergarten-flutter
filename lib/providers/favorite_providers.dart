import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/favorite_repository.dart';
import '../providers/device_id_provider.dart';
import '../models/favorite.dart';

// Favorite Repository Provider
final favoriteRepositoryProvider = Provider<FavoriteRepository>((ref) {
  return FavoriteRepository();
});

// 즐겨찾기 목록 Provider
final favoritesProvider = FutureProvider<List<Favorite>>((ref) async {
  final deviceId = await ref.watch(deviceIdProvider.future);
  final repository = ref.read(favoriteRepositoryProvider);
  
  try {
    final result = await repository.getFavorites(deviceId: deviceId);
    return result.content;
  } catch (e) {
    debugPrint('즐겨찾기 목록 로드 실패: $e');
    return [];
  }
});

// 특정 유치원의 즐겨찾기 여부 Provider
final isFavoriteProvider = FutureProvider.family<bool, String>((ref, centerId) async {
  final favorites = await ref.watch(favoritesProvider.future);
  return favorites.any((favorite) => favorite.centerId == centerId);
});

// 즐겨찾기 액션 Provider
final favoriteActionProvider = Provider((ref) {
  return FavoriteActions(ref);
});

class FavoriteActions {
  final Ref ref;
  
  FavoriteActions(this.ref);

  /// 즐겨찾기 추가
  Future<bool> addFavorite(String centerId) async {
    try {
      final deviceId = await ref.read(deviceIdProvider.future);
      final repository = ref.read(favoriteRepositoryProvider);
      
      await repository.addFavorite(
        deviceId: deviceId,
        centerId: centerId,
      );
      
      // 즐겨찾기 목록 새로고침
      ref.invalidate(favoritesProvider);
      ref.invalidate(isFavoriteProvider(centerId));
      
      return true;
    } catch (e) {
      debugPrint('즐겨찾기 추가 실패: $e');
      return false;
    }
  }

  /// 즐겨찾기 제거
  Future<bool> removeFavorite(String centerId) async {
    try {
      final deviceId = await ref.read(deviceIdProvider.future);
      final repository = ref.read(favoriteRepositoryProvider);
      
      // 즐겨찾기 ID 찾기
      final favoriteId = await repository.getFavoriteId(
        deviceId: deviceId,
        centerId: centerId,
      );
      
      if (favoriteId != null) {
        await repository.removeFavorite(
          favoriteId: favoriteId,
          deviceId: deviceId,
        );
        
        // 즐겨찾기 목록 새로고침
        ref.invalidate(favoritesProvider);
        ref.invalidate(isFavoriteProvider(centerId));
        
        return true;
      }
      
      return false;
    } catch (e) {
      debugPrint('즐겨찾기 제거 실패: $e');
      return false;
    }
  }

  /// 즐겨찾기 토글 (추가/제거)
  Future<bool> toggleFavorite(String centerId) async {
    try {
      final isFav = await ref.read(isFavoriteProvider(centerId).future);
      
      if (isFav) {
        return await removeFavorite(centerId);
      } else {
        return await addFavorite(centerId);
      }
    } catch (e) {
      debugPrint('즐겨찾기 토글 실패: $e');
      return false;
    }
  }
}

// 즐겨찾기 토글을 위한 간편 함수
Future<void> toggleFavorite(WidgetRef ref, String centerId) async {
  final actions = ref.read(favoriteActionProvider);
  await actions.toggleFavorite(centerId);
}