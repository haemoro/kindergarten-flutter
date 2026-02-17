class MapMarker {
  final String id;
  final String name;
  final String establishType;
  final String? address;
  final String? phone;
  final double lat;
  final double lng;

  const MapMarker({
    required this.id,
    required this.name,
    required this.establishType,
    this.address,
    this.phone,
    required this.lat,
    required this.lng,
  });

  factory MapMarker.fromJson(Map<String, dynamic> json) {
    return MapMarker(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      establishType: json['establishType'] ?? '',
      address: json['address'],
      phone: json['phone'],
      lat: (json['lat'] ?? 0.0).toDouble(),
      lng: (json['lng'] ?? 0.0).toDouble(),
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
    };
  }

  @override
  String toString() {
    return 'MapMarker(id: $id, name: $name, establishType: $establishType)';
  }
}