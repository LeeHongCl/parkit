class RecommendationWeights {
  final double fee;
  final double distance;
  final double availability;

  const RecommendationWeights({
    required this.fee,
    required this.distance,
    required this.availability,
  });
}

enum RecommendationType {
  priceFirst,
  distanceFirst,
  balanced;

  String get label {
    switch (this) {
      case RecommendationType.priceFirst:
        return '가격 우선형';
      case RecommendationType.distanceFirst:
        return '거리 우선형';
      case RecommendationType.balanced:
        return '균형형';
    }
  }

  String get description {
    switch (this) {
      case RecommendationType.priceFirst:
        return '요금이 저렴한 주차장을 우선 추천합니다';
      case RecommendationType.distanceFirst:
        return '목적지까지 가까운 주차장을 우선 추천합니다';
      case RecommendationType.balanced:
        return '요금과 거리를 균형 있게 고려합니다';
    }
  }

  RecommendationWeights get weights {
    switch (this) {
      case RecommendationType.priceFirst:
        return const RecommendationWeights(fee: 0.60, distance: 0.25, availability: 0.15);
      case RecommendationType.distanceFirst:
        return const RecommendationWeights(fee: 0.20, distance: 0.65, availability: 0.15);
      case RecommendationType.balanced:
        return const RecommendationWeights(fee: 0.40, distance: 0.40, availability: 0.20);
    }
  }
}
