import 'dart:io' show Platform;

class ApiConstants {
  // Base URL - 플랫폼에 따라 동적 설정
  static String get baseUrl {
    try {
      // 안드로이드 에뮬레이터에서는 10.0.2.2 사용
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:1025';
      }
    } catch (e) {
      // 웹 환경에서는 Platform이 없음
    }
    return 'http://localhost:1025';  // 웹/데스크톱/iOS용
  }
  
  static const String apiPath = '/api/app';
  static String get fullBaseUrl => '$baseUrl$apiPath';

  // Endpoints
  static const String kindergartensSearch = '/kindergartens/search';
  static const String kindergartensDetail = '/kindergartens';
  static const String kindergartensMapMarkers = '/kindergartens/map-markers';
  static const String kindergartensCompare = '/kindergartens/compare';
  static const String favorites = '/favorites';
  static const String regions = '/regions';

  // Headers
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}