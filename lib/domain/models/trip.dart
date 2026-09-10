enum TripStatus { active, completed, cancelled }

/// Simple lat/lng so domain stays free of map plugin imports.
class LatLngPoint {
  final double latitude;
  final double longitude;

  const LatLngPoint(this.latitude, this.longitude);

  Map<String, dynamic> toMap() => {
        'latitude': latitude,
        'longitude': longitude,
      };

  factory LatLngPoint.fromMap(Map<String, dynamic> map) {
    return LatLngPoint(
      (map['latitude'] as num).toDouble(),
      (map['longitude'] as num).toDouble(),
    );
  }

  @override
  String toString() => '($latitude, $longitude)';
}

class Trip {
  final String id;
  final DateTime startTime;
  final DateTime? endTime;
  final double distanceKm;
  final double? cost;
  final String? notes;
  final List<LatLngPoint> routePoints;
  final TripStatus status;

  const Trip({
    required this.id,
    required this.startTime,
    this.endTime,
    this.distanceKm = 0,
    this.cost,
    this.notes,
    this.routePoints = const [],
    this.status = TripStatus.completed,
  });

  Duration? get duration {
    if (endTime == null) return null;
    return endTime!.difference(startTime);
  }

  bool get isActive => status == TripStatus.active;

  Trip copyWith({
    String? id,
    DateTime? startTime,
    DateTime? endTime,
    double? distanceKm,
    double? cost,
    String? notes,
    List<LatLngPoint>? routePoints,
    TripStatus? status,
  }) {
    return Trip(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      distanceKm: distanceKm ?? this.distanceKm,
      cost: cost ?? this.cost,
      notes: notes ?? this.notes,
      routePoints: routePoints ?? this.routePoints,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'distanceKm': distanceKm,
      'cost': cost,
      'notes': notes,
      'routePointsJson': routePoints.map((p) => p.toMap()).toList(),
      'status': status.name,
    };
  }

  /// Flat map for sqflite row (route points stored as JSON string by repository).
  Map<String, dynamic> toDbMap(String routePointsJson) {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'distanceKm': distanceKm,
      'cost': cost,
      'notes': notes,
      'routePointsJson': routePointsJson,
      'status': status.name,
    };
  }

  factory Trip.fromMap(Map<String, dynamic> map, {List<LatLngPoint>? points}) {
    return Trip(
      id: map['id'] as String,
      startTime: DateTime.parse(map['startTime'] as String),
      endTime: map['endTime'] != null
          ? DateTime.parse(map['endTime'] as String)
          : null,
      distanceKm: (map['distanceKm'] as num?)?.toDouble() ?? 0,
      cost: (map['cost'] as num?)?.toDouble(),
      notes: map['notes'] as String?,
      routePoints: points ?? const [],
      status: TripStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => TripStatus.completed,
      ),
    );
  }
}
