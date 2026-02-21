import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../core/utils/location_service.dart';

// Location Service Provider
final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService.instance;
});

// Location Permission Provider
final locationPermissionProvider = StreamProvider<LocationPermission>((ref) {
  final service = ref.read(locationServiceProvider);
  return Stream.periodic(const Duration(seconds: 1))
      .asyncMap((_) => service.checkPermission());
});

// Current Position Provider
final currentPositionProvider = FutureProvider<Position?>((ref) async {
  final service = ref.read(locationServiceProvider);
  return await service.getCurrentPosition();
});

// Location Permission Status (AsyncValue)
final locationPermissionStatusProvider = FutureProvider<LocationPermission>((ref) async {
  final service = ref.read(locationServiceProvider);
  return await service.checkPermission();
});

// Request Location Permission
final requestLocationPermissionProvider = FutureProvider.family<LocationPermission, void>((ref, _) async {
  final service = ref.read(locationServiceProvider);
  return await service.requestPermission();
});

// Location Service Enabled
final locationServiceEnabledProvider = FutureProvider<bool>((ref) async {
  final service = ref.read(locationServiceProvider);
  return await service.isLocationServiceEnabled();
});

// 지도 포커스 위치 (검색 → 지도 탭 이동 시 사용)
final mapFocusLocationProvider = StateProvider<({double lat, double lng})?>((ref) => null);