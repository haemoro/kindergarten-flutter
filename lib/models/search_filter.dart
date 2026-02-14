class SearchFilter {
  final String? q;           // 검색어
  final double? lat;         // 위도
  final double? lng;         // 경도
  final double radiusKm;     // 반경 (기본 2)
  final String? type;        // 설립유형
  final String? sidoCode;    // 시도 코드
  final String? sggCode;     // 시군구 코드
  final String sort;         // 정렬 (distance/name)

  const SearchFilter({
    this.q,
    this.lat,
    this.lng,
    this.radiusKm = 2.0,
    this.type,
    this.sidoCode,
    this.sggCode,
    this.sort = 'distance',
  });

  SearchFilter copyWith({
    String? q,
    double? lat,
    double? lng,
    double? radiusKm,
    String? type,
    String? sidoCode,
    String? sggCode,
    String? sort,
  }) {
    return SearchFilter(
      q: q ?? this.q,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      radiusKm: radiusKm ?? this.radiusKm,
      type: type ?? this.type,
      sidoCode: sidoCode ?? this.sidoCode,
      sggCode: sggCode ?? this.sggCode,
      sort: sort ?? this.sort,
    );
  }

  // 필터 초기화 (위치 정보는 유지)
  SearchFilter reset() {
    return SearchFilter(
      lat: lat,
      lng: lng,
      radiusKm: 2.0,
      sort: 'distance',
    );
  }

  // 검색 쿼리 파라미터 생성
  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{
      'radiusKm': radiusKm,
      'sort': sort,
    };

    if (q != null && q!.isNotEmpty) params['q'] = q;
    if (lat != null) params['lat'] = lat;
    if (lng != null) params['lng'] = lng;
    if (type != null && type!.isNotEmpty) params['type'] = type;
    if (sidoCode != null && sidoCode!.isNotEmpty) params['sidoCode'] = sidoCode;
    if (sggCode != null && sggCode!.isNotEmpty) params['sggCode'] = sggCode;

    return params;
  }

  bool get hasLocation => lat != null && lng != null;
  bool get hasQuery => q != null && q!.isNotEmpty;
  bool get hasType => type != null && type!.isNotEmpty;
  bool get hasRegion => sidoCode != null && sidoCode!.isNotEmpty;

  @override
  String toString() {
    return 'SearchFilter(q: $q, lat: $lat, lng: $lng, radiusKm: $radiusKm, '
           'type: $type, sidoCode: $sidoCode, sggCode: $sggCode, sort: $sort)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SearchFilter &&
        other.q == q &&
        other.lat == lat &&
        other.lng == lng &&
        other.radiusKm == radiusKm &&
        other.type == type &&
        other.sidoCode == sidoCode &&
        other.sggCode == sggCode &&
        other.sort == sort;
  }

  @override
  int get hashCode {
    return Object.hash(q, lat, lng, radiusKm, type, sidoCode, sggCode, sort);
  }
}