class EvInfo {
  final int stations200m;
  final int? maxKw;

  const EvInfo({required this.stations200m, this.maxKw});

  factory EvInfo.fromJson(Map<String, dynamic> json) => EvInfo(
        stations200m: json['stations_200m'] as int,
        maxKw: json['max_kw'] as int?,
      );
}
