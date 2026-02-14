import 'package:dio/dio.dart';
import '../core/network/dio_client.dart';
import '../core/constants/api_constants.dart';
import '../models/region.dart';

class RegionRepository {
  final Dio _dio = DioClient.instance.dio;

  /// 지역 목록 조회 (시도/시군구)
  Future<RegionResponse> getRegions() async {
    try {
      final response = await _dio.get(ApiConstants.regions);
      return RegionResponse.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// 특정 시도의 시군구 목록 조회
  Future<List<District>> getDistricts(String sidoCode) async {
    try {
      final regionResponse = await getRegions();
      final region = regionResponse.regions
          .cast<Region?>()
          .firstWhere(
            (region) => region?.sidoCode == sidoCode,
            orElse: () => null,
          );
      return region?.sggList ?? [];
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// 시도 코드로 시도 이름 찾기
  Future<String?> getSidoName(String sidoCode) async {
    try {
      final regionResponse = await getRegions();
      final region = regionResponse.regions
          .cast<Region?>()
          .firstWhere(
            (region) => region?.sidoCode == sidoCode,
            orElse: () => null,
          );
      return region?.sidoName;
    } catch (e) {
      return null;
    }
  }

  /// 시군구 코드로 시군구 이름 찾기
  Future<String?> getDistrictName(String sidoCode, String sggCode) async {
    try {
      final districts = await getDistricts(sidoCode);
      final district = districts
          .cast<District?>()
          .firstWhere(
            (district) => district?.sggCode == sggCode,
            orElse: () => null,
          );
      return district?.sggName;
    } catch (e) {
      return null;
    }
  }

  /// 시도 목록만 가져오기
  Future<List<Region>> getSidoList() async {
    try {
      final regionResponse = await getRegions();
      return regionResponse.regions;
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