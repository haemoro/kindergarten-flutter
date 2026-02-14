import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  static LocationService? _instance;
  static LocationService get instance => _instance ??= LocationService._();

  LocationService._();

  /// 위치 권한 상태 확인
  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  /// 위치 권한 요청
  Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  /// 위치 서비스 활성화 여부 확인
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// 현재 위치 가져오기
  Future<Position?> getCurrentPosition() async {
    try {
      // 위치 서비스 활성화 여부 확인
      final isEnabled = await isLocationServiceEnabled();
      if (!isEnabled) {
        throw LocationServiceDisabledException();
      }

      // 권한 확인
      LocationPermission permission = await checkPermission();
      
      if (permission == LocationPermission.denied) {
        permission = await requestPermission();
        if (permission == LocationPermission.denied) {
          throw LocationPermissionDeniedException('Location permission denied');
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        throw LocationPermissionDeniedException(
          'Location permissions are permanently denied, we cannot request permissions.'
        );
      }

      // 현재 위치 가져오기
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (e) {
      debugPrint('Failed to get current location: $e');
      return null;
    }
  }

  /// 두 좌표 간의 거리 계산 (km)
  double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    ) / 1000; // 미터를 킬로미터로 변환
  }

  /// 주소로부터 좌표 가져오기 (Geocoding)
  Future<List<Location>> getLocationFromAddress(String address) async {
    try {
      return await locationFromAddress(address);
    } catch (e) {
      debugPrint('Failed to get location from address: $e');
      return [];
    }
  }

  /// 좌표로부터 주소 가져오기 (Reverse Geocoding)
  Future<List<Placemark>> getAddressFromLocation(
    double latitude, 
    double longitude
  ) async {
    try {
      return await placemarkFromCoordinates(latitude, longitude);
    } catch (e) {
      debugPrint('Failed to get address from location: $e');
      return [];
    }
  }
}

class LocationServiceDisabledException implements Exception {
  final String message;
  LocationServiceDisabledException([this.message = 'Location service is disabled']);
  
  @override
  String toString() => message;
}

class LocationPermissionDeniedException implements Exception {
  final String message;
  LocationPermissionDeniedException(this.message);
  
  @override
  String toString() => message;
}