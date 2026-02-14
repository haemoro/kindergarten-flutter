import 'package:dio/dio.dart';
import '../core/network/dio_client.dart';
import '../core/constants/api_constants.dart';
import '../models/page_response.dart';
import '../models/favorite.dart';

class FavoriteRepository {
  final Dio _dio = DioClient.instance.dio;

  /// 즐겨찾기 목록 조회
  Future<PageResponse<Favorite>> getFavorites({
    required String deviceId,
    int page = 0,
    int size = 20,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.favorites,
        queryParameters: {
          'deviceId': deviceId,
          'page': page,
          'size': size,
        },
      );

      return PageResponse.fromJson(
        response.data,
        (json) => Favorite.fromJson(json),
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// 즐겨찾기 추가
  Future<Favorite> addFavorite({
    required String deviceId,
    required String centerId,
  }) async {
    try {
      final requestData = FavoriteRequest(
        deviceId: deviceId,
        centerId: centerId,
      );

      final response = await _dio.post(
        ApiConstants.favorites,
        data: requestData.toJson(),
      );

      return Favorite.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// 즐겨찾기 삭제
  Future<void> removeFavorite({
    required String favoriteId,
    required String deviceId,
  }) async {
    try {
      await _dio.delete(
        '${ApiConstants.favorites}/$favoriteId',
        queryParameters: {
          'deviceId': deviceId,
        },
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// 특정 유치원의 즐겨찾기 여부 확인 (로컬 목록에서 확인)
  Future<bool> isFavorite({
    required String deviceId,
    required String centerId,
  }) async {
    try {
      final favorites = await getFavorites(deviceId: deviceId, size: 1000);
      return favorites.content.any((favorite) => favorite.centerId == centerId);
    } catch (e) {
      // 에러 시 false 반환
      return false;
    }
  }

  /// 특정 유치원의 즐겨찾기 ID 찾기 (삭제용)
  Future<String?> getFavoriteId({
    required String deviceId,
    required String centerId,
  }) async {
    try {
      final favorites = await getFavorites(deviceId: deviceId, size: 1000);
      final favorite = favorites.content
          .cast<Favorite?>()
          .firstWhere(
            (favorite) => favorite?.centerId == centerId,
            orElse: () => null,
          );
      return favorite?.id;
    } catch (e) {
      return null;
    }
  }

  Exception _handleError(dynamic error) {
    if (error is DioException && error.error != null) {
      return error.error as Exception;
    }
    return Exception(error.toString());
  }
}