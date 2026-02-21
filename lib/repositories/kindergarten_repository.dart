import 'package:dio/dio.dart';
import '../core/network/dio_client.dart';
import '../core/constants/api_constants.dart';
import '../models/page_response.dart';
import '../models/kindergarten_search.dart';
import '../models/kindergarten_detail.dart';
import '../models/map_marker.dart';
import '../models/compare_item.dart';
import '../models/center_review.dart';

class KindergartenRepository {
  final Dio _dio = DioClient.instance.dio;

  /// 유치원 검색
  Future<PageResponse<KindergartenSearch>> searchKindergartens({
    double? lat,
    double? lng,
    double? radiusKm,
    String? type,
    String? q,
    String? sidoCode,
    String? sggCode,
    String? sort,
    int page = 0,
    int size = 20,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'page': page,
        'size': size,
      };

      if (lat != null) queryParameters['lat'] = lat;
      if (lng != null) queryParameters['lng'] = lng;
      if (radiusKm != null) queryParameters['radiusKm'] = radiusKm;
      if (type != null && type.isNotEmpty) queryParameters['type'] = type;
      if (q != null && q.isNotEmpty) queryParameters['q'] = q;
      if (sidoCode != null && sidoCode.isNotEmpty) queryParameters['sidoCode'] = sidoCode;
      if (sggCode != null && sggCode.isNotEmpty) queryParameters['sggCode'] = sggCode;
      if (sort != null && sort.isNotEmpty) queryParameters['sort'] = sort;

      final response = await _dio.get(
        ApiConstants.kindergartensSearch,
        queryParameters: queryParameters,
      );

      return PageResponse.fromJson(
        response.data,
        (json) => KindergartenSearch.fromJson(json),
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// 유치원 상세 정보
  Future<KindergartenDetail> getKindergartenDetail(String id) async {
    try {
      final response = await _dio.get('${ApiConstants.kindergartensDetail}/$id');
      return KindergartenDetail.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// 지도 마커 목록
  Future<List<MapMarker>> getMapMarkers({
    required double lat,
    required double lng,
    double? radiusKm,
    String? type,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'lat': lat,
        'lng': lng,
      };

      if (radiusKm != null) queryParameters['radiusKm'] = radiusKm;
      if (type != null && type.isNotEmpty) queryParameters['type'] = type;

      final response = await _dio.get(
        ApiConstants.kindergartensMapMarkers,
        queryParameters: queryParameters,
      );

      return (response.data as List<dynamic>)
          .map((json) => MapMarker.fromJson(json))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// 유치원 비교
  Future<CompareResponse> compareKindergartens({
    required List<String> ids,
    double? lat,
    double? lng,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'ids': ids.join(','),
      };

      if (lat != null) queryParameters['lat'] = lat;
      if (lng != null) queryParameters['lng'] = lng;

      final response = await _dio.get(
        ApiConstants.kindergartensCompare,
        queryParameters: queryParameters,
      );

      return CompareResponse.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// 유치원 리뷰 목록
  Future<PageResponse<CenterReview>> getReviews(
    String id, {
    int page = 0,
    int size = 20,
  }) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.kindergartensDetail}/$id/reviews',
        queryParameters: {'page': page, 'size': size},
      );
      return PageResponse.fromJson(
        response.data,
        (json) => CenterReview.fromJson(json),
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(dynamic error) {
    if (error is DioException && error.error != null) {
      return error.error as Exception;
    }
    return Exception(error.toString());
  }
}