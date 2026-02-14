class CompareResponse {
  final List<CompareItem> centers;

  const CompareResponse({
    required this.centers,
  });

  factory CompareResponse.fromJson(Map<String, dynamic> json) {
    return CompareResponse(
      centers: (json['centers'] as List<dynamic>?)
          ?.map((item) => CompareItem.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'centers': centers.map((item) => item.toJson()).toList(),
    };
  }
}

class CompareItem {
  final String id;
  final String name;
  final String establishType;
  final String address;
  final double? distanceKm;
  final int capacity;
  final int currentEnrollment;
  final int teacherCount;
  final int classCount;
  final bool mealProvided;
  final bool busAvailable;
  final bool extendedCare;
  final double buildingArea;
  final double classroomArea;
  final bool cctvInstalled;
  final int cctvTotal;

  const CompareItem({
    required this.id,
    required this.name,
    required this.establishType,
    required this.address,
    this.distanceKm,
    required this.capacity,
    required this.currentEnrollment,
    required this.teacherCount,
    required this.classCount,
    required this.mealProvided,
    required this.busAvailable,
    required this.extendedCare,
    required this.buildingArea,
    required this.classroomArea,
    required this.cctvInstalled,
    required this.cctvTotal,
  });

  factory CompareItem.fromJson(Map<String, dynamic> json) {
    return CompareItem(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      establishType: json['establishType'] ?? '',
      address: json['address'] ?? '',
      distanceKm: json['distanceKm']?.toDouble(),
      capacity: json['capacity'] ?? 0,
      currentEnrollment: json['currentEnrollment'] ?? 0,
      teacherCount: json['teacherCount'] ?? 0,
      classCount: json['classCount'] ?? 0,
      mealProvided: json['mealProvided'] ?? false,
      busAvailable: json['busAvailable'] ?? false,
      extendedCare: json['extendedCare'] ?? false,
      buildingArea: (json['buildingArea'] ?? 0.0).toDouble(),
      classroomArea: (json['classroomArea'] ?? 0.0).toDouble(),
      cctvInstalled: json['cctvInstalled'] ?? false,
      cctvTotal: json['cctvTotal'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'establishType': establishType,
      'address': address,
      'distanceKm': distanceKm,
      'capacity': capacity,
      'currentEnrollment': currentEnrollment,
      'teacherCount': teacherCount,
      'classCount': classCount,
      'mealProvided': mealProvided,
      'busAvailable': busAvailable,
      'extendedCare': extendedCare,
      'buildingArea': buildingArea,
      'classroomArea': classroomArea,
      'cctvInstalled': cctvInstalled,
      'cctvTotal': cctvTotal,
    };
  }

  double get occupancyRate {
    if (capacity == 0) return 0.0;
    return currentEnrollment / capacity;
  }

  String get formattedDistance {
    if (distanceKm == null) return '-';
    if (distanceKm! < 1) {
      return '${(distanceKm! * 1000).toInt()}m';
    }
    return '${distanceKm!.toStringAsFixed(1)}km';
  }

  String get cctvDisplayText {
    return cctvInstalled ? 'Y($cctvTotal대)' : 'N';
  }

  @override
  String toString() {
    return 'CompareItem(id: $id, name: $name, establishType: $establishType)';
  }
}