class AppConstants {
  // 검색 기본값
  static const double defaultRadius = 2.0; // km
  static const int defaultPageSize = 20;
  static const String defaultSort = 'distance';

  // 디바운스 시간
  static const Duration searchDebounceTime = Duration(milliseconds: 300);
  static const Duration mapCameraDebounceTime = Duration(milliseconds: 500);

  // 반경 옵션
  static const List<double> radiusOptions = [1.0, 2.0, 5.0, 10.0];

  // 설립 유형
  static const List<String> establishTypes = ['국공립', '사립', '법인'];

  // 정렬 옵션
  static const Map<String, String> sortLabels = {
    'distance': '거리순',
    'name': '이름순',
    'enrollment': '원아수순',
    'occupancyRate': '재원률순',
    'capacity': '정원순',
  };

  // 지도 기본 줌 레벨 (카카오맵: 1=가까움 ~ 14=멀리)
  static const int defaultMapLevel = 3;

  // 지도 반경 (km)
  static const double mapRadius = 5.0;

  // 지도 카메라 이동 감지 임계값 (~200m)
  static const double mapMoveThreshold = 0.002;

  // 비교 최대 개수
  static const int maxCompareCount = 4;
  static const int minCompareCount = 2;
}