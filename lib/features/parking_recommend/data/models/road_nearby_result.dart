class RoadSpot {
  final double lat;
  final double lng;
  final String? roadName;

  const RoadSpot({required this.lat, required this.lng, this.roadName});

  factory RoadSpot.fromJson(Map<String, dynamic> json) => RoadSpot(
        lat: (json['lat'] as num).toDouble(),
        lng: (json['lng'] as num).toDouble(),
        roadName: json['road_name'] as String?,
      );
}

class RoadCamera {
  final double lat;
  final double lng;
  final String? place;
  final String? roadName;

  const RoadCamera({required this.lat, required this.lng, this.place, this.roadName});

  factory RoadCamera.fromJson(Map<String, dynamic> json) => RoadCamera(
        lat: (json['lat'] as num).toDouble(),
        lng: (json['lng'] as num).toDouble(),
        place: json['place'] as String?,
        roadName: json['road_name'] as String?,
      );
}

/// GET /api/v1/road/nearby 응답. 위험도 점수가 아닌 위치 정보만 담는다(참고용).
class RoadNearbyResult {
  final int totalSpots;
  final bool truncated;
  final List<RoadSpot> spots;
  final List<RoadCamera> cameras;
  final List<String> notes;

  const RoadNearbyResult({
    required this.totalSpots,
    required this.truncated,
    required this.spots,
    required this.cameras,
    required this.notes,
  });

  factory RoadNearbyResult.fromJson(Map<String, dynamic> json) => RoadNearbyResult(
        totalSpots: json['total_spots'] as int,
        truncated: json['truncated'] as bool,
        spots: ((json['spots'] as List?) ?? const [])
            .map((e) => RoadSpot.fromJson(e as Map<String, dynamic>))
            .toList(),
        cameras: ((json['cameras'] as List?) ?? const [])
            .map((e) => RoadCamera.fromJson(e as Map<String, dynamic>))
            .toList(),
        notes: ((json['notes'] as List?) ?? const []).map((e) => e as String).toList(),
      );
}
