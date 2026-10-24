class RecommendWeights {
  final double fee;
  final double distance;
  final double ev;

  const RecommendWeights({required this.fee, required this.distance, required this.ev});

  RecommendWeights copyWith({double? fee, double? distance, double? ev}) => RecommendWeights(
        fee: fee ?? this.fee,
        distance: distance ?? this.distance,
        ev: ev ?? this.ev,
      );

  bool get hasAnyPositive => fee > 0 || distance > 0 || ev > 0;

  @override
  bool operator ==(Object other) =>
      other is RecommendWeights && other.fee == fee && other.distance == distance && other.ev == ev;

  @override
  int get hashCode => Object.hash(fee, distance, ev);
}
