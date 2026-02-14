class KindergartenSearch {
  final String id;
  final String name;
  final String establishType;
  final String address;
  final String phone;
  final double lat;
  final double lng;
  final double? distanceKm;
  final int capacity;
  final int currentEnrollment;
  final int totalClassCount;
  final bool mealProvided;
  final bool busAvailable;
  final bool extendedCare;

  const KindergartenSearch({
    required this.id,
    required this.name,
    required this.establishType,
    required this.address,
    required this.phone,
    required this.lat,
    required this.lng,
    this.distanceKm,
    required this.capacity,
    required this.currentEnrollment,
    required this.totalClassCount,
    required this.mealProvided,
    required this.busAvailable,
    required this.extendedCare,
  });

  factory KindergartenSearch.fromJson(Map<String, dynamic> json) {
    return KindergartenSearch(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      establishType: json['establishType'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      lat: (json['lat'] ?? 0.0).toDouble(),
      lng: (json['lng'] ?? 0.0).toDouble(),
      distanceKm: json['distanceKm']?.toDouble(),
      capacity: json['capacity'] ?? 0,
      currentEnrollment: json['currentEnrollment'] ?? 0,
      totalClassCount: json['totalClassCount'] ?? 0,
      mealProvided: json['mealProvided'] ?? false,
      busAvailable: json['busAvailable'] ?? false,
      extendedCare: json['extendedCare'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'establishType': establishType,
      'address': address,
      'phone': phone,
      'lat': lat,
      'lng': lng,
      'distanceKm': distanceKm,
      'capacity': capacity,
      'currentEnrollment': currentEnrollment,
      'totalClassCount': totalClassCount,
      'mealProvided': mealProvided,
      'busAvailable': busAvailable,
      'extendedCare': extendedCare,
    };
  }

  double get occupancyRate {
    if (capacity == 0) return 0.0;
    return currentEnrollment / capacity;
  }

  String get formattedDistance {
    if (distanceKm == null) return '';
    if (distanceKm! < 1) {
      return '${(distanceKm! * 1000).toInt()}m';
    }
    return '${distanceKm!.toStringAsFixed(1)}km';
  }

  @override
  String toString() {
    return 'KindergartenSearch(id: $id, name: $name, establishType: $establishType)';
  }
}