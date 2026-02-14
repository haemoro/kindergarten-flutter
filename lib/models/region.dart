class RegionResponse {
  final List<Region> regions;

  const RegionResponse({
    required this.regions,
  });

  factory RegionResponse.fromJson(Map<String, dynamic> json) {
    return RegionResponse(
      regions: (json['regions'] as List<dynamic>?)
          ?.map((item) => Region.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'regions': regions.map((item) => item.toJson()).toList(),
    };
  }
}

class Region {
  final String sidoCode;
  final String sidoName;
  final List<District> sggList;

  const Region({
    required this.sidoCode,
    required this.sidoName,
    required this.sggList,
  });

  factory Region.fromJson(Map<String, dynamic> json) {
    return Region(
      sidoCode: json['sidoCode'] ?? '',
      sidoName: json['sidoName'] ?? '',
      sggList: (json['sggList'] as List<dynamic>?)
          ?.map((item) => District.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sidoCode': sidoCode,
      'sidoName': sidoName,
      'sggList': sggList.map((item) => item.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'Region(sidoCode: $sidoCode, sidoName: $sidoName, districts: ${sggList.length})';
  }
}

class District {
  final String sggCode;
  final String sggName;

  const District({
    required this.sggCode,
    required this.sggName,
  });

  factory District.fromJson(Map<String, dynamic> json) {
    return District(
      sggCode: json['sggCode'] ?? '',
      sggName: json['sggName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sggCode': sggCode,
      'sggName': sggName,
    };
  }

  @override
  String toString() {
    return 'District(sggCode: $sggCode, sggName: $sggName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is District && other.sggCode == sggCode;
  }

  @override
  int get hashCode => sggCode.hashCode;
}