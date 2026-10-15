import 'dart:math' as math;

/// 두 좌표 간 직선거리(미터)를 계산한다. 실제 도보 경로 거리가 아닌 근사치이며,
/// Phase 5에서 실제 도보 경로 API로 교체될 수 있다.
double calculateStraightLineDistanceMeters({
  required double startLatitude,
  required double startLongitude,
  required double endLatitude,
  required double endLongitude,
}) {
  const earthRadiusMeters = 6371000.0;
  final dLat = _degToRad(endLatitude - startLatitude);
  final dLon = _degToRad(endLongitude - startLongitude);

  final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(_degToRad(startLatitude)) *
          math.cos(_degToRad(endLatitude)) *
          math.sin(dLon / 2) *
          math.sin(dLon / 2);
  final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

  return earthRadiusMeters * c;
}

double _degToRad(double degrees) => degrees * (math.pi / 180);
