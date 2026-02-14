class Favorite {
  final String id; // favorite ID
  final String centerId; // kindergarten ID
  final String centerName;
  final DateTime createdAt;

  const Favorite({
    required this.id,
    required this.centerId,
    required this.centerName,
    required this.createdAt,
  });

  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite(
      id: json['id'] ?? '',
      centerId: json['centerId'] ?? '',
      centerName: json['centerName'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'centerId': centerId,
      'centerName': centerName,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Favorite(id: $id, centerId: $centerId, centerName: $centerName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Favorite && other.centerId == centerId;
  }

  @override
  int get hashCode => centerId.hashCode;
}

class FavoriteRequest {
  final String deviceId;
  final String centerId;

  const FavoriteRequest({
    required this.deviceId,
    required this.centerId,
  });

  Map<String, dynamic> toJson() {
    return {
      'deviceId': deviceId,
      'centerId': centerId,
    };
  }
}