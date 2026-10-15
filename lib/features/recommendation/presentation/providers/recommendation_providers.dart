import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../parking/presentation/providers/parking_providers.dart';
import '../../../search/domain/destination.dart';
import '../../../search/presentation/providers/search_providers.dart';
import '../../domain/parking_recommendation.dart';
import '../../domain/recommendation_engine.dart';
import '../../domain/recommendation_type.dart';

class RecommendationTypeNotifier extends Notifier<RecommendationType> {
  @override
  RecommendationType build() => RecommendationType.balanced;

  void select(RecommendationType type) => state = type;
}

final recommendationTypeProvider =
    NotifierProvider<RecommendationTypeNotifier, RecommendationType>(
  RecommendationTypeNotifier.new,
);

class ParkingDurationMinutesNotifier extends Notifier<int> {
  @override
  int build() => 180;

  void select(int minutes) => state = minutes;
}

final parkingDurationMinutesProvider =
    NotifierProvider<ParkingDurationMinutesNotifier, int>(
  ParkingDurationMinutesNotifier.new,
);

final recommendationsProvider =
    Provider.autoDispose<AsyncValue<List<ParkingRecommendation>>>((ref) {
  final lotsAsync = ref.watch(nearbyParkingLotsProvider);
  final destination = ref.watch(selectedDestinationProvider) ?? Destination.sample;
  final type = ref.watch(recommendationTypeProvider);
  final minutes = ref.watch(parkingDurationMinutesProvider);

  return lotsAsync.whenData((lots) {
    return RecommendationEngine.recommend(
      lots: lots,
      destination: destination,
      parkingMinutes: minutes,
      type: type,
    );
  });
});
