class MetaResult {
  final int parkingLots;
  final String? dataCollectedAt;
  final String? dataProcessedAt;
  final String? dataUpdatedAt;

  const MetaResult({
    required this.parkingLots,
    this.dataCollectedAt,
    this.dataProcessedAt,
    this.dataUpdatedAt,
  });

  factory MetaResult.fromJson(Map<String, dynamic> json) => MetaResult(
        parkingLots: json['parking_lots'] as int,
        dataCollectedAt: json['data_collected_at'] as String?,
        dataProcessedAt: json['data_processed_at'] as String?,
        dataUpdatedAt: json['data_updated_at'] as String?,
      );

  /// 앞 10자리(YYYY-MM-DD)만 노출. 값이 없으면 null을 반환해 문구 자체를 숨기게 한다.
  String? get displayDate {
    final updated = dataUpdatedAt;
    if (updated == null || updated.length < 10) return null;
    return updated.substring(0, 10);
  }
}
