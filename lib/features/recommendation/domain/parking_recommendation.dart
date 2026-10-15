import '../../parking/domain/parking_lot.dart';

class ParkingRecommendation {
  final ParkingLot parkingLot;
  final int? estimatedFee;
  final double? walkingDistanceMeters;
  final double recommendationScore;
  final List<String> reasons;

  const ParkingRecommendation({
    required this.parkingLot,
    required this.estimatedFee,
    required this.walkingDistanceMeters,
    required this.recommendationScore,
    required this.reasons,
  });
}
