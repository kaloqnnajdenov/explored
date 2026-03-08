class UserPoint {
  const UserPoint({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
  });

  final String id;
  final double latitude;
  final double longitude;
  final DateTime createdAt;

  UserPoint copyWith({
    String? id,
    double? latitude,
    double? longitude,
    DateTime? createdAt,
  }) {
    return UserPoint(
      id: id ?? this.id,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': createdAt.toUtc().toIso8601String(),
    };
  }

  static UserPoint fromJson(Map<String, Object?> json) {
    return UserPoint(
      id: json['id'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
