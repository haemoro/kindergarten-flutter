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
  static const List<String> sortOptions = ['distance', 'name'];

  // 지도 기본 줌 레벨
  static const double defaultMapZoom = 15.0;

  // 비교 최대 개수
  static const int maxCompareCount = 4;
  static const int minCompareCount = 2;
}