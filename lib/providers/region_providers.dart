import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/region_repository.dart';
import '../models/region.dart';

// Region Repository Provider
final regionRepositoryProvider = Provider<RegionRepository>((ref) {
  return RegionRepository();
});

// Regions Provider (전체 지역 목록 - 캐시됨)
final regionsProvider = FutureProvider<RegionResponse>((ref) async {
  final repository = ref.read(regionRepositoryProvider);
  return await repository.getRegions();
});

// 시도 목록만 가져오기
final sidoListProvider = FutureProvider<List<Region>>((ref) async {
  final regionsAsync = await ref.watch(regionsProvider.future);
  return regionsAsync.regions;
});

// 특정 시도의 시군구 목록 Provider
final districtListProvider = FutureProvider.family<List<District>, String>((ref, sidoCode) async {
  final repository = ref.read(regionRepositoryProvider);
  return await repository.getDistricts(sidoCode);
});

// 시도 이름 Provider
final sidoNameProvider = FutureProvider.family<String?, String>((ref, sidoCode) async {
  final repository = ref.read(regionRepositoryProvider);
  return await repository.getSidoName(sidoCode);
});

// 시군구 이름 Provider  
final districtNameProvider = FutureProvider.family<String?, ({String sidoCode, String sggCode})>((ref, params) async {
  final repository = ref.read(regionRepositoryProvider);
  return await repository.getDistrictName(params.sidoCode, params.sggCode);
});