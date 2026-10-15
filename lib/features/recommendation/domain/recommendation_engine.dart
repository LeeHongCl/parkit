import '../../../core/utils/distance_calculator.dart';
import '../../parking/domain/parking_fee_calculator.dart';
import '../../parking/domain/parking_lot.dart';
import '../../search/domain/destination.dart';
import 'parking_recommendation.dart';
import 'recommendation_type.dart';

/// 추천 알고리즘을 별도 모듈로 분리: 요금/거리/가용성을 정규화한 뒤
/// 추천 유형별 가중치를 적용해 점수를 산출하고 추천 사유를 함께 만든다.
class RecommendationEngine {
  static List<ParkingRecommendation> recommend({
    required List<ParkingLot> lots,
    required Destination destination,
    required int parkingMinutes,
    required RecommendationType type,
  }) {
    if (lots.isEmpty) return const [];

    final weights = type.weights;

    final distanceById = <String, double>{};
    final feeById = <String, int?>{};

    for (final lot in lots) {
      distanceById[lot.id] = calculateStraightLineDistanceMeters(
        startLatitude: destination.latitude,
        startLongitude: destination.longitude,
        endLatitude: lot.latitude,
        endLongitude: lot.longitude,
      );
      feeById[lot.id] = calculateEstimatedFee(lot, parkingMinutes);
    }

    final knownFees = feeById.values.whereType<int>().toList();
    final minFee = knownFees.isEmpty ? null : knownFees.reduce((a, b) => a < b ? a : b);
    final maxFee = knownFees.isEmpty ? null : knownFees.reduce((a, b) => a > b ? a : b);

    final distanceValues = distanceById.values.toList();
    final minDistance = distanceValues.reduce((a, b) => a < b ? a : b);
    final maxDistance = distanceValues.reduce((a, b) => a > b ? a : b);

    final recommendations = lots.map((lot) {
      final fee = feeById[lot.id];
      final distance = distanceById[lot.id]!;

      final feeScore = _normalizedInverseScore(
        value: fee?.toDouble(),
        min: minFee?.toDouble(),
        max: maxFee?.toDouble(),
        fallback: 0.5,
      );
      final distanceScore = _normalizedInverseScore(
        value: distance,
        min: minDistance,
        max: maxDistance,
        fallback: 0.5,
      );
      final availabilityScore = _availabilityScore(lot);

      final score = feeScore * weights.fee +
          distanceScore * weights.distance +
          availabilityScore * weights.availability;

      return ParkingRecommendation(
        parkingLot: lot,
        estimatedFee: fee,
        walkingDistanceMeters: distance,
        recommendationScore: score,
        reasons: _buildReasons(
          lot: lot,
          fee: fee,
          distance: distance,
          minFee: minFee,
          minDistance: minDistance,
          type: type,
        ),
      );
    }).toList();

    recommendations.sort((a, b) => b.recommendationScore.compareTo(a.recommendationScore));
    return recommendations;
  }

  static double _normalizedInverseScore({
    required double? value,
    required double? min,
    required double? max,
    required double fallback,
  }) {
    if (value == null || min == null || max == null) return fallback;
    if (max == min) return 1.0;
    return 1.0 - ((value - min) / (max - min));
  }

  /// 가용성 데이터가 없는 경우 "주차 가능"을 임의로 추정하지 않고
  /// 점수 계산용 중립값(0.5)만 사용한다. 실제 가용 여부는 UI에서 항상
  /// "정보 없음"으로 명시한다.
  static double _availabilityScore(ParkingLot lot) {
    if (!lot.hasRealtimeAvailability) return 0.5;
    final available = lot.availableSpaces!;
    if (available <= 0) return 0.0;
    final capacity = lot.capacity;
    if (capacity == null || capacity <= 0) return 1.0;
    return (available / capacity).clamp(0.0, 1.0);
  }

  static List<String> _buildReasons({
    required ParkingLot lot,
    required int? fee,
    required double distance,
    required int? minFee,
    required double minDistance,
    required RecommendationType type,
  }) {
    final reasons = <String>[];

    if (fee != null && minFee != null && fee == minFee) {
      reasons.add('주변 후보 대비 저렴한 예상 주차 요금');
    }
    if (distance == minDistance) {
      reasons.add('목적지까지 짧은 도보거리(직선거리 기준)');
    }
    if (type == RecommendationType.balanced && reasons.length >= 2) {
      reasons.add('가격과 거리의 균형');
    }
    if (lot.hasRealtimeAvailability && (lot.availableSpaces ?? 0) > 0) {
      reasons.add('확인된 주차 가능 정보');
    } else if (!lot.hasRealtimeAvailability) {
      reasons.add('실시간 주차 가능 정보 미제공');
    }

    return reasons;
  }
}
